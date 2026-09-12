[
  theme_controller: [
    name: "theme_controller",
    category: "actions",
    doc_url: "https://mishka.tools/chelekom/docs/headless/theme_controller",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/radio/",
    args: [type: ["theme_controller"], only: ["theme_controller"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        module: "ThemeController",
        type: "file",
        file: "theme_controller.js",
        imports: "import ThemeController from \"./theme_controller.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "radiogroup",
          aria: ["aria-label"],
          data_attributes: [
            "data-target",
            "data-storage-key",
            "data-theme-value",
            "data-on-change"
          ],
          note:
            "writes `data-theme` onto `target` and stores the choice, so it survives a reload — " <>
              "daisyUI's pure-CSS controller forgets it on the next navigation",
          required: true
        ],
        parts: [
          option: [
            element: "label",
            data_attributes: ["data-value", "data-checked"],
            note: "wraps its own input, so clicking the label picks the theme"
          ],
          input: [
            element: "input",
            data_attributes: ["data-value", "data-unchecked-value"],
            note:
              "a native radio (or one checkbox in `switch` mode), so keyboard navigation and " <>
                "screen-reader semantics come from the browser rather than a hook"
          ],
          label: [element: "span", note: "the slot body when given, otherwise the theme's name"]
        ]
      ],
      aria_pattern: [
        pattern: "Radio Group (native inputs)",
        keyboard: [
          "Tab — reach the group",
          "Arrow keys — move between themes (native)",
          "Space — pick the focused theme"
        ]
      ],
      state_attributes: ["data-checked", "data-value"],
      hooks: ["ThemeController"]
    ]
  ]
]
