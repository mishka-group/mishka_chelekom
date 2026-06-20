[
  navigation_menu: [
    name: "navigation_menu",
    category: "navigation",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/",
    args: [type: ["navigation_menu"], only: ["navigation_menu"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Popup",
        type: "file",
        file: "popup.js",
        imports: "import Popup from \"./popup.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          root: [element: "nav"],
          link: [element: "a", note: "plain nav item without a panel"],
          trigger: [element: "button", aria: ["aria-haspopup", "aria-expanded", "aria-controls"]],
          popup: [
            element: "div",
            role: "menu",
            aria: ["aria-label"],
            data_attributes: ["data-open", "data-closed"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Disclosure",
        keyboard: ["Enter/Space: toggle panel", "Escape: close"]
      ],
      state_attributes: ["data-open", "data-closed"],
      hooks: ["Popup"]
    ]
  ]
]
