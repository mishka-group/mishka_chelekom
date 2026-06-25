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
        module: "Tooltip",
        type: "file",
        file: "tooltip.js",
        imports: "import Tooltip from \"./tooltip.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-disabled"],
          required: true
        ],
        parts: [
          trigger: [
            element: "span",
            aria: ["aria-describedby"],
            data_attributes: ["data-popup-open"],
            note: "hover or focus this element to reveal the tooltip"
          ],
          popup: [
            element: "div",
            role: "tooltip",
            data_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-starting-style"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Tooltip (non-modal) + anchored positioning",
        keyboard: ["Escape: close", "blur: close"],
        focus: "Never steals focus; the trigger is described by the popup (aria-describedby)."
      ],
      state_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-popup-open", "data-starting-style"],
      hooks: ["Tooltip"]
    ]
  ]
]
