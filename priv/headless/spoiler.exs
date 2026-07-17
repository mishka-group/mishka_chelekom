[
  spoiler: [
    name: "spoiler",
    category: "disclosure",
    doc_url: "https://mishka.tools/chelekom/docs/headless/spoiler",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/",
    args: [type: ["spoiler"], only: ["spoiler"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-expanded"],
          note: "collapsed clamps the content to max-height (CSS); toggled client-side",
          required: true
        ],
        parts: [
          content: [element: "div", note: "the clamped / expanded region"],
          control: [
            element: "button",
            aria: ["aria-expanded", "aria-controls"],
            note: "Show more / Show less toggle (two labels swapped by CSS)"
          ]
        ]
      ],
      aria_pattern: [pattern: "Disclosure", keyboard: ["Enter / Space — toggle"]],
      state_attributes: ["data-expanded"],
      hooks: []
    ]
  ]
]
