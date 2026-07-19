// Editor (Milkdown 7) — markdown engine for the headless `editor` component.
//
// Same element contract and same hook name as every other editor engine, so the component's
// markup never changes when you switch `--lib`. See editor_tiptap.js for the full contract table.
//
// Format: this engine stores MARKDOWN SOURCE (`format="markdown"`).
//
// The teardown here is deliberately defensive. Milkdown's `create()` and `destroy()` are BOTH
// async, and `destroy()` called while the editor is still creating returns a promise that
// re-polls every 50ms until creation finishes. LiveView's destroyed() does not await anything, so
// on fast navigation the editor would finish constructing into a detached node and only then tear
// down — stacking live editors, each still holding its ProseMirror DOM handlers. Every teardown is
// therefore chained off the create promise and guarded by a disposed flag.

import { Editor as MilkdownEditor, rootCtx, defaultValueCtx, editorViewOptionsCtx } from "@milkdown/kit/core";
import { commonmark } from "@milkdown/kit/preset/commonmark";
import { gfm } from "@milkdown/kit/preset/gfm";
import { history } from "@milkdown/kit/plugin/history";
import { listener, listenerCtx } from "@milkdown/kit/plugin/listener";
import { getMarkdown, replaceAll } from "@milkdown/kit/utils";
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
    this.timer = null;
    this.remote = false;
    this.disposed = false;

    const config = userConfig || {};
    const editable = el.getAttribute("data-editable") !== "false";

    this.ready = MilkdownEditor.make()
      .config((ctx) => {
        ctx.set(rootCtx, el);
        ctx.set(defaultValueCtx, el.getAttribute("data-value") || "");
        ctx.update(editorViewOptionsCtx, (prev) => ({ ...prev, editable: () => this.editable }));

        ctx.get(listenerCtx).markdownUpdated((_ctx, markdown) => this.schedule(markdown));
        ctx.get(listenerCtx).focus(() => this.render());
        ctx.get(listenerCtx).blur(() => {
          this.render();
          this.commit();
        });
      })
      .use(commonmark)
      .use(gfm)
      .use(history)
      .use(listener)
      .use(config.extensions || [])
      .create()
      .then((editor) => {
        // The hook may already have been destroyed while this was in flight; if so tear the
        // finished editor down immediately instead of leaving it attached to a detached node.
        if (this.disposed) {
          editor.destroy();
          return null;
        }

        this.editor = editor;
        this.render();
        return editor;
      })
      .catch(() => null);

    this.editable = editable;

    this.setRef = this.handleEvent("chelekom:editor", (payload) => {
      if (!payload || (payload.id && payload.id !== this.rootId)) return;
      this.applyRemote(payload.value ?? "");
    });
  },

  updated() {
    const editable = this.el.getAttribute("data-editable") !== "false";
    if (editable === this.editable) return;

    this.editable = editable;
    // editorViewOptionsCtx reads `editable` through the closure above, so the view only needs a
    // nudge to re-evaluate it — never rebuild, that would lose the cursor and history.
    this.editor?.action((ctx) => {
      ctx.update(editorViewOptionsCtx, (prev) => ({ ...prev }));
    });
    this.render();
  },

  destroyed() {
    this.disposed = true;
    if (this.timer) clearTimeout(this.timer);
    if (this.setRef) this.removeHandleEvent(this.setRef);

    // Chain off the create promise: calling destroy() mid-creation would otherwise enter
    // Milkdown's 50ms re-poll loop that nothing here can await.
    this.ready = (this.ready || Promise.resolve())
      .then((editor) => editor?.destroy())
      .catch(() => null);

    this.editor = null;
  },

  render() {
    if (!this.editor) return;
    const markdown = this.markdown();
    toggle(this.root, "data-empty", !markdown || markdown.trim() === "");
  },

  markdown() {
    try {
      return this.editor?.action(getMarkdown()) ?? "";
    } catch (_e) {
      return "";
    }
  },

  schedule(markdown) {
    if (this.remote) return;
    if (this.timer) clearTimeout(this.timer);
    this.timer = setTimeout(() => this.commit(markdown), this.debounceMs);
  },

  commit(markdown) {
    if (!this.hidden) return;

    const next = markdown ?? this.markdown();
    if (this.hidden.value === next) return;

    this.hidden.value = next;
    this.hidden.dispatchEvent(new Event("input", { bubbles: true }));
    this.push(this.onChange, next);
    this.render();
  },

  applyRemote(value) {
    if (!this.editor) return;
    this.remote = true;

    try {
      this.editor.action(replaceAll(value));
      if (this.hidden) this.hidden.value = value;
      this.render();
    } finally {
      this.remote = false;
    }
  },

  push(event, value) {
    if (!event) return;
    this.pushEventTo(this.el, event, { value: value ?? this.markdown() });
  },
};

export default Editor;

