[
  floating_window: [
    name: "floating_window",
    category: "overlays",
    doc_url: "https://mishka.tools/chelekom/docs/headless/floating_window",
    spec_url: "https://www.w3.org/TR/wai-aria-1.2/#dialog",
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
          role: "dialog",
          aria: ["aria-label"],
          data_attributes: ["data-x", "data-y", "data-dragging", "data-on-move"],
          note:
            "carries the FloatingWindow hook; non-modal dialog (no focus trap), must be " <>
              "positioned inside a positioned ancestor",
          required: true
        ],
        parts: [
          handle: [
            element: "div",
            aria: ["aria-label", "aria-roledescription"],
            note:
              "the focusable drag handle (role=button); interactive children don't start a drag"
          ],
          body: [element: "div", note: "window content"]
        ]
      ],
      aria_pattern: [
        pattern: "Movable non-modal window (no formal APG pattern)",
        keyboard: [
          "Pointer drag on the handle to move",
          "Arrow keys on the focused handle — move 10px",
          "Shift + Arrow keys — move 1px"
        ]
      ],
      state_attributes: ["data-x", "data-y", "data-dragging"],
      hooks: ["FloatingWindow"]
    ]
  ]
]
