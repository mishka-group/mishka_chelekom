[
  toast: [
    name: "toast",
    category: "feedback",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/alert/",
    args: [
      type: ["toast"],
      only: ["toast"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    anatomy: [
      root: [element: "div", aria: ["aria-live", "aria-atomic"], required: true],
      parts: [
        toast: [element: "div", role: "status", data_attributes: ["data-duration", "data-open", "data-closed"]],
        dismiss: [element: "button", aria: ["aria-label"]]
      ]
    ],
    aria_pattern: [
      pattern: "Alert",
      keyboard: ["No required keyboard interaction (live region announces automatically)"]
    ],
    state_attributes: ["data-open", "data-closed"],
    hooks: ["ToastRegion"],
    scripts: [
      %{
        type: "file",
        file: "toast_region.js",
        module: "ToastRegion",
        imports: "import ToastRegion from \"./toast_region.js\";"
      }
    ]
  ]
]
