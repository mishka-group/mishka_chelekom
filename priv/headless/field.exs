[
  field: [
    name: "field",
    category: "forms",
    doc_url: "",
    args: [type: ["field"], only: ["field"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Field",
        type: "file",
        file: "field.js",
        imports: "import Field from \"./field.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: [
            "data-disabled",
            "data-invalid",
            "data-touched",
            "data-dirty",
            "data-filled",
            "data-focused"
          ],
          note: "carries the Field hook; reflects validity (server) + interaction (client) state",
          required: true
        ],
        parts: [
          label: [element: "label", note: "for points at the derived control id"],
          control: [
            element: "div",
            note: "wraps the caller's control; the Field hook tracks the input inside it. The control is handed the derived id/name/aria-describedby/aria-invalid/disabled via the slot :let map"
          ],
          description: [element: "p", note: "its id is folded into the control's aria-describedby"],
          error: [
            element: "p",
            note: "one per error message; each gets a stable id-error-N id folded into aria-describedby"
          ]
        ]
      ],
      aria_pattern: [pattern: "Form Field (no formal APG pattern)", keyboard: []],
      state_attributes: [
        "data-disabled",
        "data-invalid",
        "data-touched",
        "data-dirty",
        "data-filled",
        "data-focused"
      ],
      hooks: ["Field"]
    ]
  ]
]
