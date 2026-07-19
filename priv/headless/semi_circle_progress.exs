[
  semi_circle_progress: [
    name: "semi_circle_progress",
    category: "feedback",
    doc_url: "https://mishka.tools/chelekom/docs/headless/semi_circle_progress",
    spec_url: "https://www.w3.org/TR/wai-aria-1.2/#progressbar",
    args: [type: ["semi_circle_progress"], only: ["semi_circle_progress"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "progressbar",
          aria: ["aria-valuemin", "aria-valuemax", "aria-valuenow", "aria-label"],
          note: "half-circle gauge computed at render time (no JS)",
          required: true
        ],
        parts: [
          svg: [element: "svg", note: "the drawing surface — unsized, give it a width (e.g. w-full)"],
          track: [element: "path", note: "the background arc"],
          indicator: [element: "path", note: "the filled arc (stroke-dashoffset from value)"],
          label: [element: "div", note: "optional centered readout"]
        ]
      ],
      aria_pattern: [pattern: "Progressbar", keyboard: []],
      state_attributes: [],
      hooks: []
    ]
  ]
]
