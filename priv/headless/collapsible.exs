[
  collapsible: [
    name: "collapsible",
    category: "disclosure",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/",
    args: [type: ["collapsible"], only: ["collapsible"], helpers: [], module: ""],
    optional: ["disabled", "hidden_until_found", "value", "on_open_change"],
    necessary: [],
    anatomy: [
      parts: [
        item: [element: "div", data_attributes: ["data-value", "data-open", "data-disabled", "data-on-open-change"]],
        trigger: [
          element: "button",
          aria: ["aria-expanded", "aria-controls", "aria-disabled"],
          data_attributes: ["data-disabled", "data-panel-open"]
        ],
        panel: [
          element: "div",
          role: "region",
          aria: ["aria-labelledby"],
          data_attributes: [
            "data-open",
            "data-closed",
            "data-disabled",
            "data-starting-style",
            "data-ending-style"
          ],
          css_vars: ["--accordion-panel-height", "--accordion-panel-width"],
          note: ~s|closed panel carries `hidden` (or `hidden="until-found"`) when kept mounted|
        ]
      ]
    ],
    aria_pattern: [pattern: "Disclosure", keyboard: ["Enter/Space: toggle"]],
    state_attributes: [
      "data-open",
      "data-closed",
      "data-disabled",
      "data-panel-open",
      "data-starting-style",
      "data-ending-style"
    ],
    hooks: ["Disclosure"],
    scripts: [
      %{type: "file", file: "disclosure.js", module: "Disclosure", imports: "import Disclosure from \"./disclosure.js\";"}
    ]
  ]
]
