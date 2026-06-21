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
          trigger: [element: "button", note: "opens/closes the popup without typing"],
          clear: [element: "button", data_attributes: ["data-hidden"], note: "clears query/selection"],
          chips: [element: "div", note: "container of selected chips (multiple)"],
          chip: [
            element: "span",
            note: "a selected chip; has data-chip-value + a `data-part=chip-remove` button"
          ],
          value: [
            element: "input",
            note: "hidden form value (single) — multiple submits via chips' name[]"
          ],
          popup: [element: "ul", role: "listbox", data_attributes: ["data-open", "data-closed"]],
          group: [
            element: "li",
            role: "group",
            aria: ["aria-labelledby"],
            data_attributes: ["data-hidden"]
          ],
          group_label: [element: "span"],
          item: [
            element: "li",
            role: "option",
            data_attributes: [
              "data-value",
              "data-highlighted",
              "data-hidden",
              "data-selected",
              "data-disabled"
            ],
            aria: ["aria-selected", "aria-disabled"]
          ],
          indicator: [
            element: "span",
            note: "selected checkmark (shown when the item is data-selected)"
          ],
          empty: [element: "li", data_attributes: ["data-hidden"], note: "shown when nothing matches"],
          create: [
            element: "li",
            data_attributes: ["data-hidden"],
            note: "creatable: offers to create the typed query (data-create-label)"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Combobox",
        keyboard: [
          "Down/Up: open + navigate (skips disabled/hidden options)",
          "Enter: select the highlighted option (or create, when creatable)",
          "Escape: close",
          "Type: filter options"
        ]
      ],
      state_attributes: [
        "data-open",
        "data-closed",
        "data-highlighted",
        "data-hidden",
        "data-selected",
        "data-disabled"
      ],
      hooks: ["HeadlessCombobox"]
    ]
  ]
]
