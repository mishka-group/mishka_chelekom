[
  autocomplete: [
    name: "autocomplete",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/autocomplete",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/combobox/",
    args: [type: ["autocomplete"], only: ["autocomplete"], helpers: [], module: ""],
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
          clear: [
            element: "button",
            aria: ["aria-label"],
            data_attributes: ["data-hidden"],
            note: "opt-in (`clear`); hidden when the input is empty"
          ],
          value: [element: "input", note: "hidden form value"],
          status: [element: "div", role: "status", note: "aria-live region; engine writes the result count"],
          popup: [element: "ul", role: "listbox", data_attributes: ["data-open", "data-closed"]],
          group: [
            element: "li",
            role: "group",
            aria: ["aria-labelledby"],
            data_attributes: ["data-hidden"],
            note: "hidden when all its items are filtered out"
          ],
          group_label: [element: "span"],
          item: [
            element: "li",
            role: "option",
            data_attributes: ["data-value", "data-highlighted", "data-hidden"],
            aria: ["aria-selected"]
          ],
          empty: [element: "li", data_attributes: ["data-hidden"], note: "shown when nothing matches"]
        ]
      ],
      aria_pattern: [
        pattern: "Combobox",
        keyboard: [
          "Down/Up: open + navigate",
          "Enter: select",
          "Escape: close",
          "Type: filter options (auto_highlight highlights the first match)"
        ]
      ],
      state_attributes: ["data-open", "data-closed", "data-highlighted", "data-hidden"],
      hooks: ["HeadlessCombobox"]
    ]
  ]
]
