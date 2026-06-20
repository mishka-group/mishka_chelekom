[
  menu: [
    name: "menu",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/",
    args: [type: ["menu"], only: ["menu"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Popup",
        type: "file",
        file: "popup.js",
        imports: "import Popup from \"./popup.js\";"
      },
      %{
        module: "RovingTabindex",
        type: "file",
        file: "roving_tabindex.js",
        imports: "import RovingTabindex from \"./roving_tabindex.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          trigger: [element: "button", aria: ["aria-haspopup", "aria-expanded", "aria-controls"]],
          popup: [element: "div", role: "menu", data_attributes: ["data-open", "data-closed"]],
          item: [
            element: "button",
            role: "menuitem",
            data_attributes: ["data-highlighted", "data-disabled"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Menu Button",
        keyboard: ["Down/Up: navigate", "Escape: close", "Enter: activate"]
      ],
      state_attributes: ["data-open", "data-closed", "data-highlighted"],
      hooks: ["Popup", "RovingTabindex"]
    ]
  ]
]
