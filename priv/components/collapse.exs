[
  collapse: [
    name: "collapse",
    category: "general",
    doc_url: "https://mishka.tools/chelekom/docs/collapse",
    args: [
      only: ["collapse"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    required: false,
    precompile: false,
    scripts: [
      %{
        type: "file",
        file: "collapsible.js",
        module: "Collapsible",
        imports: "import Collapsible from \"./collapsible.js\";"
      }
    ]
  ]
]
