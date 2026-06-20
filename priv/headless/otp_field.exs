[
  otp_field: [
    name: "otp_field",
    category: "forms",
    doc_url: "https://www.w3.org/WAI/ARIA/apg/patterns/spinbutton/",
    args: [type: ["otp_field"], only: ["otp_field"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{module: "Otp", type: "file", file: "otp.js", imports: "import Otp from \"./otp.js\";"}
    ],
    headless: [
      anatomy: [
        parts: [
          input: [element: "input", note: "one single-char box per digit"],
          value: [element: "input", note: "hidden combined value for form submission"]
        ]
      ],
      aria_pattern: [
        pattern: "OTP / segmented input",
        keyboard: ["type: advance", "Backspace: previous", "Arrow: navigate", "Paste: distribute"]
      ],
      state_attributes: [],
      hooks: ["Otp"]
    ]
  ]
]
