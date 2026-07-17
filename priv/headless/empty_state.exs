[
  empty_state: [
    name: "empty_state",
    category: "feedback",
    doc_url: "https://mishka.tools/chelekom/docs/headless/empty_state",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["empty_state"], only: ["empty_state"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-align"],
          note: "container; data-align is left|center|right — the only styling hook it ships",
          required: true
        ],
        parts: [
          indicator: [
            element: "div",
            note: "icon or illustration (from the `indicator` slot); decorative"
          ],
          body: [element: "div", note: "wraps the title, description and any extra content"],
          title: [element: "div", note: "heading text — the `title` attr or content"],
          description: [element: "div", note: "supporting text — the `description` attr or content"],
          actions: [element: "div", note: "optional call-to-action buttons (from the `actions` slot)"]
        ]
      ],
      aria_pattern: [pattern: "Empty state (no formal APG pattern)", keyboard: []],
      state_attributes: ["data-align"],
      hooks: []
    ]
  ]
]
