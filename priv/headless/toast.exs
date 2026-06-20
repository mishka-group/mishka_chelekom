[
  toast: [
    name: "toast",
    category: "feedback",
    doc_url: "https://www.w3.org/TR/wai-aria-1.2/#aria-live",
    args: [type: ["toast"], only: ["toast"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "ToastRegion",
        type: "file",
        file: "toast_region.js",
        imports: "import ToastRegion from \"./toast_region.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [element: "div", required: true],
        parts: [
          trigger: [element: "button", note: "creates a toast from the template on click"],
          viewport: [
            element: "ol",
            aria: ["aria-live", "aria-atomic"],
            css_vars: ["--toast-frontmost-height"],
            note: "the live region + stacking container; carries data-expanded on hover/focus"
          ],
          template: [
            element: "template",
            note: "cloned per new toast; use a `data-toast-count` element for a running number"
          ],
          toast: [
            element: "li",
            data_attributes: [
              "data-duration",
              "data-open",
              "data-closed",
              "data-expanded",
              "data-limited",
              "data-starting-style",
              "data-ending-style"
            ],
            css_vars: ["--toast-index", "--toast-offset-y", "--toast-height", "--toast-swipe-movement-x", "--toast-swipe-movement-y"]
          ],
          content: [element: "div", data_attributes: ["data-behind"]],
          close: [element: "button", aria: ["aria-label"]]
        ]
      ],
      aria_pattern: [
        pattern: "Toast (live region)",
        keyboard: [
          "Hover or focus the viewport: expands the stack and pauses auto-dismiss",
          "Close button dismisses a toast; live region announces new toasts automatically"
        ]
      ],
      state_attributes: [
        "data-open",
        "data-closed",
        "data-expanded",
        "data-limited",
        "data-behind",
        "data-starting-style",
        "data-ending-style"
      ],
      hooks: ["ToastRegion"]
    ]
  ]
]
