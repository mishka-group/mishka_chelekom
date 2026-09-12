[
  pagination: [
    name: "pagination",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/pagination",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/",
    args: [type: ["pagination"], only: ["pagination"], helpers: [], module: ""],
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
          data_attributes: ["data-total", "data-page"],
          note: "the page window is computed from `total`/`page`/`siblings`/`boundaries`",
          required: true
        ],
        parts: [
          list: [element: "ul"],
          item: [element: "li"],
          page: [
            element: "button | a | input",
            aria: ["aria-current", "aria-label"],
            data_attributes: ["data-page", "data-current"],
            note:
              "a button with `on_select`, a link with `href`, a radio with `name`; the current " <>
                "page is disabled rather than linking to where you already are"
          ],
          ellipsis: [element: "span", note: "aria-hidden; stands in for an elided run"],
          first: [element: "button | a", aria: ["aria-label"]],
          previous: [
            element: "button | a",
            aria: ["aria-label"],
            note: "disabled at the first page rather than wrapping round to the last"
          ],
          next: [element: "button | a", aria: ["aria-label"]],
          last: [element: "button | a", aria: ["aria-label"]]
        ]
      ],
      aria_pattern: [
        pattern: "Navigation landmark with aria-current=\"page\"",
        keyboard: ["Tab — move between controls", "Enter / Space — go to a page"]
      ],
      state_attributes: ["data-page", "data-current", "data-total"],
      hooks: []
    ]
  ]
]
