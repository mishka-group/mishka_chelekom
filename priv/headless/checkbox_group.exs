[
  checkbox_group: [
    name: "checkbox_group",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/",
    args: [type: ["checkbox_group"], only: ["checkbox_group"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Toggle",
        type: "file",
        file: "toggle.js",
        imports: "import Toggle from \"./toggle.js\";"
      },
      %{
        module: "CheckboxGroup",
        type: "file",
        file: "checkbox_group.js",
        imports: "import CheckboxGroup from \"./checkbox_group.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "group",
          aria: ["aria-labelledby"],
          data_attributes: ["data-disabled"],
          required: true
        ],
        parts: [
          label: [element: "span", note: "visible group label wired to aria-labelledby"],
          item: [
            element: "button",
            role: "checkbox",
            aria: ["aria-checked"],
            data_attributes: [
              "data-checked",
              "data-unchecked",
              "data-indeterminate",
              "data-disabled",
              "data-parent"
            ],
            note: "a select_all item carries data-parent (the tristate \"select all\")"
          ],
          indicator: [
            element: "span",
            aria: ["aria-hidden"],
            data_attributes: ["data-checked", "data-unchecked", "data-indeterminate"]
          ],
          input: [element: "input", note: "hidden native checkbox; submits as name[]"]
        ]
      ],
      aria_pattern: [
        pattern: "Checkbox",
        keyboard: [
          "Space/Enter: toggle the focused checkbox",
          "Tab: move between checkboxes",
          "Toggling the select_all parent checks/unchecks every item"
        ]
      ],
      state_attributes: ["data-checked", "data-unchecked", "data-indeterminate", "data-disabled"],
      hooks: ["Toggle", "CheckboxGroup"]
    ]
  ]
]
