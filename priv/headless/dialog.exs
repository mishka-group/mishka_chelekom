[
  dialog: [
    name: "dialog",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/",
    args: [type: ["dialog"], only: ["dialog"], helpers: [], module: ""],
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
        root: [element: "div", data_attributes: ["data-open", "data-closed"], required: true],
        parts: [
          trigger: [element: "button", aria: ["aria-haspopup", "aria-expanded", "aria-controls"]],
          backdrop: [element: "div", aria: ["aria-hidden"]],
          popup: [
            element: "div",
            role: "dialog",
            aria: ["aria-modal", "aria-labelledby", "aria-describedby"]
          ],
          title: [element: "h2"],
          description: [element: "p"],
          close: [element: "button"]
        ]
      ],
      aria_pattern: [
        pattern: "Dialog (Modal)",
        keyboard: ["Escape: close", "Tab: cycle (trapped)", "Shift+Tab: cycle backward"],
        focus: "Trap inside popup; restore focus to opener on close"
      ],
      state_attributes: ["data-open", "data-closed"],
      hooks: ["FocusTrap"]
    ]
  ]
]
