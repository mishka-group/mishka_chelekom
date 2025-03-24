[
  combobox: [
    name: "combobox",
    args: [
      variant: ["default", "bordered", "base"],
      color: [
        "base",
        "natural",
        "primary",
        "secondary",
        "success",
        "warning",
        "danger",
        "info",
        "silver",
        "misc",
        "dawn"
      ],
      size: ["extra_small", "small", "medium", "large", "extra_large"],
      space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
      padding: ["extra_small", "small", "medium", "large", "extra_large"],
      rounded: ["extra_small", "small", "medium", "large", "extra_large"],
      only: ["combobox"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: ["scroll_area"],
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
