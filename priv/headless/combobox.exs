[
  combobox: [
    name: "combobox",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/combobox/",
    args: [type: ["combobox"], only: ["combobox"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "HeadlessCombobox",
        type: "file",
        file: "headless_combobox.js",
        imports: "import HeadlessCombobox from \"./headless_combobox.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          input: [
            element: "input",
            role: "combobox",
            aria: ["aria-controls", "aria-expanded", "aria-autocomplete", "aria-activedescendant"]
          ],
          value: [element: "input"],
          popup: [element: "ul", role: "listbox", data_attributes: ["data-open", "data-closed"]],
          item: [
            element: "li",
            role: "option",
            data_attributes: ["data-value", "data-highlighted", "data-hidden"],
            aria: ["aria-selected"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Combobox",
        keyboard: [
          "Down/Up: open + navigate",
          "Enter: select",
          "Escape: close",
          "Type: filter options"
        ]
      ],
      state_attributes: ["data-open", "data-closed", "data-highlighted", "data-hidden"],
      hooks: ["HeadlessCombobox"]
    ]
  ]
]
