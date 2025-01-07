[
  combobox: [
    name: "combobox",
    args: [
      color: [
        "base",
        "white",
        "primary",
        "secondary",
        "dark",
        "success",
        "warning",
        "danger",
        "info",
        "silver",
        "misc",
        "dawn"
      ],
      size: ["extra_small", "small", "medium", "large", "extra_large"],
      rounded: ["extra_small", "small", "medium", "large", "extra_large"],
      only: ["combobox"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    scripts: [
      %{
        type: "file",
        file: "combobox.js",
        module: "Combobox",
        imports: "import Combobox from \"./combobox.js\";"
      }
    ]
  ]
]
