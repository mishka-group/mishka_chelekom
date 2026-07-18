[
  tree_select: [
    name: "tree_select",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/tree_select",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/combobox/",
    args: [type: ["tree_select"], only: ["tree_select"], helpers: [], module: ""],
    optional: [],
    necessary: ["tree"],
    scripts: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: [],
          note: "wraps a trigger + a popover panel; put a `tree` inside the default slot",
          required: true
        ],
        parts: [
          trigger: [
            element: "button",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls"],
            note: "opens the panel via JS commands (aria-expanded follows); shows the selected label"
          ],
          value: [element: "span", note: "the current selection label (or placeholder)"],
          panel: [
            element: "div",
            note: "popover holding the tree (the tree's own role is the announced popup)"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Combobox-like disclosure over a tree",
        keyboard: [
          "Enter/Space on the trigger toggles the panel",
          "Escape / outside click — close the panel",
          "Tree owns its own keyboard"
        ]
      ],
      state_attributes: [],
      hooks: []
    ]
  ]
]
