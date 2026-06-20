[
  preview_card: [
    name: "preview_card",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["preview_card"], only: ["preview_card"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Popup",
        type: "file",
        file: "popup.js",
        imports: "import Popup from \"./popup.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          trigger: [element: "span", aria: ["aria-expanded", "aria-controls"]],
          popup: [
            element: "div",
            role: "dialog",
            data_attributes: ["data-open", "data-closed", "data-side"]
          ]
        ]
      ],
      aria_pattern: [pattern: "Hover Card (no formal APG pattern)", keyboard: ["Escape: close"]],
      state_attributes: ["data-open", "data-closed", "data-side"],
      hooks: ["Popup"]
    ]
  ]
]
