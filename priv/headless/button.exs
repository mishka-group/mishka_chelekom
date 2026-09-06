[
  button: [
    name: "button",
    category: "buttons",
    doc_url: "https://mishka.tools/chelekom/docs/headless/button",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/button/",
    args: [type: ["button"], only: ["button"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    headless: [
      anatomy: [
        root: [
          element: "button | a",
          role: "button",
          aria: ["aria-busy", "aria-disabled"],
          data_attributes: ["data-disabled", "data-loading"],
          note:
            "a `<button>` by default; `navigate`/`patch`/`href` render a link instead, which " <>
              "carries `aria-disabled` since anchors have no native disabled",
          required: true
        ],
        parts: [
          "start-icon": [element: "span", note: "optional `:start_icon` slot, before the label"],
          loader: [
            element: "span",
            note: "optional `:loader` slot, rendered only while `loading`"
          ],
          label: [element: "span", note: "the label; keeps its width while loading"],
          "end-icon": [element: "span", note: "optional `:end_icon` slot, after the label"]
        ]
      ],
      aria_pattern: [
        pattern: "Button",
        keyboard: ["Enter — activate", "Space — activate"]
      ],
      state_attributes: ["data-disabled", "data-loading"],
      hooks: []
    ]
  ]
]
