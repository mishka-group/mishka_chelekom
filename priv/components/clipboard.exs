[
  clipboard: [
    name: "clipboard",
    category: "general",
    doc_url: "https://mishka.tools/chelekom/docs/clipboard",
    args: [
      only: ["clipboard"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    scripts: [
      %{
        type: "file",
        file: "clipboard.js",
        module: "Clipboard",
        imports: "import Clipboard from \"./clipboard.js\";"
      }
    ]
  ]
]
