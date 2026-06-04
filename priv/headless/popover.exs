[
  popover: [
    name: "popover",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["popover"], only: ["popover"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        trigger: [element: "button", aria: ["aria-expanded", "aria-controls"]],
        popup: [element: "div", role: "dialog", data_attributes: ["data-open", "data-closed", "data-side"]]
      ]
    ],
    aria_pattern: [pattern: "Disclosure + positioning", keyboard: ["Escape: close", "click outside: close"]],
    state_attributes: ["data-open", "data-closed", "data-side"],
    hooks: ["Popup"],
    scripts: [
      %{type: "file", file: "popup.js", module: "Popup", imports: "import Popup from \"./popup.js\";"}
    ]
  ]
]
