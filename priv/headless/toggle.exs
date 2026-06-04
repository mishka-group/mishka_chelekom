[
  toggle: [
    name: "toggle",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/button/",
    args: [
      type: ["toggle"],
      only: ["toggle"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        root: [element: "button", aria: ["aria-pressed"], data_attributes: ["data-on", "data-off"], required: true]
      ]
    ],
    aria_pattern: [
      pattern: "Button (Toggle)",
      keyboard: ["Enter: toggle pressed state", "Space: toggle pressed state"]
    ],
    state_attributes: ["data-on", "data-off"],
    hooks: ["Toggle"],
    scripts: [
      %{
        type: "file",
        file: "toggle.js",
        module: "Toggle",
        imports: "import Toggle from \"./toggle.js\";"
      }
    ]
  ]
]
