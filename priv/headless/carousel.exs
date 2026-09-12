[
  carousel: [
    name: "carousel",
    category: "data-display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/carousel",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/carousel/",
    args: [type: ["carousel"], only: ["carousel"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        module: "HeadlessCarousel",
        type: "file",
        file: "headless_carousel.js",
        imports: "import HeadlessCarousel from \"./headless_carousel.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "region",
          aria: ["aria-roledescription", "aria-label"],
          data_attributes: [
            "data-orientation",
            "data-snap",
            "data-index",
            "data-loop",
            "data-autoplay"
          ],
          note:
            "the scrolling is native scroll-snap, so it works with the hook absent; the hook only " <>
              "adds the state CSS cannot report",
          required: true
        ],
        parts: [
          viewport: [
            element: "div",
            note: "the snap container, focusable so arrow keys can drive it"
          ],
          slide: [
            element: "div",
            role: "group",
            aria: ["aria-roledescription", "aria-label", "aria-hidden"],
            data_attributes: ["data-index", "data-current"],
            note: "labelled \"3 of 7\"; current is observed by IntersectionObserver, never counted"
          ],
          previous: [element: "button", aria: ["aria-label", "aria-controls"]],
          next: [element: "button", aria: ["aria-label", "aria-controls"]],
          indicators: [element: "div", role: "group"],
          indicator: [
            element: "button",
            aria: ["aria-current", "aria-label"],
            data_attributes: ["data-index", "data-current"]
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Carousel",
        keyboard: [
          "Arrow Left / Right — previous / next slide (vertical: Up / Down)",
          "Home / End — first / last slide",
          "Tab — reach the viewport and the controls"
        ]
      ],
      state_attributes: ["data-current", "data-index", "data-orientation", "data-snap"],
      hooks: ["HeadlessCarousel"]
    ]
  ]
]
