[
  scroll_area: [
    name: "scroll_area",
    category: "media",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["scroll_area"], only: ["scroll_area"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [parts: [viewport: [element: "div", note: "the scrollable, focusable viewport"]]],
      aria_pattern: [
        pattern: "Scroll area",
        keyboard: ["Arrow/PageUp/PageDown: scroll the focused viewport"]
      ],
      state_attributes: ["data-orientation"],
      hooks: []
    ]
  ]
]
