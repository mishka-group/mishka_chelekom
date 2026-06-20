[
  switch: [
    name: "switch",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/switch/",
    args: [type: ["switch"], only: ["switch"], helpers: [], module: ""],
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
          role: "switch",
          aria: ["aria-checked", "aria-labelledby"],
          data_attributes: ["data-checked", "data-unchecked"],
          required: true
        ],
        parts: [input: [element: "input"], thumb: [element: "span"], label: [element: "span"]]
      ],
      aria_pattern: [pattern: "Switch", keyboard: ["Enter: toggle", "Space: toggle"]],
      state_attributes: ["data-checked", "data-unchecked"],
      hooks: ["Toggle"]
    ]
  ]
]
