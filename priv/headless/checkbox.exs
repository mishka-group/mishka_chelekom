[
  checkbox: [
    name: "checkbox",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/",
    args: [type: ["checkbox"], only: ["checkbox"], helpers: [], module: ""],
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
        root: [
          element: "button",
          role: "checkbox",
          aria: ["aria-checked"],
          data_attributes: ["data-checked", "data-unchecked", "data-disabled"],
          required: true
        ],
        parts: [
          input: [element: "input", aria: ["aria-hidden"]],
          indicator: [element: "span", aria: ["aria-hidden"]],
          label: [element: "span"]
        ]
      ],
      aria_pattern: [
        pattern: "Checkbox",
        keyboard: ["Space: toggle checked", "Enter: toggle checked"]
      ],
      state_attributes: ["data-checked", "data-unchecked", "data-disabled"],
      hooks: ["Toggle"]
    ]
  ]
]
