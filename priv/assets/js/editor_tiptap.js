// Editor — headless rich-text editor engine (TipTap 3 / ProseMirror).
//
// The hook lives on `[data-part="surface"]`, NOT on the component root. The surface is
// `phx-update="ignore"` because TipTap owns that subtree, and LiveView merges ONLY `data-*` on an
// ignored element — `class`, `style` and `aria-*` freeze at first render. Keeping the boundary
// inner lets the root stay a normal, server-styled element while `data-*` on the surface remains
// the one live channel from the server.
//
// Element contract:
//   [data-part="root"]     — component root, carries the consumer's class and the state attrs the
//                            engine writes: data-empty, data-focused
//   [data-part="surface"]  — carries the hook + phx-update="ignore"; id is `<root id>-surface`;
//                            all configuration is read from ITS data-* (see table below)
//   [data-part="value"]    — hidden <textarea> mirror carrying `name`; what the form submits.
//                            Never give it phx-change: LiveView's form recovery skips elements
//                            that have one, and the document would be lost on reconnect.
//   [data-editor-command]  — optional toolbar buttons anywhere in the root; the engine binds them
//                            by delegation (so they survive morphdom) and marks the active ones
//                            with data-active.
//
//   data-* on the surface   | meaning
//   ------------------------|--------------------------------------------------------------
//   data-root-id            | id of the root; also the id `chelekom:editor` filters on
//   data-value-id           | id of the hidden mirror
//   data-format             | "json" (default, XSS-safe) or "html"
//   data-value              | initial document
//   data-placeholder        | empty-state text, rendered by CSS from data-empty on the root
//   data-editable           | "true"/"false" — live-togglable, since data-* crosses the boundary
//   data-debounce           | ms to wait before committing to the mirror (default 300)
//   data-on-change          | LiveView event pushed with {value} after each commit
//   data-on-focus/-blur     | optional LiveView events, pushed with {value}
//
// Server -> client: `push_event("chelekom:editor", %{id: <root id>, value: ...})`. A single global
// event name with an id filter in the payload, matching otp.js — a per-instance name cannot be
// produced by a LiveComponent that does not know the DOM id.

