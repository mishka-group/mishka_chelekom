[
  angle_slider: [
    name: "angle_slider",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/angle_slider",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/slider/",
    args: [type: ["angle_slider"], only: ["angle_slider"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "AngleSlider", type: "file", file: "angle_slider.js", imports: "import AngleSlider from \"./angle_slider.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "slider",
          aria: ["aria-valuemin", "aria-valuemax", "aria-valuenow", "aria-valuetext", "aria-label"],
          data_attributes: ["data-value", "data-step", "data-disabled", "data-dragging", "data-on-change"],
          note: "carries the AngleSlider hook; exposes --angle for an optional conic-gradient fill",
          required: true
        ],
        parts: [
          "thumb-layer": [element: "span", note: "absolutely fills the root; rotated by the angle"],
          thumb: [element: "span", note: "the handle, placed at the top of the rotating layer"],
          value: [element: "span", note: "optional; the hook writes the current degrees here"],
          input: [element: "input", note: "optional hidden input for form submission"]
        ]
      ],
      aria_pattern: [
        pattern: "Slider (circular)",
        keyboard: ["Arrow keys: ±step", "Home: 0°", "End: last step"]
      ],
      state_attributes: ["data-value", "data-dragging", "data-disabled"],
      hooks: ["AngleSlider"]
    ]
  ]
]
