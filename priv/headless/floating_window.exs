[
  floating_window: [
    name: "floating_window",
    category: "overlays",
    doc_url: "https://mishka.tools/chelekom/docs/headless/floating_window",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/",
    args: [type: ["floating_window"], only: ["floating_window"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "FloatingWindow", type: "file", file: "floating_window.js", imports: "import FloatingWindow from \"./floating_window.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-x", "data-y", "data-dragging", "data-on-move"],
          note: "carries the FloatingWindow hook; must be positioned inside a positioned ancestor",
          required: true
        ],
        parts: [
          handle: [element: "div", note: "the drag handle; interactive children don't start a drag"],
          body: [element: "div", note: "window content"]
        ]
      ],
      aria_pattern: [
        pattern: "Movable window (dialog-like)",
        keyboard: ["Pointer drag on the handle to move"]
      ],
      state_attributes: ["data-x", "data-y", "data-dragging"],
      hooks: ["FloatingWindow"]
    ]
  ]
]
