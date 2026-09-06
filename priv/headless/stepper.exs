[
  stepper: [
    name: "stepper",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/stepper",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/",
    args: [type: ["stepper"], only: ["stepper"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    headless: [
      anatomy: [
        root: [
          element: "ol",
          role: "list",
          aria: ["aria-label"],
          data_attributes: ["data-orientation", "data-orientation-from"],
          note: "ordered, because the order of a flow is the meaning",
          required: true
        ],
        parts: [
          step: [
            element: "li",
            aria: ["aria-current"],
            data_attributes: ["data-index", "data-state", "data-disabled"],
            note:
              "state is derived from the root's `active` index unless the step overrides it; the " <>
                "current one carries aria-current=\"step\""
          ],
          indicator: [
            element: "span",
            data_attributes: ["data-content"],
            note:
              "holds the step's own content (an icon, a checkmark) when given; otherwise the skin " <>
                "numbers it, and `content` overrides that number"
          ],
          content: [element: "span", note: "wraps label and description so the step stays a two-row grid"],
          label: [element: "span"],
          description: [element: "span"],
          action: [
            element: "button | a",
            aria: ["aria-labelledby"],
            note:
              "covers the whole step instead of wrapping it, so the step itself stays a plain " <>
                "grid container and the click target is still the entire step"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Ordered list with aria-current=\"step\"",
        keyboard: ["Tab — move to a selectable step", "Enter / Space — select it"]
      ],
      state_attributes: ["data-state", "data-orientation", "data-orientation-from", "data-index", "data-disabled"],
      hooks: []
    ]
  ]
]
