[
  rating: [
    name: "rating",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/rating",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/radio/",
    args: [type: ["rating"], only: ["rating"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        module: "RadioGroup",
        type: "file",
        file: "radio_group.js",
        imports: "import RadioGroup from \"./radio_group.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "radiogroup",
          aria: ["aria-label", "aria-readonly"],
          data_attributes: ["data-orientation", "data-disabled", "data-precision"],
          note:
            "a rating is a single choice from an ordered set, so it reuses the RadioGroup engine " <>
              "rather than inventing a widget; a hidden input carries the value into a form",
          required: true
        ],
        parts: [
          item: [
            element: "button",
            role: "radio",
            aria: ["aria-checked", "aria-label"],
            data_attributes: ["data-value", "data-half", "data-checked", "data-clear"],
            note:
              "one per star at precision 1.0, two half-width ones per star at 0.5; siblings, so a " <>
                "stylesheet can fill every star up to the chosen one with `:has(~ …)` and no JS"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Radio Group",
        keyboard: [
          "Arrow Right / Down — next star (selects)",
          "Arrow Left / Up — previous star (selects)",
          "Home / End — first / last",
          "Space / Enter — select the focused star"
        ]
      ],
      state_attributes: ["data-checked", "data-unchecked", "data-half", "data-precision"],
      hooks: ["RadioGroup"]
    ]
  ]
]
