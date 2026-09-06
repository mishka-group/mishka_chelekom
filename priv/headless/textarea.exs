[
  textarea: [
    name: "textarea",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/textarea",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/textbox/",
    args: [type: ["textarea"], only: ["textarea"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        module: "Autosize",
        type: "file",
        file: "autosize.js",
        imports: "import Autosize from \"./autosize.js\";"
      }
    ],
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
            "data-required",
            "data-autosize"
          ],
          note:
            "the control box — a skin paints this and leaves the `<textarea>` transparent, so the " <>
              "resize handle does not cut across the border",
          required: true
        ],
        parts: [
          textarea: [
            element: "textarea",
            aria: ["aria-invalid", "aria-describedby"],
            note:
              "carries the Autosize hook only when `autosize` is set; takes its id/name/value " <>
                "from `field` when a `Phoenix.HTML.FormField` is given"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Textbox (multiline)",
        keyboard: ["Tab — focus", "Enter — newline", "Text entry is native"]
      ],
      state_attributes: [
        "data-invalid",
        "data-valid",
        "data-disabled",
        "data-readonly",
        "data-required",
        "data-autosize",
        "data-resize"
      ],
      hooks: ["Autosize"]
    ]
  ]
]
