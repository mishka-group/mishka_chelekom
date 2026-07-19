[
  tags_input: [
    name: "tags_input",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/tags_input",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["tags_input"], only: ["tags_input"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-disabled"],
          note: "the control; clicking anywhere focuses the input via JS.focus (no JS hook)",
          required: true
        ],
        parts: [
          tag: [
            element: "span",
            note: "one token — holds its label, a remove button and a hidden list input"
          ],
          remove: [
            element: "button",
            aria: ["aria-label"],
            note: "removes the tag; fires on_remove with phx-value-tag"
          ],
          input: [
            element: "input",
            note: "the draft field; add on Enter via a wrapping form phx-submit or on_add (phx-keydown)"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Tags input (text field + removable tokens)",
        keyboard: ["Enter — add the draft", "Click ✕ — remove a tag"]
      ],
      state_attributes: ["data-disabled"],
      hooks: []
    ]
  ]
]
