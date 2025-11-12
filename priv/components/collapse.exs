[
  collapse: [
    name: "collapse",
    args: [
      only: ["collapse"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
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
