[
  splitter: [
    name: "splitter",
    category: "layout",
    doc_url: "https://mishka.tools/chelekom/docs/headless/splitter",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/windowsplitter/",
    args: [type: ["splitter"], only: ["splitter"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "Splitter", type: "file", file: "splitter.js", imports: "import Splitter from \"./splitter.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-orientation", "data-dragging", "data-disabled"],
          note: "carries the Splitter hook; exposes --chelekom-splitter-pos (percent) for panel sizing",
          required: true
        ],
        parts: [
          panel: [element: "div", note: "the two panes (data-index 0/1)"],
          resizer: [
            element: "div",
            role: "separator",
            aria: ["aria-orientation", "aria-valuemin", "aria-valuemax", "aria-valuenow"],
            note: "drag or arrow-key to resize"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Window Splitter",
        keyboard: ["Arrow ±1 (Shift ×10)", "Home → min · End → max"]
      ],
      state_attributes: ["data-orientation", "data-dragging", "data-disabled"],
      hooks: ["Splitter"]
    ]
  ]
]
