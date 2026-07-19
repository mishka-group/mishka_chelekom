[
  overflow_list: [
    name: "overflow_list",
    category: "data",
    doc_url: "https://mishka.tools/chelekom/docs/headless/overflow_list",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["overflow_list"], only: ["overflow_list"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "OverflowList", type: "file", file: "overflow_list.js", imports: "import OverflowList from \"./overflow_list.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-min-visible", "data-on-change"],
          note: "carries the OverflowList hook; a ResizeObserver re-runs the layout on resize",
          required: true
        ],
        parts: [
          item: [
            element: "span",
            note: "one list item; overflow sets data-hidden + inert (out of tab order and a11y tree)"
          ],
          counter: [element: "span", note: "the '+N' element; gets data-hidden when nothing overflows"],
          "counter-value": [element: "span", note: "receives the hidden count as text"]
        ]
      ],
      aria_pattern: [pattern: "Overflow list (no formal APG pattern)", keyboard: []],
      state_attributes: ["data-hidden"],
      hooks: ["OverflowList"]
    ]
  ]
]
