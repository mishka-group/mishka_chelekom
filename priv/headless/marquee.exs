[
  marquee: [
    name: "marquee",
    category: "data display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/marquee",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["marquee"], only: ["marquee"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [element: "div", note: "clips the overflow; you set overflow-hidden", required: true],
        parts: [
          track: [element: "div", note: "the moving track (apply your CSS keyframes animation here)"],
          group: [
            element: "div",
            note: "the content, rendered twice (second copy aria-hidden) for a seamless loop"
          ]
        ]
      ],
      aria_pattern: [pattern: "Marquee (no formal APG pattern)", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
