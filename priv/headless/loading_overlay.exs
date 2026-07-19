[
  loading_overlay: [
    name: "loading_overlay",
    category: "feedback",
    doc_url: "https://mishka.tools/chelekom/docs/headless/loading_overlay",
    spec_url: "https://www.w3.org/TR/wai-aria-1.2/#aria-live",
    args: [type: ["loading_overlay"], only: ["loading_overlay"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "status",
          aria: ["aria-live", "aria-label", "aria-hidden"],
          data_attributes: ["data-visible"],
          note:
            "absolute overlay for a relative parent; toggled by `visible` (CSS opacity, no JS); " <>
              "hidden = aria-hidden + inline pointer-events:none so it never blocks clicks",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [pattern: "Status (live region)", keyboard: []],
      state_attributes: ["data-visible"],
      hooks: []
    ]
  ]
]
