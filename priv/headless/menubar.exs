[
  menubar: [
    name: "menubar",
    category: "navigation",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/menubar/",
    args: [type: ["menubar"], only: ["menubar"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        menubar: [element: "div", role: "menubar", data_attributes: ["data-orientation"]],
        trigger: [element: "button", role: "menuitem", aria: ["aria-haspopup", "aria-expanded", "aria-controls"]],
        popup: [element: "div", role: "menu", data_attributes: ["data-open", "data-closed"]]
      ]
    ],
    aria_pattern: [
      pattern: "Menubar",
      keyboard: ["Left/Right: move between menus", "Home/End: first/last menu", "Enter/Space: open menu", "Escape: close menu"]
    ],
    state_attributes: ["data-open", "data-closed"],
    hooks: ["RovingTabindex", "Popup"],
    scripts: [
      %{
        type: "file",
        file: "roving_tabindex.js",
        module: "RovingTabindex",
        imports: "import RovingTabindex from \"./roving_tabindex.js\";"
      },
      %{
        type: "file",
        file: "popup.js",
        module: "Popup",
        imports: "import Popup from \"./popup.js\";"
      }
    ]
  ]
]
