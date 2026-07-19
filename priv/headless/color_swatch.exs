[
  color_swatch: [
    name: "color_swatch",
    category: "data display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/color_swatch",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["color_swatch"], only: ["color_swatch"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "span",
          role: "img",
          aria: ["aria-label"],
          note: "shows a color; the value is set inline, size/shape are yours",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Color swatch (no formal APG pattern)", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
