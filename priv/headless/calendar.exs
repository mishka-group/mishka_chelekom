[
  calendar: [
    name: "calendar",
    category: "forms",
    doc_url: "",
    args: [
      type: ["calendar"],
      only: ["calendar"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    anatomy: [
      parts: [
        input: [element: "input"],
        header: [element: "div"],
        prev: [element: "button", aria: ["aria-label"]],
        label: [element: "div", aria: ["aria-live"]],
        next: [element: "button", aria: ["aria-label"]],
        grid: [element: "div", role: "grid", aria: ["aria-labelledby"]],
        weekdays: [element: "div", role: "row"],
        row: [element: "div", role: "row"],
        day: [
          element: "button",
          role: "gridcell",
          aria: ["aria-selected"],
          data_attributes: ["data-date", "data-today", "data-selected", "data-disabled"]
        ]
      ]
    ],
    aria_pattern: [
      pattern: "Date Grid",
      keyboard: [
        "ArrowLeft/Right: ±1 day",
        "ArrowUp/Down: ±1 week",
        "Home/End: week start/end",
        "PageUp/PageDown: ±1 month",
        "Enter/Space: select"
      ]
    ],
    state_attributes: ["data-selected", "data-today", "data-disabled"],
    hooks: ["DateGrid"],
    scripts: [
      %{
        type: "file",
        file: "date_grid.js",
        module: "DateGrid",
        imports: "import DateGrid from \"./date_grid.js\";"
      }
    ]
  ]
]
