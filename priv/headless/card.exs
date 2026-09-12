[
  card: [
    name: "card",
    category: "data-display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/card",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/",
    args: [type: ["card"], only: ["card"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    headless: [
      anatomy: [
        root: [
          element: "div | a",
          role: "none",
          aria: ["aria-labelledby"],
          data_attributes: ["data-figure-position"],
          note:
            "`navigate`/`patch`/`href` render an anchor instead, which is the honest markup for a " <>
              "card that is one big click target",
          required: true
        ],
        parts: [
          figure: [
            element: "figure",
            note:
              "rendered before or after the body per `figure_position`, which is what the " <>
                "corner-rounding rules key off"
          ],
          body: [element: "div", note: "padding box for title, content and actions"],
          title: [
            element: "h1…h6 | div",
            note: "a real heading at `title_level`, wired to the root via aria-labelledby"
          ],
          content: [element: "div", note: "the inner block"],
          actions: [element: "div", note: "buttons or links at the end of the body"]
        ]
      ],
      aria_pattern: [
        pattern: "None — a card is layout; the heading carries the meaning",
        keyboard: ["Tab — focus, when the card is a link"]
      ],
      state_attributes: ["data-figure-position"],
      hooks: []
    ]
  ]
]
