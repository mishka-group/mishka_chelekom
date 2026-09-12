[
  fab: [
    name: "fab",
    category: "buttons",
    doc_url: "https://mishka.tools/chelekom/docs/headless/fab",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/",
    args: [type: ["fab"], only: ["fab"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
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
        root: [
          element: "div",
          role: "none",
          aria: [],
          data_attributes: ["data-placement", "data-direction", "data-contained"],
          note:
            "reuses the shared Popup engine, so Escape and an outside click close the dial and " <>
              "the trigger reports aria-expanded — none of which daisyUI's :focus-within can do",
          required: true
        ],
        parts: [
          trigger: [
            element: "button",
            aria: ["aria-label", "aria-haspopup", "aria-expanded", "aria-controls"],
            note:
              "a real button, not daisyUI's `div[tabindex=0][role=button]`: that is not a button " <>
                "to assistive tech and cannot be activated with Space"
          ],
          popup: [
            element: "div",
            role: "menu",
            data_attributes: ["data-open", "data-closed"],
            note: "not rendered at all when there are no actions — a lone FAB is just a button"
          ],
          action: [
            element: "button | a",
            role: "menuitem",
            aria: ["aria-label"],
            data_attributes: ["data-index", "data-disabled"]
          ],
          "main-action": [
            element: "button | a",
            role: "menuitem",
            note: "daisyUI's `fab-main-action` — replaces the trigger's meaning while open"
          ],
          label: [element: "span", note: "aria-hidden; the action's aria-label already carries it"]
        ]
      ],
      aria_pattern: [
        pattern: "Menu Button",
        keyboard: [
          "Enter / Space — open the dial",
          "Escape — close it",
          "Tab — move through the actions"
        ]
      ],
      state_attributes: ["data-open", "data-closed", "data-direction", "data-placement"],
      hooks: ["Popup"]
    ]
  ]
]
