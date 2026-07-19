// Editor (CodeMirror 6) — code editing engine for the headless `editor` component.
//
// Same element contract and same hook name as every other editor engine, so the component's
// markup never changes when you switch `--lib`. See editor_tiptap.js for the full contract table.
//
// Format: this engine stores PLAIN TEXT (`format="text"`). There is no JSON/HTML document —
// `view.state.doc.toString()` is the whole value.
//
// Extensions are hand-picked rather than `basicSetup`, which is documented as non-customizable
// and additionally drags in the find/replace panel UI. The array below is basicSetup minus
// search, so `editor_extensions.js` can add to it and a consumer can drop a line.

import { EditorState, Compartment } from "@codemirror/state";
import {
  EditorView,
  keymap,
  lineNumbers,
  highlightActiveLine,
  highlightActiveLineGutter,
  highlightSpecialChars,
  drawSelection,
  dropCursor,
  rectangularSelection,
  crosshairCursor,
} from "@codemirror/view";
import { defaultKeymap, history, historyKeymap, indentWithTab } from "@codemirror/commands";
import {
  syntaxHighlighting,
  defaultHighlightStyle,
  indentOnInput,
  bracketMatching,
  foldGutter,
  foldKeymap,
} from "@codemirror/language";
import { javascript } from "@codemirror/lang-javascript";
import userConfig from "./editor_extensions.js";

function toggle(el, attr, on) {
  if (!el) return;
  if (on) el.setAttribute(attr, "");
  else el.removeAttribute(attr);
}

const Editor = {
  mounted() {
    const el = this.el;

    this.rootId = el.getAttribute("data-root-id");
    this.root = document.getElementById(this.rootId) || el.parentElement;
    this.hidden = document.getElementById(el.getAttribute("data-value-id"));
    this.debounceMs = parseInt(el.getAttribute("data-debounce"), 10) || 300;
    this.onChange = el.getAttribute("data-on-change");
    this.onFocus = el.getAttribute("data-on-focus");
    this.onBlur = el.getAttribute("data-on-blur");
    this.timer = null;
    this.remote = false;

    const config = userConfig || {};
    const editable = el.getAttribute("data-editable") !== "false";

    // Compartments let `editable` be reconfigured live. Rebuilding the view instead would lose
    // the cursor, the selection and the undo history on every server patch.
    this.editableComp = new Compartment();
    this.readOnlyComp = new Compartment();

    this.view = new EditorView({
      doc: el.getAttribute("data-value") || "",
      parent: el,
      extensions: [
        lineNumbers(),
        highlightActiveLineGutter(),
        highlightSpecialChars(),
        history(),
        foldGutter(),
        drawSelection(),
        dropCursor(),
        EditorState.allowMultipleSelections.of(true),
        indentOnInput(),
        syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
        bracketMatching(),
        rectangularSelection(),
        crosshairCursor(),
        highlightActiveLine(),
        keymap.of([...defaultKeymap, ...historyKeymap, ...foldKeymap, indentWithTab]),
        javascript(),
        this.editableComp.of(EditorView.editable.of(editable)),
        this.readOnlyComp.of(EditorState.readOnly.of(!editable)),
        EditorView.updateListener.of((update) => {
          if (update.focusChanged) this.render();
          if (!update.docChanged) return;
          // Read from update.state, not this.view.state: during the callback the view's own
          // state is mid-transaction.
          this.schedule(update.state.doc.toString());
        }),
        ...(config.extensions || []),
      ],
    });

    this.setRef = this.handleEvent("chelekom:editor", (payload) => {
      if (!payload || (payload.id && payload.id !== this.rootId)) return;
      this.applyRemote(payload.value ?? "");
    });

    this.render();
  },

  updated() {
    if (!this.view) return;

    const editable = this.el.getAttribute("data-editable") !== "false";

    this.view.dispatch({
      effects: [
        this.editableComp.reconfigure(EditorView.editable.of(editable)),
        this.readOnlyComp.reconfigure(EditorState.readOnly.of(!editable)),
      ],
    });

    this.render();
  },

  destroyed() {
    if (this.timer) clearTimeout(this.timer);
    if (this.setRef) this.removeHandleEvent(this.setRef);
    // Synchronous and complete: removes the DOM, unregisters handlers, notifies plugins.
    // Note a dispatch after destroy() silently no-ops rather than throwing, so null the ref or a
    // leaked callback fails invisibly.
    this.view?.destroy();
    this.view = null;
  },

  render() {
    if (!this.view) return;
    toggle(this.root, "data-empty", this.view.state.doc.length === 0);
    toggle(this.root, "data-focused", this.view.hasFocus);
  },

  schedule(text) {
    this.render();
    if (this.remote) return;
    if (this.timer) clearTimeout(this.timer);
    this.timer = setTimeout(() => this.commit(text), this.debounceMs);
  },

  commit(text) {
    if (!this.view || !this.hidden) return;

    const next = text ?? this.view.state.doc.toString();
    if (this.hidden.value === next) return;

    this.hidden.value = next;
    this.hidden.dispatchEvent(new Event("input", { bubbles: true }));
    this.push(this.onChange, next);
  },

  applyRemote(value) {
    if (!this.view) return;
    this.remote = true;

    try {
      this.view.dispatch({
        changes: { from: 0, to: this.view.state.doc.length, insert: value },
      });
      if (this.hidden) this.hidden.value = value;
      this.render();
    } finally {
      this.remote = false;
    }
  },

  push(event, value) {
    if (!event || !this.view) return;
    this.pushEventTo(this.el, event, { value: value ?? this.view.state.doc.toString() });
  },
};

export default Editor;

