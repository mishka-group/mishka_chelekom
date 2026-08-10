[
  countdown: [
    name: "countdown",
    category: "data-display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/countdown",
    spec_url: "https://www.w3.org/TR/wai-aria-1.2/#timer",
    args: [type: ["countdown"], only: ["countdown"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        module: "Countdown",
        type: "file",
        file: "countdown.js",
        imports: "import Countdown from \"./countdown.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "timer",
          aria: ["aria-live"],
          data_attributes: ["data-deadline", "data-units", "data-complete", "data-on-complete"],
          note:
            "live updates are off by default — a per-second live region is unusable noise; the " <>
              "deadline is absolute so a slow render cannot drift the clock",
          required: true
        ],
        parts: [
          unit: [element: "span", data_attributes: ["data-unit"]],
          digit: [
            element: "span",
            aria: ["aria-label"],
            data_attributes: ["data-unit"],
            note: "carries `--value`, the custom property daisyUI's rolling digits animate"
          ],
          label: [
            element: "span",
            note: "aria-hidden; the digit's own aria-label already carries the unit"
          ],
          separator: [element: "span", note: "aria-hidden"]
        ]
      ],
      aria_pattern: [
        pattern: "Timer",
        keyboard: ["None — a countdown is not interactive"]
      ],
      state_attributes: ["data-complete", "data-unit"],
      hooks: ["Countdown"]
    ]
  ]
]
