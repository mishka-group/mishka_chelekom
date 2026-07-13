[
  toggle_group: [
    name: "toggle_group",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/toggle-group",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/",
    args: [type: ["toggle_group"], only: ["toggle_group"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "ToggleGroup",
        type: "file",
        file: "toggle_group.js",
        imports: "import ToggleGroup from \"./toggle_group.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "group",
          aria: ["aria-orientation", "aria-disabled"],
          data_attributes: ["data-orientation", "data-multiple", "data-disabled"],
          note: "carries the ToggleGroup hook; reads name/multiple/orientation/loop from data-*",
          required: true
        ],
        parts: [
          item: [
            element: "button",
            role: "button",
            aria: ["aria-pressed", "aria-disabled"],
            data_attributes: ["data-pressed", "data-disabled", "data-value"]
          ],
          value_inputs: [
            element: "span",
            note: "hidden input(s) carrying the pressed value(s) for form submission"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Toolbar",
        keyboard: [
          "Arrow (along orientation): move focus between toggles (looping)",
          "Home / End: first / last toggle",
          "Enter / Space: toggle pressed state"
        ]
      ],
      state_attributes: ["data-pressed", "data-disabled", "data-orientation", "data-multiple"],
      hooks: ["ToggleGroup"]
    ]
  ]
]
