[
  action_icon: [
    name: "action_icon",
    category: "buttons",
    doc_url: "https://mishka.tools/chelekom/docs/headless/action_icon",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/button/",
    args: [type: ["action_icon"], only: ["action_icon"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "button",
          role: "button",
          aria: ["aria-label"],
          data_attributes: ["data-disabled"],
          note: "icon-only action button; always has an accessible label",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Button", keyboard: ["Enter / Space — activate"]],
      state_attributes: ["data-disabled"],
      hooks: []
    ]
  ]
]
