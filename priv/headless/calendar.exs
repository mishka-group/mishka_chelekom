[
  calendar: [
    name: "calendar",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/calendar",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/grid/",
    args: [type: ["calendar"], only: ["calendar"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        module: "Calendar",
        type: "file",
        file: "calendar.js",
        imports: "import Calendar from \"./calendar.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "none",
          aria: [],
          data_attributes: ["data-month", "data-mode", "data-on-select", "data-on-month-change"],
          note:
            "the grid is Date arithmetic in Elixir, so the month is right before the socket " <>
              "connects; the hook only moves focus, which a server cannot do",
          required: true
        ],
        parts: [
          header: [element: "div"],
          previous: [
            element: "button",
            aria: ["aria-label"],
            note: "disabled when `min` puts the previous month out of range"
          ],
          next: [element: "button", aria: ["aria-label"]],
          heading: [element: "div", aria: ["aria-live"], note: "announces the month as it changes"],
          grid: [element: "table", role: "grid", aria: ["aria-labelledby", "aria-label"]],
          weekday: [element: "th", note: "`scope=\"col\"`, with the full name in `abbr`"],
          week: [element: "tr"],
          day: [
            element: "button",
            role: "gridcell",
            aria: ["aria-selected", "aria-current", "aria-disabled", "aria-label"],
            data_attributes: [
              "data-date",
              "data-today",
              "data-outside",
              "data-selected",
              "data-range-start",
              "data-range-end",
              "data-in-range"
            ],
            note:
              "labelled \"Monday, 3 March 2025\" — a bare number says nothing about where in the " <>
                "grid you are; one day at a time is in the tab order"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Grid",
        keyboard: [
          "Arrow Left / Right — previous / next day",
          "Arrow Up / Down — same weekday, previous / next week",
          "Home / End — first / last day of the week",
          "PageUp / PageDown — same day, previous / next month",
          "Enter / Space — pick the focused day"
        ]
      ],
      state_attributes: [
        "data-selected",
        "data-today",
        "data-outside",
        "data-in-range",
        "data-range-start",
        "data-range-end"
      ],
      hooks: ["Calendar"]
    ]
  ]
]
