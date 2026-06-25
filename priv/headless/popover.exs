[
  popover: [
    name: "popover",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["popover"], only: ["popover"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Popover",
        type: "file",
        file: "popover.js",
        imports: "import Popover from \"./popover.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-modal", "data-disabled"],
          required: true
        ],
        parts: [
          trigger: [
            element: "button",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls"],
            data_attributes: ["data-popup-open", "data-pressed", "data-disabled"]
          ],
          backdrop: [
            element: "div",
            aria: ["aria-hidden"],
            note: "rendered only when modal is not false"
          ],
          popup: [
            element: "div",
            role: "dialog",
            aria: ["aria-modal", "aria-labelledby", "aria-describedby"],
            data_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-starting-style"]
          ],
          title: [element: "h2"],
          description: [element: "p"],
          content: [element: "div"],
          close: [element: "button", note: "footer; use data-close to close"]
        ]
      ],
      aria_pattern: [
        pattern: "Dialog (non-modal by default) + anchored positioning",
        keyboard: ["Escape: close", "Tab: trapped cycle when modal", "click outside: close"],
        focus: "Focus moves into the popup on open (initial_focus); restored to the trigger (or final_focus) on close."
      ],
      state_attributes: [
        "data-open",
        "data-closed",
        "data-side",
        "data-align",
        "data-modal",
        "data-popup-open",
        "data-pressed",
        "data-starting-style"
      ],
      hooks: ["Popover"]
    ]
  ]
]
