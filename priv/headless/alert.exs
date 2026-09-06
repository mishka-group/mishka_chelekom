[
  alert: [
    name: "alert",
    category: "feedback",
    doc_url: "https://mishka.tools/chelekom/docs/headless/alert",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/alert/",
    args: [type: ["alert"], only: ["alert"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "status | alert",
          aria: ["aria-live", "aria-labelledby"],
          data_attributes: ["data-urgency", "data-dismissible"],
          note:
            "`urgency` picks the semantics: polite → status, assertive → alert (interrupts), " <>
              "off → a plain region for a message already on the page at load",
          required: true
        ],
        parts: [
          icon: [element: "span", note: "decorative, aria-hidden"],
          title: [element: "span", note: "announced first, via the root's aria-labelledby"],
          content: [element: "div", note: "the message"],
          actions: [element: "span", note: "buttons or links at the end"],
          close: [
            element: "button",
            aria: ["aria-label"],
            note: "hides the alert with Phoenix.LiveView.JS unless `on_dismiss` overrides it"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Alert",
        keyboard: ["Enter / Space on the close button — dismiss"]
      ],
      state_attributes: ["data-urgency", "data-dismissible"],
      hooks: []
    ]
  ]
]
