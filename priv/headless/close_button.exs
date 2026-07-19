[
  close_button: [
    name: "close_button",
    category: "buttons",
    doc_url: "https://mishka.tools/chelekom/docs/headless/close_button",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/button/",
    args: [type: ["close_button"], only: ["close_button"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "button",
          role: "button",
          aria: ["aria-label"],
          data_attributes: ["data-disabled"],
          note: "icon-only button; always carries an accessible label",
          required: true
        ],
        parts: [
          icon: [element: "span", note: "the built-in ✕, rendered only when no custom icon is given"]
        ]
      ],
      aria_pattern: [pattern: "Button", keyboard: ["Enter / Space — activate"]],
      state_attributes: ["data-disabled"],
      hooks: []
    ]
  ]
]
