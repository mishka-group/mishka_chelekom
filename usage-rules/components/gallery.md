# Gallery Component

Media gallery with grid, masonry, and featured layouts, plus filterable gallery support.

**Documentation**: https://mishka.tools/chelekom/docs/gallery

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component gallery

# Generate with specific options
mix mishka.ui.gen.component gallery --rounded medium,large

# Generate specific component types only
mix mishka.ui.gen.component gallery --type gallery,filterable_gallery

# Generate with custom module name
mix mishka.ui.gen.component gallery --module MyAppWeb.Components.CustomGallery
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | `galleryFilter.js` |

## Component Types

| Component | Description |
|-----------|-------------|
| `gallery/1` | Standard grid gallery |
| `gallery_media/1` | Individual media item |
| `filterable_gallery/1` | Gallery with category filtering |

## Attributes

### `gallery/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `type` | `:string` | `"default"` | Layout: `default`, `masonry`, `featured` |
| `cols` | `:integer` | `3` | Number of columns |
| `gap` | `:string` | `"medium"` | Space between items |
| `class` | `:any` | `nil` | Custom CSS class |

### `gallery_media/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `src` | `:string` | **required** | Media source URL |
| `alt` | `:string` | `nil` | Alt text |
| `rounded` | `:string` | `"medium"` | Border radius |
| `shadow` | `:string` | `nil` | Shadow style |
| `class` | `:any` | `nil` | Custom CSS class |

### `filterable_gallery/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `cols` | `:integer` | `3` | Number of columns |
| `gap` | `:string` | `"medium"` | Space between items |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Gallery media items.

### `filter` Slot (for filterable_gallery)

Filter button items.

## Available Options

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Gallery Types
`default`, `masonry`, `featured`

## Usage Examples

### Basic Gallery

```heex
<.gallery cols={3} gap="medium">
  <.gallery_media src="/images/photo1.jpg" alt="Photo 1" />
  <.gallery_media src="/images/photo2.jpg" alt="Photo 2" />
  <.gallery_media src="/images/photo3.jpg" alt="Photo 3" />
  <.gallery_media src="/images/photo4.jpg" alt="Photo 4" />
  <.gallery_media src="/images/photo5.jpg" alt="Photo 5" />
  <.gallery_media src="/images/photo6.jpg" alt="Photo 6" />
</.gallery>
```

### Masonry Layout

```heex
<.gallery type="masonry" cols={4} gap="small">
  <.gallery_media :for={image <- @images} src={image.url} alt={image.title} />
</.gallery>
```

### Featured Layout

```heex
<.gallery type="featured" gap="medium">
  <.gallery_media src="/images/featured.jpg" alt="Featured" class="col-span-2 row-span-2" />
  <.gallery_media src="/images/small1.jpg" alt="Small 1" />
  <.gallery_media src="/images/small2.jpg" alt="Small 2" />
  <.gallery_media src="/images/small3.jpg" alt="Small 3" />
  <.gallery_media src="/images/small4.jpg" alt="Small 4" />
</.gallery>
```

### With Rounded Corners

```heex
<.gallery cols={3}>
  <.gallery_media src="/images/1.jpg" rounded="large" />
  <.gallery_media src="/images/2.jpg" rounded="large" />
  <.gallery_media src="/images/3.jpg" rounded="large" />
</.gallery>
```

### With Shadows

```heex
<.gallery cols={3}>
  <.gallery_media src="/images/1.jpg" shadow="medium" />
  <.gallery_media src="/images/2.jpg" shadow="large" />
  <.gallery_media src="/images/3.jpg" shadow="extra_large" />
</.gallery>
```

### Filterable Gallery

```heex
<.filterable_gallery id="portfolio" cols={3}>
  <:filter category="all">All</:filter>
  <:filter category="web">Web Design</:filter>
  <:filter category="mobile">Mobile Apps</:filter>
  <:filter category="branding">Branding</:filter>

  <.gallery_media src="/images/web1.jpg" category="web" />
  <.gallery_media src="/images/mobile1.jpg" category="mobile" />
  <.gallery_media src="/images/brand1.jpg" category="branding" />
  <.gallery_media src="/images/web2.jpg" category="web" />
  <.gallery_media src="/images/mobile2.jpg" category="mobile" />
</.filterable_gallery>
```

### Different Column Counts

```heex
<.gallery cols={2}>Two columns</.gallery>
<.gallery cols={3}>Three columns</.gallery>
<.gallery cols={4}>Four columns</.gallery>
<.gallery cols={5}>Five columns</.gallery>
```

## Common Patterns

### Product Image Gallery

```heex
<.gallery cols={4} gap="small" class="mt-4">
  <.gallery_media
    :for={image <- @product.images}
    src={image.thumbnail_url}
    alt={image.alt_text}
    rounded="medium"
    class="cursor-pointer hover:opacity-80 transition"
    phx-click="select_image"
    phx-value-id={image.id}
  />
</.gallery>
```

### Portfolio Gallery

```heex
<.filterable_gallery id="portfolio" cols={3} gap="large">
  <:filter category="all" class="active">All Projects</:filter>
  <:filter category="design">Design</:filter>
  <:filter category="development">Development</:filter>
  <:filter category="marketing">Marketing</:filter>

  <.gallery_media
    :for={project <- @projects}
    src={project.cover_image}
    alt={project.title}
    category={project.category}
    rounded="large"
    shadow="medium"
  >
    <div class="absolute inset-0 bg-black/50 opacity-0 hover:opacity-100 transition flex items-center justify-center">
      <p class="text-white font-bold">{project.title}</p>
    </div>
  </.gallery_media>
</.filterable_gallery>
```

### Image Grid with Overlay

```heex
<.gallery cols={3} gap="medium">
  <div :for={image <- @images} class="relative group">
    <.gallery_media src={image.url} alt={image.title} rounded="large" />
    <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition rounded-large flex items-end p-4">
      <div class="text-white">
        <p class="font-bold">{image.title}</p>
        <p class="text-sm">{image.description}</p>
      </div>
    </div>
  </div>
</.gallery>
```

## JavaScript Hook

The filterable gallery uses the `GalleryFilter` JavaScript hook. This is automatically configured when you generate the component.

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```
