[
  avatar: [
    name: "avatar",
    category: "media",
    doc_url: "https://mishka.tools/chelekom/docs/headless/avatar",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/",
    args: [type: ["avatar"], only: ["avatar"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Avatar",
        type: "file",
        file: "avatar.js",
        imports: "import Avatar from \"./avatar.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "span",
          data_attributes: ["data-status"],
          note: "carries the Avatar hook; data-status is idle|loading|loaded|error",
          required: true
        ],
        parts: [
          image: [element: "img", aria: ["alt"], note: "revealed only once it has loaded"],
          fallback: [
            element: "span",
            note: "shown until the image loads; data-delay (ms) defers its appearance"
          ]
        ]
      ],
      aria_pattern: [pattern: "Avatar (no formal APG pattern)", keyboard: []],
      state_attributes: ["data-status"],
      hooks: ["Avatar"]
    ]
  ]
]
