[
  sparkline: [
    name: "sparkline",
    category: "data display",
    doc_url: "https://mishka.tools/chelekom/docs/headless/sparkline",
    spec_url: "https://developer.mozilla.org/en-US/docs/Web/SVG/Element/path",
    args: [type: ["sparkline"], only: ["sparkline"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    # No npm, no scripts, no hook: this component is pure server-rendered SVG. It works in a table
    # cell, a stat card, even an email — anywhere HEEx renders — and needs no JS build pipeline at
    # all, which is why it ships regardless of which chart engine (if any) you generated.
    headless: [
      anatomy: [
        root: [
          element: "svg",
          aria: ["aria-hidden", "aria-label", "role"],
          data_attributes: [],
          note:
            "the whole component is one inline <svg>. It inherits `currentColor`, so it takes the " <>
              "surrounding text color unless you pass `color`",
          required: true
        ],
        parts: []
      ],
      aria_pattern: [
        pattern: "Sparkline (decorative by default; role=img when named)",
        keyboard: [
          "Non-interactive: no keyboard behavior",
          "aria-hidden by default; pass aria_label to expose a summary (role becomes img)"
        ]
      ],
      state_attributes: [],
      hooks: []
    ]
  ]
]
