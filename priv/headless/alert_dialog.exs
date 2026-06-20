[
  alert_dialog: [
    name: "alert_dialog",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/",
    args: [type: ["alert_dialog"], only: ["alert_dialog"], helpers: [], module: ""],
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
          data_attributes: ["data-open", "data-closed", "data-close-on-outside"],
          required: true
        ],
        parts: [
          trigger: [element: "button", aria: ["aria-haspopup", "aria-expanded", "aria-controls"]],
          backdrop: [element: "div", aria: ["aria-hidden"]],
          popup: [
            element: "div",
            role: "alertdialog",
            aria: ["aria-modal", "aria-labelledby", "aria-describedby"],
            data_attributes: ["data-open", "data-closed"]
          ],
          title: [element: "h2", required: true],
          description: [element: "p", required: true],
          content: [element: "div"],
          actions: [
            element: "div",
            note: "footer with confirm/cancel buttons; use data-close to close"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Alert Dialog",
        keyboard: ["Escape: close", "Tab: cycle (trapped)", "Shift+Tab: cycle backward"],
        focus: "Trap inside popup; restore focus to opener on close"
      ],
      state_attributes: ["data-open", "data-closed"],
      hooks: ["FocusTrap"]
    ]
  ]
]
