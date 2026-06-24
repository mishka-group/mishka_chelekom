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
        module: "Tabs",
        type: "file",
        file: "tabs.js",
        imports: "import Tabs from \"./tabs.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-orientation", "data-activation-direction"],
          note: "carries the Tabs hook; data-value is the controlled active tab",
          required: true
        ],
        parts: [
          tablist: [
            element: "div",
            role: "tablist",
            aria: ["aria-orientation"],
            note: "exposes --active-tab-left/right/top/bottom/width/height"
          ],
          tab: [
            element: "button",
            role: "tab",
            aria: ["aria-selected", "aria-controls"],
            data_attributes: ["data-active", "data-disabled", "data-orientation", "data-value"]
          ],
          indicator: [
            element: "div",
            data_attributes: ["data-orientation", "data-activation-direction"],
            note: "the animated underline; positions itself from the --active-tab-* vars"
          ],
          panel: [
            element: "div",
            role: "tabpanel",
            aria: ["aria-labelledby"],
            data_attributes: ["data-hidden", "data-index", "data-orientation", "data-activation-direction"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Tabs",
        keyboard: ["Arrow (along orientation): move + activate", "Home/End: first/last"]
      ],
      state_attributes: [
        "data-orientation",
        "data-activation-direction",
        "data-active",
        "data-disabled",
        "data-hidden"
      ],
      hooks: ["Tabs"]
    ]
  ]
]
