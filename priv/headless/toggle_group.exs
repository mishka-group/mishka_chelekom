[
  toggle_group: [
    name: "toggle_group",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/",
    args: [type: ["toggle_group"], only: ["toggle_group"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        root: [element: "div", role: "group", data_attributes: ["data-orientation"]],
        item: [
          element: "button",
          role: "button",
          aria: ["aria-pressed"],
          data_attributes: ["data-on", "data-off", "data-highlighted", "data-disabled", "data-value"]
        ]
      ]
    ],
    aria_pattern: [
      pattern: "Toolbar",
      keyboard: [
        "Left/Right: move focus between toggles",
        "Home: focus first toggle",
        "End: focus last toggle",
        "Enter/Space: toggle pressed state"
      ]
    ],
    state_attributes: ["data-on", "data-off", "data-highlighted", "data-orientation"],
    hooks: ["RovingTabindex", "Toggle"],
    scripts: [
      %{
        type: "file",
        file: "roving_tabindex.js",
        module: "RovingTabindex",
        imports: "import RovingTabindex from \"./roving_tabindex.js\";"
      },
      %{
        type: "file",
        file: "toggle.js",
        module: "Toggle",
        imports: "import Toggle from \"./toggle.js\";"
      }
    ]
  ]
]
