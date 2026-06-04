[
  toolbar: [
    name: "toolbar",
    category: "navigation",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/",
    args: [
      type: ["toolbar"],
      only: ["toolbar"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        item: [element: "button", data_attributes: ["data-disabled", "data-highlighted"]]
      ]
    ],
    aria_pattern: [
      pattern: "Toolbar",
      keyboard: [
        "Left/Right: move focus (horizontal)",
        "Up/Down: move focus (vertical)",
        "Home: first item",
        "End: last item",
        "Tab: move out of the toolbar"
      ]
    ],
    state_attributes: ["data-disabled", "data-highlighted"],
    hooks: ["RovingTabindex"],
    scripts: [
      %{
        type: "file",
        file: "roving_tabindex.js",
        module: "RovingTabindex",
        imports: "import RovingTabindex from \"./roving_tabindex.js\";"
      }
    ]
  ]
]
