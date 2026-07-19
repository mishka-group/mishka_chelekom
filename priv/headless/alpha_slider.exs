[
  alpha_slider: [
    name: "alpha_slider",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/alpha_slider",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/slider/",
    args: [type: ["alpha_slider"], only: ["alpha_slider"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "Slider", type: "file", file: "slider.js", imports: "import Slider from \"./slider.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-disabled"],
          note: "reuses the Slider engine (0–100); exposes --chelekom-alpha-color for the track gradient",
          required: true
        ],
        parts: [
          control: [element: "div"],
          track: [element: "div", note: "checkerboard + transparent→color gradient"],
          indicator: [element: "div", note: "usually hidden"],
          thumb: [
            element: "span",
            role: "slider",
            aria: ["aria-valuemin", "aria-valuemax", "aria-valuenow"],
            note: "the draggable handle; contains the hidden input"
          ]
        ]
      ],
      aria_pattern: [pattern: "Slider", keyboard: ["Arrow ±step", "Home → 0 · End → 100"]],
      state_attributes: ["data-disabled", "data-dragging"],
      hooks: ["Slider"]
    ]
  ]
]
