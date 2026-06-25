[
  otp_field: [
    name: "otp_field",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["otp_field"], only: ["otp_field"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "Otp", type: "file", file: "otp.js", imports: "import Otp from \"./otp.js\";"}
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          role: "group",
          aria: ["aria-label"],
          data_attributes: [
            "data-disabled",
            "data-readonly",
            "data-required",
            "data-complete",
            "data-filled",
            "data-focused"
          ],
          note: "carries the Otp hook; reads length/validation_type/transform/mask from data-*",
          required: true
        ],
        parts: [
          input: [
            element: "input",
            data_attributes: ["data-filled", "data-complete", "data-focused"],
            note: "one single-char slot per character; roving tabindex (only active slot tabbable)"
          ],
          separator: [element: "span", note: "optional divider between groups (group + separator)"],
          value: [
            element: "input",
            note: "hidden input carrying the combined value + pattern/required for form submission"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "OTP / segmented input",
        keyboard: [
          "type: replace + advance · Backspace: clear/back (Ctrl/Meta+Backspace: clear all)",
          "Delete: remove + shift · Arrow Left/Right: navigate (Ctrl/Meta: ends)",
          "Home/ArrowUp: first · End/ArrowDown: last filled · Paste: distribute"
        ]
      ],
      state_attributes: [
        "data-disabled",
        "data-readonly",
        "data-required",
        "data-complete",
        "data-filled",
        "data-focused"
      ],
      hooks: ["Otp"]
    ]
  ]
]
