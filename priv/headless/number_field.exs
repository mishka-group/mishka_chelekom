[
  number_field: [
    name: "number_field",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/spinbutton/",
    args: [type: ["number_field"], only: ["number_field"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "NumberField",
        type: "file",
        file: "number_field.js",
        imports: "import NumberField from \"./number_field.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-disabled", "data-readonly", "data-required", "data-scrubbing"],
          note: "carries the NumberField hook; reads min/max/step/format/locale from data-*",
          required: true
        ],
        parts: [
          scrub_area: [
            element: "span",
            note: "optional drag region (data-direction, data-pixel-sensitivity)"
          ],
          scrub_area_cursor: [element: "span", note: "optional custom cursor shown while scrubbing"],
          decrement: [
            element: "button",
            aria: ["aria-label", "aria-controls"],
            note: "press-and-hold to auto-repeat; tabindex=-1"
          ],
          input: [
            element: "input",
            aria: ["aria-roledescription"],
            note: "visible locale-formatted text input"
          ],
          increment: [
            element: "button",
            aria: ["aria-label", "aria-controls"],
            note: "press-and-hold to auto-repeat; tabindex=-1"
          ],
          hidden_input: [
            element: "input",
            note: "visually hidden type=number carrying the raw value for form submission"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Spinbutton (Base UI: editable text input + aria-roledescription)",
        keyboard: [
          "ArrowUp/ArrowDown: ±step (Shift ⇒ largeStep, Alt ⇒ smallStep)",
          "PageUp/PageDown: ±largeStep",
          "Home: min · End: max",
          "Wheel: ±step when focused (allow_wheel_scrub)"
        ]
      ],
      state_attributes: ["data-disabled", "data-readonly", "data-required", "data-scrubbing"],
      hooks: ["NumberField"]
    ]
  ]
]
