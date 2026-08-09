[
  switch: [
    name: "switch",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/switch",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/switch/",
    args: [type: ["switch"], only: ["switch"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        module: "Toggle",
        type: "file",
        file: "toggle.js",
        imports: "import Toggle from \"./toggle.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "button",
          role: "switch",
          aria: ["aria-checked", "aria-labelledby", "aria-readonly", "aria-required"],
          data_attributes: [
            "data-checked",
            "data-unchecked",
            "data-disabled",
            "data-readonly",
            "data-required"
          ],
          required: true
        ],
        parts: [
          input: [element: "input", note: "hidden checkbox carrying the value for form submission"],
          track: [element: "span", data_attributes: ["data-checked", "data-unchecked"]],
          thumb: [element: "span", data_attributes: ["data-checked", "data-unchecked"]],
          "on-icon": [
            element: "span",
            data_attributes: ["data-checked", "data-unchecked"],
            note: "optional `:on_icon` slot, rendered inside the track after the thumb"
          ],
          "off-icon": [
            element: "span",
            data_attributes: ["data-checked", "data-unchecked"],
            note: "optional `:off_icon` slot, rendered inside the track after the thumb"
          ],
          label: [element: "span"]
        ]
      ],
      aria_pattern: [pattern: "Switch", keyboard: ["Enter: toggle", "Space: toggle"]],
      state_attributes: [
        "data-checked",
        "data-unchecked",
        "data-disabled",
        "data-readonly",
        "data-required"
      ],
      hooks: ["Toggle"]
    ]
  ]
]
