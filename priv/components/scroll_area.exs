[
  scroll_area: [
    name: "scroll_area",
    args: [
      padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
      only: ["scroll_area"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    scripts: [
      %{
        type: "file",
        file: "scrollArea.js",
        module: "ScrollArea",
        imports: "import ScrollArea from \"./scrollArea.js\";"
      }
    ]
  ]
]
