[
  dock: [
    name: "dock",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/dock",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/",
    args: [type: ["dock"], only: ["dock"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    headless: [
      anatomy: [
        root: [
          element: "nav",
          role: "navigation",
          aria: ["aria-label"],
          data_attributes: ["data-position", "data-contained"],
          note:
            "a landmark, because a dock is the view's primary navigation; `contained` drops the " <>
              "fixed positioning so it can live inside a mockup",
          required: true
        ],
        parts: [
          item: [
            element: "a | button | span",
            aria: ["aria-current", "aria-disabled"],
            data_attributes: ["data-index", "data-active", "data-disabled"],
            note:
              "a link by default, a button with `on_select`, and a plain span when it goes " <>
                "nowhere — a dead destination should not take a tab stop"
          ],
          icon: [element: "span", note: "the slot body; decorative, aria-hidden"],
          label: [
            element: "span",
            data_attributes: ["data-hidden"],
            note:
              "`show_labels={false}` hides it visually but keeps it for screen readers, which is " <>
                "what an icon-only dock should do"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Navigation landmark with aria-current=\"page\"",
        keyboard: ["Tab — move between destinations", "Enter — follow one"]
      ],
      state_attributes: ["data-active", "data-position", "data-contained", "data-hidden"],
      hooks: []
    ]
  ]
]
