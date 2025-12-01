# Image Component

Image component with responsive options, lazy loading, and customizable styling.

**Documentation**: https://mishka.tools/chelekom/docs/image

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component image

# Generate with specific options
mix mishka.ui.gen.component image --rounded medium,large,full

# Generate with custom module name
mix mishka.ui.gen.component image --module MyAppWeb.Components.CustomImage
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `src` | `:string` | **required** | Image source URL |
| `alt` | `:string` | `nil` | Alt text for accessibility |
| `width` | `:integer` | `nil` | Image width |
| `height` | `:integer` | `nil` | Image height |
| `loading` | `:string` | `nil` | Loading behavior: `lazy`, `eager` |
| `fetchpriority` | `:string` | `nil` | Fetch priority: `high`, `low`, `auto` |
| `rounded` | `:string` | `nil` | Border radius |
| `shadow` | `:string` | `nil` | Shadow style |
| `srcset` | `:string` | `nil` | Responsive image sources |
| `sizes` | `:string` | `nil` | Responsive sizes |
| `class` | `:any` | `nil` | Custom CSS class |

## Available Options

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`

### Shadow
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Image

```heex
<.image src="/images/photo.jpg" alt="Description" />
```

### With Dimensions

```heex
<.image src="/images/photo.jpg" alt="Photo" width={400} height={300} />
```

### Lazy Loading

```heex
<.image src="/images/below-fold.jpg" alt="Below fold" loading="lazy" />
```

### High Priority

```heex
<.image src="/images/hero.jpg" alt="Hero image" fetchpriority="high" />
```

### Rounded Corners

```heex
<.image src="/images/avatar.jpg" alt="Avatar" rounded="full" />
<.image src="/images/card.jpg" alt="Card" rounded="large" />
<.image src="/images/thumb.jpg" alt="Thumbnail" rounded="medium" />
```

### With Shadow

```heex
<.image src="/images/product.jpg" alt="Product" shadow="medium" />
<.image src="/images/feature.jpg" alt="Feature" shadow="large" />
<.image src="/images/hero.jpg" alt="Hero" shadow="extra_large" />
```

### Combined Styling

```heex
<.image
  src="/images/photo.jpg"
  alt="Styled photo"
  rounded="large"
  shadow="medium"
  class="w-full max-w-md"
/>
```

### Responsive Images

```heex
<.image
  src="/images/photo-800.jpg"
  srcset="/images/photo-400.jpg 400w, /images/photo-800.jpg 800w, /images/photo-1200.jpg 1200w"
  sizes="(max-width: 600px) 400px, (max-width: 1000px) 800px, 1200px"
  alt="Responsive photo"
/>
```

### Circle Avatar

```heex
<.image
  src="/images/user.jpg"
  alt="User avatar"
  rounded="full"
  width={100}
  height={100}
  class="object-cover"
/>
```

## Common Patterns

### Product Image

```heex
<.image
  src={@product.image_url}
  alt={@product.name}
  rounded="medium"
  shadow="small"
  loading="lazy"
  class="w-full aspect-square object-cover"
/>
```

### Hero Image

```heex
<.image
  src="/images/hero-banner.jpg"
  alt="Welcome to our site"
  fetchpriority="high"
  class="w-full h-96 object-cover"
/>
```

### Thumbnail Grid

```heex
<div class="grid grid-cols-4 gap-2">
  <.image
    :for={image <- @thumbnails}
    src={image.thumb_url}
    alt={image.title}
    rounded="small"
    loading="lazy"
    class="aspect-square object-cover cursor-pointer hover:opacity-80"
  />
</div>
```

### Profile Card

```heex
<div class="flex items-center gap-4">
  <.image
    src={@user.avatar}
    alt={@user.name}
    rounded="full"
    width={64}
    height={64}
    class="object-cover"
  />
  <div>
    <p class="font-semibold">{@user.name}</p>
    <p class="text-gray-500">{@user.role}</p>
  </div>
</div>
```

### Gallery Item

```heex
<div class="relative group">
  <.image
    src={@photo.url}
    alt={@photo.title}
    rounded="large"
    shadow="medium"
    loading="lazy"
    class="w-full aspect-[4/3] object-cover"
  />
  <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity rounded-large flex items-center justify-center">
    <.button variant="outline" color="white">View</.button>
  </div>
</div>
```

### Blog Featured Image

```heex
<article>
  <.image
    src={@post.featured_image}
    alt={@post.title}
    rounded="large"
    class="w-full aspect-video object-cover mb-6"
    loading="lazy"
  />
  <h1 class="text-3xl font-bold">{@post.title}</h1>
  <p class="text-gray-600 mt-4">{@post.excerpt}</p>
</article>
```

### Image with Fallback

```heex
<.image
  src={@user.avatar || "/images/default-avatar.png"}
  alt={@user.name}
  rounded="full"
  class="size-12 object-cover"
/>
```
