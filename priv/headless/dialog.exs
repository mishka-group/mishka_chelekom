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
        root: [
          element: "div",
          data_attributes: ["data-open", "data-closed", "data-modal"],
          required: true
        ],
        parts: [
          trigger: [
            element: "button",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls"],
            data_attributes: ["data-popup-open", "data-disabled"]
          ],
          backdrop: [
            element: "div",
            aria: ["aria-hidden"],
            data_attributes: ["data-open", "data-closed", "data-starting-style", "data-ending-style"],
            note: "rendered only when modal is not false"
          ],
          viewport: [
            element: "div",
            data_attributes: ["data-nested", "data-nested-dialog-open"],
            note: "fixed centering + scroll layer for the popup"
          ],
          popup: [
            element: "div",
            role: "dialog",
            aria: ["aria-modal", "aria-labelledby", "aria-describedby"],
            data_attributes: [
              "data-open",
              "data-closed",
              "data-modal",
              "data-starting-style",
              "data-ending-style",
              "data-nested",
              "data-nested-dialog-open"
            ],
            css_vars: ["--nested-dialogs"]
          ],
          title: [element: "h2"],
          description: [element: "p"],
          content: [element: "div"],
          close: [element: "button", note: "footer; use data-close to close (supports disabled)"]
        ]
      ],
      aria_pattern: [
        pattern: "Dialog (Modal)",
        keyboard: ["Escape: close", "Tab: cycle (trapped when modal)", "Shift+Tab: cycle backward"],
        focus: "Trap inside popup when modal; restore focus to opener (or final_focus) on close. initial_focus / final_focus override the targets."
      ],
      state_attributes: ["data-open", "data-closed", "data-modal", "data-nested", "data-nested-dialog-open", "data-starting-style"],
      hooks: ["FocusTrap"]
    ]
  ]
]
