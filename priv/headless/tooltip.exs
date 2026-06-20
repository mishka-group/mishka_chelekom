[
  tooltip: [
    name: "tooltip",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/tooltip/",
    args: [type: ["tooltip"], only: ["tooltip"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Popup",
        type: "file",
        file: "popup.js",
        imports: "import Popup from \"./popup.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          trigger: [element: "span", aria: ["aria-describedby"]],
          popup: [
            element: "div",
            role: "tooltip",
            data_attributes: ["data-open", "data-closed", "data-side"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Tooltip",
        keyboard: ["Escape: dismiss"],
        focus: "Never focuses the tooltip"
      ],
      state_attributes: ["data-open", "data-closed", "data-side"],
      hooks: ["Popup"]
    ]
  ]
]
