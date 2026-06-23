[
  radio: [
    name: "radio",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/radio/",
    args: [type: ["radio"], only: ["radio"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "Radio", type: "file", file: "radio.js", imports: "import Radio from \"./radio.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "label",
          data_attributes: [
            "data-checked",
            "data-unchecked",
            "data-disabled",
            "data-readonly",
            "data-required"
          ],
          note: "carries the Radio hook; reflects checked/disabled/readonly/required",
          required: true
        ],
        parts: [
          input: [element: "input", note: "native radio input (grouping, keyboard, form value)"],
          indicator: [
            element: "span",
            data_attributes: ["data-checked", "data-unchecked"],
            note: "selection dot — shown via data-checked"
          ],
          label: [element: "span"]
        ]
      ],
      aria_pattern: [
        pattern: "Radio (native semantics)",
        keyboard: ["Arrow keys: move + select within the name group", "Space: select"]
      ],
      state_attributes: [
        "data-checked",
        "data-unchecked",
        "data-disabled",
        "data-readonly",
        "data-required"
      ],
      hooks: ["Radio"]
    ]
  ]
]
