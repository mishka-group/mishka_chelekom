[
  tabs: [
    name: "tabs",
    category: "navigation",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/tabs/",
    args: [type: ["tabs"], only: ["tabs"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "RovingTabindex",
        type: "file",
        file: "roving_tabindex.js",
        imports: "import RovingTabindex from \"./roving_tabindex.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          tablist: [element: "div", role: "tablist", aria: ["aria-orientation"]],
          tab: [element: "button", role: "tab", aria: ["aria-selected", "aria-controls"]],
          panel: [
            element: "div",
            role: "tabpanel",
            aria: ["aria-labelledby"],
            data_attributes: ["data-open", "data-closed"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Tabs",
        keyboard: ["Arrow: move + activate", "Home/End: first/last"]
      ],
      state_attributes: ["data-open", "data-closed"],
      hooks: ["RovingTabindex"]
    ]
  ]
]
