[
  avatar: [
    name: "avatar",
    category: "media",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["avatar"], only: ["avatar"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        parts: [
          image: [element: "img", aria: ["alt"]],
          fallback: [element: "span", aria: ["aria-hidden"]]
        ]
      ],
      aria_pattern: [pattern: "Avatar (no formal APG pattern)", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
