[
  accordion: [
    name: "accordion",
    args: [
      variant: [
        "default",
        "bordered",
        "outline",
        "shadow",
        "gradient",
        "menu",
        "outline_separated",
        "bordered_seperated",
        "transparent",
        "base",
        "base_separated"
      ],
      color: [
        "base",
        "natural",
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
      padding: ["extra_small", "small", "medium", "large", "extra_large"],
      space: ["extra_small", "small", "medium", "large", "extra_large", "none"],
      type: ["accordion"],
      rounded: ["extra_small", "small", "medium", "large", "extra_large", "full"],
      only: ["accordion"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: ["icon"],
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
