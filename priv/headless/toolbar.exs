[
  toolbar: [
    name: "toolbar",
    category: "navigation",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/",
    args: [type: ["toolbar"], only: ["toolbar"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Toolbar",
        type: "file",
        file: "toolbar.js",
        imports: "import Toolbar from \"./toolbar.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "toolbar",
          aria: ["aria-orientation", "aria-disabled"],
          data_attributes: ["data-orientation", "data-disabled"],
          note: "carries the Toolbar hook; reads orientation/loop/disabled/focusable from data-*",
          required: true
        ],
        parts: [
          button: [
            element: "button",
            data_attributes: ["data-orientation", "data-disabled", "data-focusable"]
          ],
          link: [element: "a", data_attributes: ["data-orientation"]],
          input: [
            element: "input",
            data_attributes: ["data-orientation", "data-disabled", "data-focusable"]
          ],
          group: [
            element: "div",
            role: "group",
            aria: ["aria-label"],
            data_attributes: ["data-orientation", "data-disabled"]
          ],
          separator: [element: "div", role: "separator", data_attributes: ["data-orientation"]]
        ]
      ],
      aria_pattern: [
        pattern: "Toolbar",
        keyboard: [
          "Arrow (along orientation): move focus (looping)",
          "Home / End: first / last item",
          "Tab: move out of the toolbar",
          "Inputs keep their own cursor movement; navigate at the boundaries"
        ]
      ],
      state_attributes: ["data-orientation", "data-disabled", "data-focusable"],
      hooks: ["Toolbar"]
    ]
  ]
]
