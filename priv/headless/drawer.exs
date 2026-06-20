[
  drawer: [
    name: "drawer",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/",
    args: [type: ["drawer"], only: ["drawer"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "FocusTrap",
        type: "file",
        file: "focus_trap.js",
        imports: "import FocusTrap from \"./focus_trap.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          trigger: [element: "button"],
          backdrop: [element: "div", aria: ["aria-hidden"]],
          popup: [
            element: "div",
            role: "dialog",
            aria: ["aria-modal", "aria-labelledby", "aria-describedby"],
            data_attributes: ["data-side", "data-open", "data-closed"]
          ],
          title: [element: "h2"],
          description: [element: "p"],
          close: [element: "button"]
        ]
      ],
      aria_pattern: [
        pattern: "Dialog (Modal)",
        keyboard: ["Escape: close", "Tab: trapped cycle"],
        focus: "Trap; restore to opener"
      ],
      state_attributes: ["data-open", "data-closed", "data-side"],
      hooks: ["FocusTrap"]
    ]
  ]
]
