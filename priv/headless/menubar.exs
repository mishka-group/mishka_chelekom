[
  menubar: [
    name: "menubar",
    category: "navigation",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/menubar/",
    args: [type: ["menubar"], only: ["menubar"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Menubar",
        type: "file",
        file: "menubar.js",
        imports: "import Menubar from \"./menubar.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "menubar",
          aria: ["aria-orientation", "aria-disabled"],
          data_attributes: ["data-orientation", "data-modal", "data-has-submenu-open", "data-disabled"],
          note: "carries the Menubar hook; reads orientation/loop/modal/disabled from data-*",
          required: true
        ],
        parts: [
          menu: [element: "div", note: "wraps one trigger + its popup"],
          trigger: [
            element: "button",
            role: "menuitem",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls", "aria-disabled"],
            data_attributes: ["data-popup-open", "data-pressed", "data-disabled"]
          ],
          popup: [
            element: "div",
            role: "menu",
            aria: ["aria-label"],
            data_attributes: ["data-open", "data-closed"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Menubar",
        keyboard: [
          "Arrow (along orientation): move between menus (switches the open menu)",
          "Home/End: first/last menu",
          "Enter/Space/cross-arrow: open menu · Escape: close",
          "Arrow Up/Down: move between items in an open menu"
        ]
      ],
      state_attributes: [
        "data-orientation",
        "data-modal",
        "data-has-submenu-open",
        "data-disabled",
        "data-open",
        "data-closed",
        "data-popup-open",
        "data-pressed"
      ],
      hooks: ["Menubar"]
    ]
  ]
]
