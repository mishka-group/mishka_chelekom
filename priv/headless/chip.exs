[
  chip: [
    name: "chip",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/chip",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/checkbox/",
    args: [type: ["chip"], only: ["chip"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "label",
          data_attributes: ["data-disabled"],
          note: "wraps a real input; reflect the checked look with :has(:checked) — no JS",
          required: true
        ],
        parts: [
          input: [
            element: "input",
            note: "the native checkbox/radio; visually hide it and drive styling from :checked"
          ],
          label: [element: "span", note: "the visible pill content"]
        ]
      ],
      aria_pattern: [
        pattern: "Checkbox / Radio (native input)",
        keyboard: ["Space — toggle", "Tab — move between chips"]
      ],
      state_attributes: ["data-disabled"],
      hooks: []
    ]
  ]
]
