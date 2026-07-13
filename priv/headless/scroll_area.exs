[
  scroll_area: [
    name: "scroll_area",
    category: "media",
    doc_url: "https://mishka.tools/chelekom/docs/headless/scroll-area",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["scroll_area"], only: ["scroll_area"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "ScrollArea",
        type: "file",
        file: "scrollArea.js",
        imports: "import ScrollArea from \"./scrollArea.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: [
            "data-orientation",
            "data-scrolling",
            "data-has-overflow-x",
            "data-has-overflow-y",
            "data-overflow-x-start",
            "data-overflow-x-end",
            "data-overflow-y-start",
            "data-overflow-y-end"
          ],
          note: "carries the ScrollArea hook; exposes --scroll-area-overflow-* and --scroll-area-thumb-* CSS vars",
          required: true
        ],
        parts: [
          viewport: [element: "div", note: "the scrollable, focusable viewport (native scrollbar hidden)"],
          content: [element: "div", note: "wraps the scrollable content"],
          scrollbar: [
            element: "div",
            data_attributes: ["data-orientation", "data-hovering", "data-scrolling"]
          ],
          thumb: [
            element: "div",
            data_attributes: ["data-orientation"],
            note: "draggable; sized via --scroll-area-thumb-*"
          ],
          corner: [element: "div", note: "shown with orientation=both where the scrollbars meet"]
        ]
      ],
      aria_pattern: [
        pattern: "Scroll area",
        keyboard: ["Arrow/PageUp/PageDown: scroll the focused viewport"]
      ],
      state_attributes: [
        "data-orientation",
        "data-scrolling",
        "data-hovering",
        "data-has-overflow-x",
        "data-has-overflow-y",
        "data-overflow-x-start",
        "data-overflow-x-end",
        "data-overflow-y-start",
        "data-overflow-y-end"
      ],
      hooks: ["ScrollArea"]
    ]
  ]
]
