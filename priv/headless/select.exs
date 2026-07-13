[
  select: [
    name: "select",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/select",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/combobox/",
    args: [type: ["select"], only: ["select"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Select",
        type: "file",
        file: "select.js",
        imports: "import Select from \"./select.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          note: "carries the Select hook; reads name/multiple/disabled/readonly/required from data-*",
          required: true
        ],
        parts: [
          label: [element: "label", note: "accessible name, wired via aria-labelledby"],
          trigger: [
            element: "button",
            role: "combobox",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls", "aria-readonly", "aria-required"],
            data_attributes: [
              "data-popup-open",
              "data-placeholder",
              "data-disabled",
              "data-readonly",
              "data-required"
            ]
          ],
          value: [element: "span", data_attributes: ["data-placeholder"], note: "selected label(s) or placeholder"],
          icon: [element: "span", data_attributes: ["data-popup-open"]],
          positioner: [element: "div"],
          popup: [
            element: "ul",
            role: "listbox",
            aria: ["aria-multiselectable"],
            data_attributes: ["data-open", "data-closed", "data-side"]
          ],
          group: [element: "li", role: "group", aria: ["aria-labelledby"]],
          group_label: [element: "span"],
          item: [
            element: "li",
            role: "option",
            aria: ["aria-selected"],
            data_attributes: ["data-selected", "data-highlighted", "data-disabled"]
          ],
          item_indicator: [element: "span", note: "selected ✓ (shown when the item is data-selected)"],
          item_text: [element: "span"],
          value_inputs: [element: "span", note: "hidden input(s) carrying the value for form submission"]
        ]
      ],
      aria_pattern: [
        pattern: "Listbox / Combobox",
        keyboard: [
          "Enter/Space/Arrow: open · Arrow Up/Down + Home/End: navigate",
          "Enter/Space: select · Escape/Tab: close · Type: typeahead jump"
        ]
      ],
      state_attributes: [
        "data-open",
        "data-closed",
        "data-side",
        "data-highlighted",
        "data-selected",
        "data-disabled",
        "data-readonly",
        "data-required",
        "data-placeholder",
        "data-popup-open"
      ],
      hooks: ["Select"]
    ]
  ]
]
