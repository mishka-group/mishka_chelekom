[
  slider: [
    name: "slider",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/slider/",
    args: [
      type: ["slider"],
      only: ["slider"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    anatomy: [
      root: [
        element: "div",
        data_attributes: ["data-min", "data-max", "data-step", "data-value"],
        required: true
      ],
      parts: [
        track: [element: "div"],
        range: [element: "div"],
        thumb: [
          element: "div",
          role: "slider",
          aria: ["aria-valuemin", "aria-valuemax", "aria-valuenow"]
        ],
        input: [element: "input"]
      ]
    ],
    aria_pattern: [
      pattern: "Slider",
      keyboard: [
        "ArrowRight/ArrowUp: increase by step",
        "ArrowLeft/ArrowDown: decrease by step",
        "PageUp: increase by 10·step",
        "PageDown: decrease by 10·step",
        "Home: minimum",
        "End: maximum"
      ]
    ],
    state_attributes: ["data-min", "data-max", "data-step", "data-value"],
    hooks: ["Slider"],
    scripts: [
      %{
        type: "file",
        file: "slider.js",
        module: "Slider",
        imports: "import Slider from \"./slider.js\";"
      }
    ]
  ]
]
