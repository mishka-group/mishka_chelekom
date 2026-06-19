[
  accordion: [
    name: "accordion",
    category: "disclosure",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/accordion/",
    args: [type: ["accordion"], only: ["accordion"], helpers: [], module: ""],
    optional: [
      "multiple",
      "collapsible",
      "disabled",
      "orientation",
      "heading_level",
      "loop",
      "hidden_until_found",
      "value",
      "initial_open",
      "on_value_change"
    ],
    necessary: [],
    anatomy: [
      parts: [
        item: [
          element: "div",
          data_attributes: [
            "data-index",
            "data-value",
            "data-open",
            "data-disabled",
            "data-on-open-change"
          ]
        ],
        header: [element: "h1..h6", note: "heading level set by `heading_level`"],
        trigger: [
          element: "button",
          aria: ["aria-expanded", "aria-controls", "aria-disabled"],
          data_attributes: ["data-index", "data-disabled", "data-panel-open"],
          note: "roving tabindex (one trigger in the tab order)"
        ],
        panel: [
          element: "div",
          role: "region",
          aria: ["aria-labelledby"],
          data_attributes: [
            "data-open",
            "data-closed",
            "data-index",
            "data-orientation",
            "data-disabled",
            "data-starting-style",
            "data-ending-style"
          ],
          css_vars: ["--accordion-panel-height", "--accordion-panel-width"],
          note: ~s|closed panels carry `hidden` (or `hidden="until-found"`) when kept mounted|
        ]
      ]
    ],
    aria_pattern: [
      pattern: "Accordion",
      keyboard: [
        "Enter/Space: toggle the focused panel",
        "ArrowDown/ArrowUp: move focus between headers (ArrowRight/ArrowLeft when horizontal, RTL-aware)",
        "Home/End: focus the first/last enabled header",
        "disabled headers are skipped"
      ]
    ],
    state_attributes: [
      "data-open",
      "data-closed",
      "data-disabled",
      "data-orientation",
      "data-index",
      "data-panel-open",
      "data-starting-style",
      "data-ending-style"
    ],
    hooks: ["Disclosure"],
    scripts: [
      %{type: "file", file: "disclosure.js", module: "Disclosure", imports: "import Disclosure from \"./disclosure.js\";"}
    ]
  ]
]
