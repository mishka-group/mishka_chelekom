[
  hue_slider: [
    name: "hue_slider",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/hue_slider",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/slider/",
    args: [type: ["hue_slider"], only: ["hue_slider"], helpers: [], module: ""],
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
          note: "reuses the Slider engine (0–360); put a hue gradient on the track",
          required: true
        ],
        parts: [
          control: [element: "div"],
          track: [element: "div", note: "apply the rainbow hue gradient here"],
          indicator: [element: "div", note: "usually hidden for a hue slider"],
          thumb: [
            element: "span",
            role: "slider",
            aria: ["aria-valuemin", "aria-valuemax", "aria-valuenow"],
            note: "the draggable handle; contains the hidden input"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Slider",
        keyboard: ["Arrow ±step", "Home → 0 · End → 360"]
      ],
      state_attributes: ["data-disabled", "data-dragging"],
      hooks: ["Slider"]
    ]
  ]
]
