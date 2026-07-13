[
  slider: [
    name: "slider",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/slider",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/slider/",
    args: [type: ["slider"], only: ["slider"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Slider",
        type: "file",
        file: "slider.js",
        imports: "import Slider from \"./slider.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-orientation", "data-dragging", "data-disabled"],
          note: "carries the Slider hook; reads min/max/step/large_step/orientation/format from data-*",
          required: true
        ],
        parts: [
          label: [element: "label", note: "accessible label, wired via aria-labelledby"],
          value: [
            element: "output",
            data_attributes: ["data-orientation"],
            note: "formatted value readout"
          ],
          control: [
            element: "div",
            data_attributes: ["data-orientation", "data-dragging", "data-disabled"],
            note: "press to jump the nearest thumb; drag to move it"
          ],
          track: [element: "div", data_attributes: ["data-orientation"]],
          indicator: [
            element: "div",
            data_attributes: ["data-orientation"],
            note: "the filled interval from the first thumb (or min) to the last"
          ],
          thumb: [
            element: "span",
            role: "slider",
            aria: [
              "aria-orientation",
              "aria-valuemin",
              "aria-valuemax",
              "aria-valuenow",
              "aria-valuetext"
            ],
            data_attributes: ["data-index", "data-orientation", "data-dragging", "data-disabled"],
            note: "one per value; contains a hidden input for form submission"
          ],
          input: [element: "input", note: "hidden value carrier (single → name, range → name[])"]
        ]
      ],
      aria_pattern: [
        pattern: "Slider (and multi-thumb)",
        keyboard: [
          "Arrow: ±step (Up/Right increase) · Shift+Arrow / PageUp/Down: ±large_step",
          "Home: min · End: max"
        ]
      ],
      state_attributes: ["data-orientation", "data-dragging", "data-disabled", "data-index"],
      hooks: ["Slider"]
    ]
  ]
]
