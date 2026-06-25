[
  drawer: [
    name: "drawer",
    category: "overlays",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/",
    args: [type: ["drawer"], only: ["drawer"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Drawer",
        type: "file",
        file: "drawer.js",
        imports: "import Drawer from \"./drawer.js\";"
      }
    ],
    headless: [
      anatomy: [
        parts: [
          trigger: [
            element: "button",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls"],
            data_attributes: ["data-popup-open"]
          ],
          swipe_area: [
            element: "div",
            role: "presentation",
            aria: ["aria-hidden"],
            data_attributes: ["data-open", "data-closed", "data-disabled", "data-swiping", "data-swipe-direction"],
            note: "opt-in (`swipe_area`); drag from the edge to open a closed drawer"
          ],
          backdrop: [
            element: "div",
            aria: ["aria-hidden"],
            data_attributes: ["data-swiping"],
            css_vars: ["--drawer-swipe-progress"]
          ],
          viewport: [element: "div", note: "fixed positioning + clipping layer for the popup"],
          popup: [
            element: "div",
            role: "dialog",
            aria: ["aria-modal", "aria-labelledby", "aria-describedby"],
            data_attributes: [
              "data-side",
              "data-modal",
              "data-open",
              "data-closed",
              "data-swiping",
              "data-swipe-direction",
              "data-swipe-dismiss",
              "data-expanded",
              "data-starting-style",
              "data-ending-style"
            ],
            css_vars: [
              "--drawer-swipe-movement-x",
              "--drawer-swipe-movement-y",
              "--drawer-snap-point-offset",
              "--drawer-swipe-strength"
            ]
          ],
          handle: [element: "div", aria: ["aria-hidden"], note: "optional drag-handle pill for bottom sheets"],
          title: [element: "h2"],
          description: [element: "p"],
          content: [element: "div"],
          close: [element: "button", note: "footer; use data-close to close"],
          indent: [
            element: "div",
            note: "[data-drawer-content] under a [data-drawer-provider]; scales while a drawer is open",
            data_attributes: ["data-active", "data-inactive"],
            css_vars: ["--drawer-swipe-progress"]
          ],
          indent_background: [
            element: "div",
            note: "[data-drawer-background]; the surface revealed behind the indented content",
            data_attributes: ["data-active", "data-inactive"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Dialog (Modal)",
        keyboard: ["Escape: close", "Tab: trapped cycle (when modal)", "Shift+Tab: cycle backward"],
        focus: "Trap inside popup when modal; restore focus to opener on close. Swipe is pointer-only (no keyboard equivalent)."
      ],
      state_attributes: [
        "data-open",
        "data-closed",
        "data-side",
        "data-modal",
        "data-swiping",
        "data-swipe-direction",
        "data-swipe-dismiss",
        "data-expanded"
      ],
      hooks: ["Drawer"]
    ]
  ]
]
