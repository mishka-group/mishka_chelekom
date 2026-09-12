[
  table: [
    name: "table",
    category: "data-display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/table",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/table/",
    args: [type: ["table"], only: ["table"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        module: "Indeterminate",
        type: "file",
        file: "indeterminate.js",
        imports: "import Indeterminate from \"./indeterminate.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "table",
          role: "table",
          aria: [],
          data_attributes: ["data-sort-by", "data-sort-dir"],
          required: true
        ],
        parts: [
          caption: [
            element: "caption",
            data_attributes: ["data-hidden"],
            note: "names the table; hidden visually by default but always there for a reader"
          ],
          head: [element: "thead"],
          header: [
            element: "th",
            aria: ["aria-sort"],
            data_attributes: ["data-sortable", "data-align"],
            note: "`scope=\"col\"`; only the sorted column carries aria-sort"
          ],
          sort: [
            element: "button",
            data_attributes: ["data-dir"],
            note: "activating the sorted column reverses it; any other starts ascending"
          ],
          body: [element: "tbody"],
          row: [element: "tr", data_attributes: ["data-selected"]],
          cell: [
            element: "td | th",
            data_attributes: ["data-align"],
            note: "a `row_header` column renders `<th scope=\"row\">`, which names the row"
          ],
          select: [element: "input", aria: ["aria-label"]],
          "select-all": [
            element: "input",
            data_attributes: ["data-indeterminate"],
            note: "tri-state; the middle state is a DOM property, set by the Indeterminate hook"
          ],
          empty: [element: "td", note: "spans every column when there are no rows"],
          foot: [element: "tfoot"]
        ]
      ],
      aria_pattern: [
        pattern: "Table",
        keyboard: ["Tab — reach the sort buttons and checkboxes", "Enter / Space — activate them"]
      ],
      state_attributes: ["data-sort-by", "data-sort-dir", "data-selected", "data-indeterminate"],
      hooks: ["Indeterminate"]
    ]
  ]
]
