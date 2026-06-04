[
  number_field: [
    name: "number_field",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/spinbutton/",
    args: [
      type: ["number_field"],
      only: ["number_field"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        decrement: [element: "button", aria: ["aria-label"]],
        input: [element: "input", role: "spinbutton", aria: ["aria-valuemin", "aria-valuemax", "aria-valuenow"]],
        increment: [element: "button", aria: ["aria-label"]]
      ]
    ],
    aria_pattern: [
      pattern: "Spinbutton",
      keyboard: ["ArrowUp: increment", "ArrowDown: decrement", "PageUp: +10·step", "PageDown: -10·step"]
    ],
    state_attributes: ["aria-valuemin", "aria-valuemax", "aria-valuenow"],
    hooks: ["NumberScrub"],
    scripts: [
      %{
        type: "file",
        file: "number_scrub.js",
        module: "NumberScrub",
        imports: "import NumberScrub from \"./number_scrub.js\";"
      }
    ]
  ]
]
