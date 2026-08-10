[
  file_input: [
    name: "file_input",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/file_input",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/textbox/",
    args: [type: ["file_input"], only: ["file_input"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    headless: [
      anatomy: [
        root: [
          element: "input",
          role: "none",
          aria: ["aria-invalid", "aria-describedby"],
          data_attributes: ["data-invalid", "data-disabled"],
          note:
            "the input *is* the root — `::file-selector-button` only exists on the input, so a " <>
              "wrapper would put the browser's own button out of reach of the skin",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [
        pattern: "Native file picker",
        keyboard: ["Tab — focus", "Enter / Space — open the picker"]
      ],
      state_attributes: ["data-invalid", "data-disabled"],
      hooks: []
    ]
  ]
]
