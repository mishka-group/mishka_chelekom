[
  radio_group: [
    name: "radio_group",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/radio/",
    args: [type: ["radio_group"], only: ["radio_group"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "RovingTabindex",
        type: "file",
        file: "roving_tabindex.js",
        imports: "import RovingTabindex from \"./roving_tabindex.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "radiogroup",
          aria: ["aria-orientation", "aria-disabled", "aria-readonly", "aria-required"],
          data_attributes: ["data-disabled"]
        ],
        parts: [
          item: [
            element: "button",
            role: "radio",
            aria: ["aria-checked", "aria-disabled"],
            data_attributes: ["data-checked", "data-unchecked", "data-disabled", "data-highlighted"]
          ],
          hidden_input: [element: "input", note: "carries the value (+ required) for form submission"]
        ]
      ],
      aria_pattern: [
        pattern: "Radio Group",
        keyboard: [
          "Down/Right: next + select",
          "Up/Left: previous + select",
          "Home/End: first/last",
          "Space/Enter: select"
        ]
      ],
      state_attributes: ["data-checked", "data-unchecked", "data-disabled", "data-highlighted"],
      hooks: ["RovingTabindex"]
    ]
  ]
]