import { Editor as TipTapEditor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";

// Commands a toolbar button may request via [data-editor-command]. Each maps to a TipTap chain.
const COMMANDS = {
  bold: (c) => c.toggleBold(),
  italic: (c) => c.toggleItalic(),
  strike: (c) => c.toggleStrike(),
  code: (c) => c.toggleCode(),
  paragraph: (c) => c.setParagraph(),
  h1: (c) => c.toggleHeading({ level: 1 }),
  h2: (c) => c.toggleHeading({ level: 2 }),
  h3: (c) => c.toggleHeading({ level: 3 }),
  bullet_list: (c) => c.toggleBulletList(),
  ordered_list: (c) => c.toggleOrderedList(),
  blockquote: (c) => c.toggleBlockquote(),
  code_block: (c) => c.toggleCodeBlock(),
  horizontal_rule: (c) => c.setHorizontalRule(),
  undo: (c) => c.undo(),
  redo: (c) => c.redo(),
};

// What `isActive` should be asked for a given command, when it is a toggle.
const ACTIVE_CHECKS = {
  bold: ["bold"],
  italic: ["italic"],
  strike: ["strike"],
  code: ["code"],
  paragraph: ["paragraph"],
  h1: ["heading", { level: 1 }],
  h2: ["heading", { level: 2 }],
  h3: ["heading", { level: 3 }],
  bullet_list: ["bulletList"],
  ordered_list: ["orderedList"],
  blockquote: ["blockquote"],
  code_block: ["codeBlock"],
};

// ---- pure helpers -------------------------------------------------------------------------

// JSON documents arrive as a string on a data-* attribute. Anything unparseable is treated as
// "no document" rather than throwing, so one bad row can never break the whole page.
export function parseInitial(raw, format) {
  if (raw == null || raw === "") return format === "json" ? null : "";
  if (format !== "json") return raw;

  try {
    return JSON.parse(raw);
  } catch (_e) {
    return null;
  }
}

export function serialize(editor, format) {
  if (!editor) return "";
  return format === "json" ? JSON.stringify(editor.getJSON()) : editor.getHTML();
}

function toggle(el, attr, on) {
  if (!el) return;
  if (on) el.setAttribute(attr, "");
  else el.removeAttribute(attr);
}

// ---- hook ---------------------------------------------------------------------------------

const Editor = {
  mounted() {
    const el = this.el;

    this.rootId = el.getAttribute("data-root-id");
    this.root = document.getElementById(this.rootId) || el.parentElement;
    this.hidden = document.getElementById(el.getAttribute("data-value-id"));
    this.format = el.getAttribute("data-format") === "html" ? "html" : "json";
    this.debounceMs = parseInt(el.getAttribute("data-debounce"), 10) || 300;
    this.onChange = el.getAttribute("data-on-change");
    this.onFocus = el.getAttribute("data-on-focus");
    this.onBlur = el.getAttribute("data-on-blur");
    this.timer = null;
    this.remote = false;

    this.editor = new TipTapEditor({
      element: el,
      extensions: [StarterKit],
      content: parseInitial(el.getAttribute("data-value"), this.format),
      editable: el.getAttribute("data-editable") !== "false",
      onUpdate: () => this.schedule(),
      onSelectionUpdate: () => this.render(),
      onFocus: () => {
        this.render();
        this.push(this.onFocus);
      },
      onBlur: () => {
        this.render();
        this.commit();
        this.push(this.onBlur);
      },
    });

    // Toolbar clicks are delegated from the root, not bound per button: the toolbar lives outside
    // the ignored subtree, so morphdom may replace those nodes on any patch and per-node
    // listeners would silently stop working.
    this._onToolbar = (event) => {
      const button = event.target.closest("[data-editor-command]");
      if (!button || !this.root.contains(button) || !this.editor) return;
      const run = COMMANDS[button.getAttribute("data-editor-command")];
      if (!run) return;
      event.preventDefault();
      run(this.editor.chain().focus()).run();
    };

    // Pressing a toolbar button must not blur the editor first, or the command applies to a lost
    // selection.
    this._onToolbarDown = (event) => {
      if (event.target.closest("[data-editor-command]")) event.preventDefault();
    };

    this.root.addEventListener("click", this._onToolbar);
    this.root.addEventListener("mousedown", this._onToolbarDown);

    this.setRef = this.handleEvent("chelekom:editor", (payload) => {
      if (!payload || (payload.id && payload.id !== this.rootId)) return;
      this.applyRemote(payload.value ?? "");
    });

    this.render();
  },

  // Only data-* survive on an ignored element, so this is where live config lands. Never destroy
  // and rebuild the editor here — that would lose the cursor and the undo history.
  updated() {
    if (!this.editor) return;

    const editable = this.el.getAttribute("data-editable") !== "false";
    if (this.editor.isEditable !== editable) this.editor.setEditable(editable);

    // A patch may have stripped the state attrs the engine owns; repaint them.
    this.render();
  },

  destroyed() {
    if (this.timer) clearTimeout(this.timer);
    if (this.setRef) this.removeHandleEvent(this.setRef);
    if (this.root) {
      this.root.removeEventListener("click", this._onToolbar);
      this.root.removeEventListener("mousedown", this._onToolbarDown);
    }
    // The single biggest leak: without this the ProseMirror view, its plugins and its DOM
    // listeners outlive every LiveView navigation.
    if (this.editor) this.editor.destroy();
    this.editor = null;
  },

  // Presentation only — never pushes, so it is safe to call from updated() without risking a
  // render -> push -> patch -> render loop.
  render() {
    if (!this.editor) return;

    toggle(this.root, "data-empty", this.editor.isEmpty);
    toggle(this.root, "data-focused", this.editor.isFocused);

    for (const button of this.root.querySelectorAll("[data-editor-command]")) {
      const check = ACTIVE_CHECKS[button.getAttribute("data-editor-command")];
      if (check) toggle(button, "data-active", this.editor.isActive(...check));
    }
  },

  // The only place that writes the mirror and pushes.
  commit() {
    if (!this.editor || !this.hidden) return;

    const next = serialize(this.editor, this.format);
    if (this.hidden.value === next) return;

    this.hidden.value = next;
    // Bubbling, and a plain Event on a form-associated element: this is what makes an enclosing
    // <.form phx-change> fire for a value set programmatically.
    this.hidden.dispatchEvent(new Event("input", { bubbles: true }));
    this.push(this.onChange, next);
  },

  schedule() {
    this.render();
    // Server-applied content must not echo straight back as a user edit.
    if (this.remote) return;
    if (this.timer) clearTimeout(this.timer);
    this.timer = setTimeout(() => this.commit(), this.debounceMs);
  },

  applyRemote(value) {
    if (!this.editor) return;
    this.remote = true;

    try {
      this.editor.commands.setContent(parseInitial(value, this.format), false);
      if (this.hidden) this.hidden.value = serialize(this.editor, this.format);
      this.render();
    } finally {
      this.remote = false;
    }
  },

  push(event, value) {
    if (!event) return;
    this.pushEventTo(this.el, event, { value: value ?? serialize(this.editor, this.format) });
  },
};

export default Editor;
