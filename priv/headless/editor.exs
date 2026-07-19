[
  editor: [
    name: "editor",
    category: "forms",
    doc_url: "https://mishka.tools/chelekom/docs/headless/editor",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/",
    args: [type: ["editor"], only: ["editor"], helpers: [], module: ""],
    optional: [],
    necessary: [],

    # EXACT pins, never carets. @tiptap/core peer-depends on @tiptap/pm at an exact version, and
    # drift there yields two prosemirror-model instances — which fails at runtime with an opaque
    # RangeError, not at install time. The catalog-integrity test enforces the x.y.z shape.
    npm: [
      %{name: "@tiptap/core", version: "3.28.0"},
      %{name: "@tiptap/pm", version: "3.28.0"},
      %{name: "@tiptap/starter-kit", version: "3.28.0"}
    ],

    license: [
      spdx: "MIT",
      note:
        "@tiptap/* and the prosemirror-* packages they pull are MIT. Public npm, no license key, " <>
          "no telemetry. The paid surface (Tiptap Pro/Cloud) lives on a separate private registry " <>
          "and is deliberately not referenced here."
    ],

    # Multi-engine shape. Only :tiptap is populated today; a second engine is data plus one file,
    # with no change to the component's markup or public API. Every entry must register the same
    # hook module (asserted by the catalog-integrity test) so the template never branches.
    libs: [
      tiptap: [
        default: true,
        npm: [
          %{name: "@tiptap/core", version: "3.28.0"},
          %{name: "@tiptap/pm", version: "3.28.0"},
          %{name: "@tiptap/starter-kit", version: "3.28.0"}
        ],
        scripts: [
          %{
            module: "Editor",
            type: "file",
            file: "editor_tiptap.js",
            imports: "import Editor from \"./editor_tiptap.js\";"
          }
        ]
      ]
    ],
    # Written once into assets/vendor/ and never overwritten, so a developer's extension config
    # survives regeneration. The engine itself IS regenerated, which is why config cannot live there.
    user_files: [%{file: "editor_extensions.js"}],
    scripts: [
      %{
        module: "Editor",
        type: "file",
        file: "editor_tiptap.js",
        imports: "import Editor from \"./editor_tiptap.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "div",
          data_attributes: ["data-disabled", "data-readonly", "data-empty", "data-focused"],
          note:
            "the styled wrapper — NOT the hook. Keeps a live `class`, unlike the ignored surface",
          required: true
        ],
        parts: [
          toolbar: [
            element: "div",
            role: "toolbar",
            aria: ["aria-label", "aria-controls"],
            note:
              "optional slot; buttons tagged data-editor-command are wired by the engine and get " <>
                "data-active when their mark/node is active"
          ],
          value: [
            element: "textarea",
            note:
              "hidden mirror carrying `name` — what the form submits. Never give it phx-change: " <>
                "form recovery skips elements that have one"
          ],
          surface: [
            element: "div",
            role: "textbox",
            aria: ["aria-multiline", "aria-labelledby", "aria-describedby"],
            data_attributes: [
              "data-root-id",
              "data-value-id",
              "data-format",
              "data-value",
              "data-editable",
              "data-debounce",
              "data-on-change"
            ],
            note:
              "carries phx-hook + phx-update=\"ignore\"; id is <root id>-surface. data-* is the " <>
                "only channel the server can reach it through"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Rich text editor (multiline textbox + toolbar)",
        keyboard: [
          "Standard contenteditable editing",
          "Mod+B / Mod+I / Mod+Shift+X — bold / italic / strike",
          "Mod+Z / Mod+Shift+Z — undo / redo (ProseMirror history)",
          "Tab — leaves the editor (it is one tab stop, not a tab trap)"
        ]
      ],
      state_attributes: ["data-disabled", "data-readonly", "data-empty", "data-focused"],
      hooks: ["Editor"]
    ]
  ]
]
