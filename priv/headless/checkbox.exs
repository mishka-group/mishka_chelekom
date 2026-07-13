[
  checkbox: [
    name: "checkbox",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/checkbox",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/",
    args: [type: ["checkbox"], only: ["checkbox"], helpers: [], module: ""],
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
          element: "button",
          role: "checkbox",
          aria: ["aria-checked", "aria-readonly", "aria-required"],
          data_attributes: [
            "data-checked",
            "data-unchecked",
            "data-indeterminate",
            "data-disabled",
            "data-readonly",
            "data-required",
            "data-parent"
          ],
          required: true
        ],
        parts: [
          input: [element: "input", aria: ["aria-hidden"]],
          indicator: [
            element: "span",
            aria: ["aria-hidden"],
            data_attributes: ["data-checked", "data-unchecked", "data-indeterminate"]
          ],
          label: [element: "span"]
        ]
      ],
      aria_pattern: [
        pattern: "Checkbox",
        keyboard: ["Space: toggle checked", "Enter: toggle checked"]
      ],
      state_attributes: [
        "data-checked",
        "data-unchecked",
        "data-indeterminate",
        "data-disabled",
        "data-readonly",
        "data-required"
      ],
      hooks: ["Toggle", "CheckboxGroup"]
    ]
  ]
]
