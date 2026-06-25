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
        module: "PreviewCard",
        type: "file",
        file: "preview_card.js",
        imports: "import PreviewCard from \"./preview_card.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-open", "data-closed", "data-side", "data-align"],
          required: true
        ],
        parts: [
          trigger: [
            element: "span",
            aria: ["aria-expanded", "aria-controls"],
            data_attributes: ["data-popup-open"],
            note: "hover or focus this element (usually a link) to reveal the preview"
          ],
          popup: [
            element: "div",
            role: "dialog",
            data_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-starting-style"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Hover card (non-modal) + anchored positioning",
        keyboard: ["Escape: close", "blur: close"],
        focus: "Never steals focus — focus stays on the trigger; the popup is hoverable."
      ],
      state_attributes: ["data-open", "data-closed", "data-side", "data-align", "data-popup-open", "data-starting-style"],
      hooks: ["PreviewCard"]
    ]
  ]
]
