[
  text_input: [
    name: "text_input",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/text_input",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/textbox/",
    args: [type: ["text_input"], only: ["text_input"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "none",
          aria: [],
          data_attributes: [
            "data-invalid",
            "data-valid",
            "data-disabled",
            "data-readonly",
            "data-required"
          ],
          note:
            "the control box — a skin paints this and leaves the `<input>` transparent, which is " <>
              "what lets a leading section sit inside the border",
          required: true
        ],
        parts: [
          "start-section": [element: "span", note: "leading content inside the control"],
          input: [
            element: "input",
            aria: ["aria-invalid", "aria-describedby"],
            note:
              "takes its id/name/value from `field` when a `Phoenix.HTML.FormField` is given, " <>
                "otherwise from `name`/`value`"
          ],
          "end-section": [element: "span", note: "trailing content inside the control"]
        ]
      ],
      aria_pattern: [
        pattern: "Textbox",
        keyboard: ["Tab — focus", "Text entry is native"]
      ],
      state_attributes: [
        "data-invalid",
        "data-valid",
        "data-disabled",
        "data-readonly",
        "data-required"
      ],
      hooks: []
    ]
  ]
]
