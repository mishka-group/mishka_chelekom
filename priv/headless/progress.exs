[
  progress: [
    name: "progress",
    category: "feedback",
    doc_url: "https://www.w3.org/TR/wai-aria-1.2/#progressbar",
    args: [type: ["progress"], only: ["progress"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "progressbar",
          aria: [
            "aria-valuemin",
            "aria-valuemax",
            "aria-valuenow",
            "aria-valuetext",
            "aria-labelledby"
          ],
          data_attributes: ["data-indeterminate", "data-progressing", "data-complete"],
          required: true
        ],
        parts: [
          label: [element: "span"],
          value: [element: "span", note: "optional readout, rendered when `show_value` is set"],
          track: [
            element: "div",
            data_attributes: ["data-indeterminate", "data-progressing", "data-complete"]
          ],
          indicator: [
            element: "div",
            data_attributes: ["data-indeterminate", "data-progressing", "data-complete"],
            css_vars: ["--chelekom-progress"]
          ]
        ]
      ],
      aria_pattern: [pattern: "Progressbar", keyboard: []],
      state_attributes: ["data-indeterminate", "data-progressing", "data-complete"],
      hooks: []
    ]
  ]
]
