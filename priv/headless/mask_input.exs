[
  mask_input: [
    name: "mask_input",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/mask_input",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["mask_input"], only: ["mask_input"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "MaskInput", type: "file", file: "mask_input.js", imports: "import MaskInput from \"./mask_input.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "input",
          data_attributes: ["data-mask"],
          note: "carries the MaskInput hook; data-mask is the pattern (9=digit, a=letter, *=alphanumeric, others literal)",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [
        pattern: "Text field with input masking (no formal APG pattern)",
        keyboard: ["Type: characters are formatted to the mask as you go"]
      ],
      state_attributes: ["data-mask"],
      hooks: ["MaskInput"]
    ]
  ]
]
