[
  context_menu: [
    name: "context_menu",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/menu/",
    args: [type: ["context_menu"], only: ["context_menu"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        trigger: [element: "div", data_attributes: ["data-part"]],
        popup: [element: "div", role: "menu", data_attributes: ["data-open", "data-closed", "data-side"]],
        item: [element: "button", role: "menuitem", data_attributes: ["data-highlighted", "data-disabled"]]
      ]
    ],
    aria_pattern: [pattern: "Menu", keyboard: ["Down/Up: navigate", "Home/End: first/last", "Escape: close", "Enter/Space: activate"]],
    state_attributes: ["data-open", "data-closed", "data-highlighted", "data-disabled"],
    hooks: ["Popup", "RovingTabindex"],
    scripts: [
      %{type: "file", file: "popup.js", module: "Popup", imports: "import Popup from \"./popup.js\";"},
      %{type: "file", file: "roving_tabindex.js", module: "RovingTabindex", imports: "import RovingTabindex from \"./roving_tabindex.js\";"}
    ]
  ]
]
