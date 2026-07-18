[
  segmented_control: [
    name: "segmented_control",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/segmented_control",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/radio/",
    args: [type: ["segmented_control"], only: ["segmented_control"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "radiogroup",
          aria: ["aria-label"],
          data_attributes: ["data-disabled"],
          note: "a row of native radios; the selected look comes from :has(:checked) — no JS",
          required: true
        ],
        parts: [
          item: [element: "label", note: "one segment, wraps a visually-hidden radio"],
          input: [element: "input", note: "the native radio (Tab/Arrow keys select natively)"],
          label: [element: "span", note: "the visible segment label"]
        ]
      ],
      aria_pattern: [
        pattern: "Radio group (native)",
        keyboard: ["Arrow keys — move selection", "Tab — into/out of the group"]
      ],
      state_attributes: ["data-disabled"],
      hooks: []
    ]
  ]
]
