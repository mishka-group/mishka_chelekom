[
  nav_link: [
    name: "nav_link",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/nav_link",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/",
    args: [type: ["nav_link"], only: ["nav_link"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "a / details",
          aria: ["aria-current"],
          data_attributes: ["data-active"],
          note: "a leaf link (<a>) or, with children, a native <details> disclosure",
          required: true
        ],
        parts: [
          control: [
            element: "summary",
            note: "the group's toggle row; wire on_toggle here for server-controlled open"
          ],
          icon: [element: "span", note: "leading icon"],
          label: [element: "span", note: "the label text"],
          trailing: [element: "span", note: "trailing content / chevron"],
          children: [element: "div", note: "nested nav links (when the item is a group)"]
        ]
      ],
      aria_pattern: [
        pattern: "Link / Disclosure",
        keyboard: ["Enter — follow (leaf)", "Enter / Space — toggle (group summary)"]
      ],
      state_attributes: ["data-active"],
      hooks: []
    ]
  ]
]
