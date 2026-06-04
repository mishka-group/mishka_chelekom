[
  collapsible: [
    name: "collapsible",
    category: "disclosure",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/",
    args: [type: ["collapsible"], only: ["collapsible"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        trigger: [element: "button", aria: ["aria-expanded", "aria-controls"]],
        panel: [element: "div", role: "region", aria: ["aria-labelledby"], data_attributes: ["data-open", "data-closed"]]
      ]
    ],
    aria_pattern: [pattern: "Disclosure", keyboard: ["Enter/Space: toggle"]],
    state_attributes: ["data-open", "data-closed"],
    hooks: ["Disclosure"],
    scripts: [
      %{type: "file", file: "disclosure.js", module: "Disclosure", imports: "import Disclosure from \"./disclosure.js\";"}
    ]
  ]
]
