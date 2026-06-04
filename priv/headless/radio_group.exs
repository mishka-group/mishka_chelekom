[
  radio_group: [
    name: "radio_group",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/radio/",
    args: [type: ["radio_group"], only: ["radio_group"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        root: [element: "div", role: "radiogroup", aria: ["aria-orientation"]],
        item: [element: "button", role: "radio", aria: ["aria-checked"], data_attributes: ["data-highlighted"]],
        hidden_input: [element: "input", note: "carries the value for form submission"]
      ]
    ],
    aria_pattern: [pattern: "Radio Group", keyboard: ["Down/Right: next + select", "Up/Left: previous + select", "Home/End: first/last", "Space/Enter: select"]],
    state_attributes: ["data-highlighted", "aria-checked"],
    hooks: ["RovingTabindex"],
    scripts: [
      %{type: "file", file: "roving_tabindex.js", module: "RovingTabindex", imports: "import RovingTabindex from \"./roving_tabindex.js\";"}
    ]
  ]
]
