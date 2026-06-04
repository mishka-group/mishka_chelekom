[
  select: [
    name: "select",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/combobox/",
    args: [type: ["select"], only: ["select"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        trigger: [element: "button", role: "combobox", aria: ["aria-haspopup", "aria-expanded", "aria-controls"]],
        popup: [element: "ul", role: "listbox", data_attributes: ["data-open", "data-closed"]],
        option: [element: "li", role: "option", aria: ["aria-selected"], data_attributes: ["data-highlighted"]],
        hidden_input: [element: "input", note: "carries the value for form submission"]
      ]
    ],
    aria_pattern: [pattern: "Listbox / Combobox", keyboard: ["Down/Up: navigate", "Home/End", "Escape: close"]],
    state_attributes: ["data-open", "data-closed", "data-highlighted"],
    hooks: ["Popup", "RovingTabindex"],
    scripts: [
      %{type: "file", file: "popup.js", module: "Popup", imports: "import Popup from \"./popup.js\";"},
      %{type: "file", file: "roving_tabindex.js", module: "RovingTabindex", imports: "import RovingTabindex from \"./roving_tabindex.js\";"}
    ]
  ]
]
