// Editor configuration — THIS FILE IS YOURS.
//
// Chelekom creates it once and never overwrites it, so anything you put here survives
// `mix mishka.ui.gen.headless editor` being run again. (The engine next to it, editor_*.js, IS
// regenerated — never edit that one.)
//
// Install a package first, with the tool you already have:
//
//     mix mishka.assets.deps @tiptap/extension-table@3.28.0
//
// then register it here.
//
//     import Table from "@tiptap/extension-table";
//     import TableRow from "@tiptap/extension-table-row";
//
//     export default {
//       extensions: [Table.configure({ resizable: true }), TableRow],
//       starterKit: { heading: { levels: [1, 2, 3] } },
//     };
//
// `extensions` are appended after StarterKit; `starterKit` is passed to StarterKit.configure/1
// (use it to tune or switch off what StarterKit already bundles). Both keys are optional.
//
// Engines other than TipTap read the same shape: `extensions` is handed to whatever the engine
// calls its plugin list, so switching engines does not mean re-learning this file.

export default {
  extensions: [],
  starterKit: {},
};
