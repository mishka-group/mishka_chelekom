[
  dropdown: [
    name: "dropdown",
    category: "navigations",
    doc_url: "https://mishka.tools/chelekom/docs/dropdown",
    args: [
      variant: ["default", "outline", "bordered", "shadow", "gradient", "base"],
      color: [
        "base",
        "natural",
        "white",
        "dark",
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
      space: ["extra_small", "small", "medium", "large", "extra_large"],
      rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
      padding: ["extra_small", "small", "medium", "large", "extra_large", "none"],
      type: ["dropdown", "dropdown_trigger", "dropdown_content"],
      only: ["dropdown", "dropdown_trigger", "dropdown_content"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    scripts: [
      %{
        type: "file",
        file: "floating.js",
        module: "Floating",
        imports: "import Floating from \"./floating.js\";"
      }
    ]
  ]
]
