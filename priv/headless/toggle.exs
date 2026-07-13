[
  toggle: [
    name: "toggle",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/toggle",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/button/",
    args: [type: ["toggle"], only: ["toggle"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Toggle",
        type: "file",
        file: "toggle.js",
        imports: "import Toggle from \"./toggle.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          root: [
            element: "button",
            aria: ["aria-pressed"],
            data_attributes: ["data-pressed", "data-disabled"],
            required: true
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Button (Toggle)",
        keyboard: ["Enter: toggle pressed state", "Space: toggle pressed state"]
      ],
      state_attributes: ["data-pressed", "data-disabled"],
      hooks: ["Toggle"]
    ]
  ]
]
