[
  clipboard: [
    name: "clipboard",
    args: [
      only: ["clipboard"],
      helpers: [],
      module: "",
      component_prefix: nil
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
