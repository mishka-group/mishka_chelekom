[
  color_picker: [
    name: "color_picker",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/color_picker",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["color_picker"], only: ["color_picker"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "ColorPicker", type: "file", file: "color_picker.js", imports: "import ColorPicker from \"./color_picker.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-value", "data-dragging"],
          note: "carries the ColorPicker hook; data-value is the current hex",
          required: true
        ],
        parts: [
          area: [element: "div", note: "2D saturation/value area — drag to pick"],
          "area-thumb": [element: "span", note: "the draggable handle in the area"],
          hue: [element: "input", note: "native range (0–360) for hue"],
          preview: [element: "span", role: "img", note: "shows the current color"],
          input: [element: "input", note: "hidden hex value for form submission"]
        ]
      ],
      aria_pattern: [pattern: "Color picker (no formal APG pattern)", keyboard: ["Hue: Arrow keys (native range)"]],
      state_attributes: ["data-value", "data-dragging"],
      hooks: ["ColorPicker"]
    ]
  ]
]
