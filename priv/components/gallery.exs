[
  gallery: [
    name: "gallery",
    args: [
      rounded: ["extra_small", "small", "medium", "large", "extra_large", "none"],
      type: ["gallery", "filterable_gallery"],
      only: ["gallery", "gallery_media", "filterable_gallery"],
      helpers: [],
      module: ""
    ],
    optional: [],
    necessary: [],
    scripts: [
      %{
        type: "file",
        file: "galleryFilter.js",
        module: "GalleryFilter",
        imports: "import GalleryFilter from \"./galleryFilter.js\";"
      }
    ]
  ]
]
