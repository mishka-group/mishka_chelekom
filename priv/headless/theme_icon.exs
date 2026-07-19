[
  theme_icon: [
    name: "theme_icon",
    category: "data display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/theme_icon",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["theme_icon"], only: ["theme_icon"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "span",
          aria: ["aria-label", "aria-hidden"],
          note: "wraps an icon; decorative by default, or labelled with `label`",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Theme icon (no formal APG pattern)", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
