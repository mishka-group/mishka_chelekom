[
  breadcrumb: [
    name: "breadcrumb",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/breadcrumb",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/breadcrumb/",
    args: [type: ["breadcrumb"], only: ["breadcrumb"], helpers: [], module: ""],
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
          data_attributes: ["data-collapsed"],
          note: "a landmark, so the trail can be jumped to rather than tabbed through",
          required: true
        ],
        parts: [
          list: [element: "ol", note: "ordered, because the order of a trail carries meaning"],
          item: [element: "li", data_attributes: ["data-index"]],
          link: [
            element: "a | span",
            aria: ["aria-current"],
            note:
              "the current page renders as a span with aria-current, not a link — a link to the " <>
                "page you are on is a dead end that still takes a tab stop"
          ],
          separator: [element: "span", note: "aria-hidden, so the trail reads as words"],
          ellipsis: [
            element: "button | span",
            note: "stands in for the collapsed middle; a button when `on_expand` is given"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Breadcrumb",
        keyboard: ["Tab — move through the crumbs", "Enter — follow a crumb"]
      ],
      state_attributes: ["data-collapsed", "data-index", "aria-current"],
      hooks: []
    ]
  ]
]
