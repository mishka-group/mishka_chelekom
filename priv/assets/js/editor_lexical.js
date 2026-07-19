// Editor (Lexical) — Meta's rich-text engine for the headless `editor` component.
//
// Same element contract and same hook name as every other editor engine, so the component's
// markup never changes when you switch `--lib`. See editor_tiptap.js for the full contract table.
//
// Format: this engine stores the Lexical editor state as JSON (`format="json"`). Prefer it over
// HTML — Lexical's DOM import/export is both lossy and the most actively changing part of the
// library, so committing stored user data to it is the one choice an upgrade could corrupt.
//
// Teardown is entirely manual: Lexical has NO destroy()/dispose(). Two things are mandatory, and
// forgetting either leaks on every LiveView navigation:
//   1. call every unregister function returned at setup (collected via mergeRegister)
//   2. call setRootElement(null) — the ONLY thing that disconnects the MutationObserver, clears
//      the root, and decrements the reference-counted document-level `selectionchange` listener.
//      Skip it and `document` retains this editor and its detached root forever.

import { createEditor } from "lexical";
import { registerRichText } from "@lexical/rich-text";
import { registerHistory, createEmptyHistoryState } from "@lexical/history";
import { mergeRegister } from "@lexical/utils";
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

    const config = userConfig || {};

    // Lexical renders into a contenteditable the engine owns; the surface itself is the ignored
    // node, so build the editable child here rather than making the surface contenteditable.
    this.contentEditable = document.createElement("div");
    this.contentEditable.contentEditable = "true";
    this.contentEditable.setAttribute("data-part", "lexical-content");
    this.contentEditable.style.outline = "none";
    el.appendChild(this.contentEditable);

    this.editor = createEditor({
      namespace: "chelekom-editor",
      // Lexical ships zero styling: the theme maps node types to YOUR class names. Anything not
      // named here renders as a plain paragraph, which is consistent with the headless contract.
      theme: config.theme || {},
      editable: el.getAttribute("data-editable") !== "false",
      onError: (error) => {
        throw error;
      },
      nodes: config.nodes || [],
    });

    this.editor.setRootElement(this.contentEditable);

    const initial = el.getAttribute("data-value");

    if (initial) {
      try {
        this.editor.setEditorState(this.editor.parseEditorState(initial));
      } catch (_e) {
        // A malformed stored document must not take the page down.
      }
    }

    this.unregister = mergeRegister(
      registerRichText(this.editor),
      registerHistory(this.editor, createEmptyHistoryState(), 300),
      this.editor.registerUpdateListener(({ editorState }) => this.schedule(editorState)),
    );

    this._onFocus = () => this.render();
    this._onBlur = () => {
      this.render();
      this.commit();
    };

    this.contentEditable.addEventListener("focus", this._onFocus);
    this.contentEditable.addEventListener("blur", this._onBlur);

    this.setRef = this.handleEvent("chelekom:editor", (payload) => {
      if (!payload || (payload.id && payload.id !== this.rootId)) return;
      this.applyRemote(payload.value ?? "");
    });

    this.render();
  },

  updated() {
    if (!this.editor) return;

    const editable = this.el.getAttribute("data-editable") !== "false";
    if (this.editor.isEditable() !== editable) this.editor.setEditable(editable);

    this.render();
  },

  destroyed() {
    if (this.timer) clearTimeout(this.timer);
    if (this.setRef) this.removeHandleEvent(this.setRef);

    this.contentEditable?.removeEventListener("focus", this._onFocus);
    this.contentEditable?.removeEventListener("blur", this._onBlur);

    // Order matters: unregister listeners first, then detach the root while the editor is still
    // coherent (setRootElement(null) runs a full reconciliation flush internally).
    this.unregister?.();
    this.editor?.setRootElement(null);

    this.editor = null;
    this.contentEditable = null;
  },

  render() {
    if (!this.editor) return;

    const empty = this.text().trim() === "";
    toggle(this.root, "data-empty", empty);
    toggle(this.root, "data-focused", document.activeElement === this.contentEditable);
  },

  text() {
    try {
      return this.editor?.getEditorState().read(() => {
        const root = this.contentEditable;
        return root ? root.textContent || "" : "";
      });
    } catch (_e) {
      return "";
    }
  },

  serialize(editorState) {
    const state = editorState || this.editor?.getEditorState();
    return state ? JSON.stringify(state.toJSON()) : "";
  },

  schedule(editorState) {
    this.render();
    if (this.remote) return;
    if (this.timer) clearTimeout(this.timer);
    this.timer = setTimeout(() => this.commit(this.serialize(editorState)), this.debounceMs);
  },

  commit(value) {
    if (!this.editor || !this.hidden) return;

    const next = value ?? this.serialize();
    if (this.hidden.value === next) return;

    this.hidden.value = next;
    this.hidden.dispatchEvent(new Event("input", { bubbles: true }));
    this.push(this.onChange, next);
  },

  applyRemote(value) {
    if (!this.editor || !value) return;
    this.remote = true;

    try {
      this.editor.setEditorState(this.editor.parseEditorState(value));
      if (this.hidden) this.hidden.value = value;
      this.render();
    } catch (_e) {
      // ignore an unparseable document pushed from the server
    } finally {
      this.remote = false;
    }
  },

  push(event, value) {
    if (!event) return;
    this.pushEventTo(this.el, event, { value: value ?? this.serialize() });
  },
};

export default Editor;
