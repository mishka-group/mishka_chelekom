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
        module: "Menu",
        type: "file",
        file: "menu.js",
        imports: "import Menu from \"./menu.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-disabled", "data-side", "data-align"],
          required: true
        ],
        parts: [
          trigger: [
            element: "button",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls"],
            data_attributes: ["data-popup-open", "data-pressed", "data-disabled"]
          ],
          popup: [
            element: "div",
            role: "menu",
            data_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-starting-style"]
          ],
          item: [
            element: "button",
            role: "menuitem",
            data_attributes: ["data-highlighted", "data-disabled"]
          ],
          checkbox_item: [
            element: "button",
            role: "menuitemcheckbox",
            aria: ["aria-checked"],
            data_attributes: ["data-checked", "data-unchecked", "data-highlighted", "data-disabled"]
          ],
          checkbox_item_indicator: [element: "span", aria: ["aria-hidden"], data_attributes: ["data-checked", "data-unchecked"]],
          radio_group: [element: "div", role: "group", aria: ["aria-labelledby"]],
          radio_item: [
            element: "button",
            role: "menuitemradio",
            aria: ["aria-checked"],
            data_attributes: ["data-value", "data-checked", "data-unchecked", "data-highlighted", "data-disabled"]
          ],
          radio_item_indicator: [element: "span", aria: ["aria-hidden"], data_attributes: ["data-checked", "data-unchecked"]],
          link_item: [element: "a", role: "menuitem", data_attributes: ["data-highlighted"]],
          group: [element: "div", role: "group", aria: ["aria-labelledby"]],
          group_label: [element: "div", role: "presentation"],
          separator: [element: "div", role: "separator", data_attributes: ["data-orientation"]],
          submenu_trigger: [
            element: "button",
            role: "menuitem",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls"],
            data_attributes: ["data-popup-open", "data-highlighted", "data-disabled"]
          ],
          submenu_popup: [
            element: "div",
            role: "menu",
            data_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-starting-style"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Menu Button",
        keyboard: [
          "Enter/Space/ArrowDown: open + focus first item",
          "ArrowUp: open + focus last item",
          "Down/Up: navigate",
          "Home/End: first/last",
          "Enter/Space: activate",
          "ArrowRight: open submenu",
          "ArrowLeft / Escape: close submenu / menu",
          "Type: typeahead"
        ],
        focus: "Focus moves into the popup on open; restored to the trigger on close."
      ],
      state_attributes: [
        "data-open",
        "data-closed",
        "data-side",
        "data-align",
        "data-highlighted",
        "data-checked",
        "data-unchecked",
        "data-disabled",
        "data-popup-open",
        "data-pressed",
        "data-starting-style"
      ],
      hooks: ["Menu"]
    ]
  ]
]
