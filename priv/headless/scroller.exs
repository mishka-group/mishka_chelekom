[
  scroller: [
    name: "scroller",
    category: "layout",
    doc_url: "https://mishka.tools/chelekom/docs/headless/scroller",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["scroller"], only: ["scroller"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "Scroller", type: "file", file: "scroller.js", imports: "import Scroller from \"./scroller.js\";"}
    ],
    headless: [
      anatomy: [
        root: [element: "div", note: "carries the Scroller hook", required: true],
        parts: [
          prev: [element: "button", aria: ["aria-label"], data_attributes: ["data-disabled"], note: "scroll back"],
          viewport: [element: "div", note: "the horizontally scrollable region (overflow-x auto)"],
          next: [element: "button", aria: ["aria-label"], data_attributes: ["data-disabled"], note: "scroll forward"]
        ]
      ],
      aria_pattern: [pattern: "Scroller (no formal APG pattern)", keyboard: []],
      state_attributes: ["data-disabled"],
      hooks: ["Scroller"]
    ]
  ]
]
