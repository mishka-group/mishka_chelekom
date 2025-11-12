[
  carousel: [
    name: "carousel",
    args: [
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
      only: ["carousel"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: ["image", "icon"],
    scripts: [
      %{
        type: "file",
        file: "carousel.js",
        module: "Carousel",
        imports: "import Carousel from \"./carousel.js\";"
      }
    ]
  ]
]
