# GalleryFilter Hook

JavaScript hook for filtering gallery items by category with animated transitions.

## Hook Name

```javascript
GalleryFilter
```

## Used By Components

- `filterable_gallery`

## Data Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-default-filter` | `string` | `"All"` | Default active filter |

### Filter Button Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `data-gallery-filter` | - | Marks element as filter button |
| `data-category` | `string` | Filter category name |

### Gallery Item Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `data-gallery-item` | - | Marks element as gallery item |
| `data-category` | `string` | Item's category |

## Features

- **Category Filtering**: Show/hide items by category
- **Animated Transitions**: Smooth scale and opacity animations
- **Active State**: Visual indicator for active filter
- **All Filter**: Show all items option
- **Accessibility**: ARIA labels for filter buttons

## Element Structure

The hook expects this DOM structure:

```html
<div id="gallery-1" phx-hook="GalleryFilter" data-default-filter="All">
  <!-- Filter Buttons -->
  <div class="filter-buttons">
    <button data-gallery-filter data-category="All">All</button>
    <button data-gallery-filter data-category="Nature">Nature</button>
    <button data-gallery-filter data-category="City">City</button>
  </div>

  <!-- Gallery Items -->
  <div class="gallery-items">
    <div data-gallery-item data-category="Nature">
      <img src="/nature1.jpg" />
    </div>
    <div data-gallery-item data-category="City">
      <img src="/city1.jpg" />
    </div>
    <div data-gallery-item data-category="Nature">
      <img src="/nature2.jpg" />
    </div>
  </div>
</div>
```

## Usage Examples

### Basic Filterable Gallery

```heex
<.filterable_gallery
  id="photo-gallery"
  filters={["Nature", "Architecture", "People"]}
>
  <:item :for={photo <- @photos} category={photo.category}>
    <img src={photo.url} alt={photo.title} class="rounded-lg" />
  </:item>
</.filterable_gallery>
```

### With Custom Default Filter

```heex
<.filterable_gallery
  id="portfolio-gallery"
  filters={["Web", "Mobile", "Design"]}
  default_filter="Web"
>
  <:item :for={project <- @projects} category={project.type}>
    <div class="p-4">
      <img src={project.thumbnail} alt={project.name} />
      <h3>{project.name}</h3>
    </div>
  </:item>
</.filterable_gallery>
```

### With Custom Filter Slot

```heex
<.filterable_gallery
  id="product-gallery"
  filters={["Electronics", "Clothing", "Home"]}
>
  <:filter :let={category}>
    <.button
      data-gallery-filter
      data-category={category}
      variant="outline"
      size="small"
    >
      {category}
    </.button>
  </:filter>

  <:item :for={product <- @products} category={product.category}>
    <.card>
      <img src={product.image} alt={product.name} />
      <div class="p-4">
        <h4>{product.name}</h4>
        <p>${product.price}</p>
      </div>
    </.card>
  </:item>
</.filterable_gallery>
```

### With Animation Options

```heex
<.filterable_gallery
  id="animated-gallery"
  filters={["All", "Photos", "Videos"]}
  animation="fade"
  animation_size="large"
>
  <:item :for={media <- @media} category={media.type}>
    <div class="aspect-video">
      <%= if media.type == "Videos" do %>
        <video src={media.url} />
      <% else %>
        <img src={media.url} />
      <% end %>
    </div>
  </:item>
</.filterable_gallery>
```

### Grid Layout Gallery

```heex
<div class="container mx-auto">
  <.filterable_gallery
    id="grid-gallery"
    filters={["Landscape", "Portrait", "Abstract"]}
    class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4"
  >
    <:item :for={image <- @images} category={image.category}>
      <div class="overflow-hidden rounded-lg">
        <img
          src={image.src}
          alt={image.alt}
          class="w-full h-48 object-cover hover:scale-105 transition"
        />
      </div>
    </:item>
  </.filterable_gallery>
</div>
```

### Portfolio with Multiple Categories

```heex
<.filterable_gallery
  id="portfolio"
  filters={["All", "Branding", "UI/UX", "Print", "Web"]}
  default_filter="All"
>
  <:item :for={work <- @works} category={work.category}>
    <a href={~p"/portfolio/#{work.slug}"} class="block group">
      <div class="relative overflow-hidden rounded-xl">
        <img src={work.cover} alt={work.title} class="w-full" />
        <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition flex items-center justify-center">
          <span class="text-white font-medium">{work.title}</span>
        </div>
      </div>
    </a>
  </:item>
</.filterable_gallery>
```

## CSS Classes

| Class | Description |
|-------|-------------|
| `.filterable-gallery` | Main container class |
| `.filter-buttons` | Filter buttons wrapper |
| `.filter-btn` | Individual filter button |
| `.filter-btn.active` | Active filter state |
| `.gallery-items` | Items container |
| `[data-gallery-item]` | Individual gallery item |

## Animation Classes

Items use these classes during transitions:

```css
/* Hidden state */
[data-gallery-item].filtered-out {
  opacity: 0;
  transform: scale(0.8);
  display: none;
}

/* Visible state */
[data-gallery-item] {
  opacity: 1;
  transform: scale(1);
  transition: opacity 0.3s, transform 0.3s;
}
```

## JavaScript Integration

Register the hook in your `app.js`:

```javascript
import GalleryFilter from "./galleryFilter"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { GalleryFilter }
})
```
