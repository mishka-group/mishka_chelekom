[
  fieldset: [
    name: "fieldset",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/fieldset",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["fieldset"], only: ["fieldset"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "fieldset",
          aria: ["aria-labelledby"],
          data_attributes: ["data-disabled"],
          note: "native <fieldset>; `disabled` natively disables every descendant control",
          required: true
        ],
        parts: [
          legend: [
            element: "div",
            data_attributes: ["data-disabled"],
            note: "styleable group label (a <div>, not native <legend>) wired via aria-labelledby"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Fieldset (grouping via <fieldset> + an aria-labelledby legend)",
        keyboard: []
      ],
      state_attributes: ["data-disabled"],
      hooks: []
    ]
  ]
]
