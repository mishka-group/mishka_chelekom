[
  navigation_menu: [
    name: "navigation_menu",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/navigation-menu",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/menubar/",
    args: [type: ["navigation_menu"], only: ["navigation_menu"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "NavigationMenu",
        type: "file",
        file: "navigation_menu.js",
        imports: "import NavigationMenu from \"./navigation_menu.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "nav",
          data_attributes: ["data-orientation"],
          note: "carries the NavigationMenu hook; reads value/delay/orientation/side/align from data-*",
          required: true
        ],
        parts: [
          list: [element: "ul"],
          item: [element: "li", data_attributes: ["data-value"]],
          link: [element: "a", aria: ["aria-current"], data_attributes: ["data-active"], note: "plain nav item"],
          trigger: [
            element: "button",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls"],
            data_attributes: ["data-popup-open", "data-value"]
          ],
          icon: [element: "span", data_attributes: ["data-open"]],
          content: [
            element: "div",
            data_attributes: ["data-activation-direction", "data-value"],
            note: "stored hidden; the active one is moved into the viewport and morphed"
          ],
          positioner: [
            element: "div",
            data_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-instant"],
            note: "exposes --positioner-width/height"
          ],
          popup: [
            element: "nav",
            data_attributes: ["data-open", "data-closed", "data-side", "data-align"],
            note: "exposes --popup-width/height (the morphing size)"
          ],
          viewport: [element: "div", note: "the active content lives here"],
          arrow: [element: "div", data_attributes: ["data-side", "data-align"]]
        ]
      ],
      aria_pattern: [
        pattern: "Navigation menu (menubar-like)",
        keyboard: [
          "Arrow (along orientation): move between triggers",
          "Cross-arrow / Enter / Space: open the menu",
          "Escape: close · Tab out: close"
        ]
      ],
      state_attributes: [
        "data-orientation",
        "data-open",
        "data-closed",
        "data-side",
        "data-align",
        "data-instant",
        "data-activation-direction",
        "data-popup-open",
        "data-active"
      ],
      hooks: ["NavigationMenu"]
    ]
  ]
]
