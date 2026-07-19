[
  color_input: [
    name: "color_input",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/color_input",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/disclosure/",
    args: [type: ["color_input"], only: ["color_input"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "ColorPicker", type: "file", file: "color_picker.js", imports: "import ColorPicker from \"./color_picker.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-value", "data-on-change"],
          note: "carries the ColorPicker hook; the picker panel is toggled with JS commands",
          required: true
        ],
        parts: [
          control: [element: "div", note: "the always-visible row: swatch + hex field + trigger"],
          preview: [element: "span", role: "img", note: "current color swatch"],
          text: [element: "input", note: "editable hex field (two-way with the picker)"],
          trigger: [
            element: "button",
            aria: ["aria-haspopup", "aria-expanded", "aria-controls"],
            note: "toggles the panel via JS commands; aria-expanded tracks it"
          ],
          panel: [
            element: "div",
            role: "dialog",
            note: "popover holding the picker area + hue; closes on outside click / Escape"
          ],
          area: [element: "div", note: "saturation/value area"],
          "area-thumb": [element: "span", note: "draggable handle"],
          hue: [element: "input", note: "native range (0–360)"],
          input: [element: "input", note: "hidden hex value for form submission"]
        ]
      ],
      aria_pattern: [
        pattern: "Text field + color picker in a popover (disclosure)",
        keyboard: [
          "Hue: Arrow keys (native range)",
          "Type a hex in the text field",
          "Escape / outside click — close the panel"
        ]
      ],
      state_attributes: ["data-value", "data-dragging"],
      hooks: ["ColorPicker"]
    ]
  ]
]
