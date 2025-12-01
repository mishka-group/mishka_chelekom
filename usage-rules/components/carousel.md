# Carousel Component

Dynamic image/media carousel with navigation controls, indicators, and autoplay support.

**Documentation**: https://mishka.tools/chelekom/docs/carousel

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component carousel

# Generate with specific options
mix mishka.ui.gen.component carousel --color primary,natural --size medium,large

# Generate with custom module name
mix mishka.ui.gen.component carousel --module MyAppWeb.Components.CustomCarousel
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `image`, `icon` |
| **Optional** | None |
| **JavaScript** | `carousel.js` |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `overlay` | `:string` | `"natural"` | Overlay color theme |
| `size` | `:string` | `"large"` | Text and content size |
| `padding` | `:string` | `"medium"` | Content padding |
| `text_position` | `:string` | `"center"` | Text alignment: `start`, `end`, `center` |
| `indicator` | `:boolean` | `false` | Show navigation dots |
| `control` | `:boolean` | `true` | Show navigation arrows |
| `autoplay` | `:boolean` | `false` | Auto-advance slides |
| `autoplay_interval` | `:integer` | `5000` | Milliseconds between slides |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `slide` Slot

| Attribute | Type | Description |
|-----------|------|-------------|
| `image` | `:string` | Slide image URL |
| `image_class` | `:string` | Image styling class |
| `title` | `:string` | Slide title |
| `title_class` | `:string` | Title styling class |
| `description` | `:string` | Slide description |
| `description_class` | `:string` | Description styling class |
| `content_position` | `:string` | Position: `start`, `end`, `center`, `between`, `around` |
| `active` | `:boolean` | Initially active slide |
| `navigate` | `:string` | LiveView navigation path |
| `patch` | `:string` | LiveView patch path |
| `href` | `:string` | External URL |
| `wrapper_class` | `:string` | Slide wrapper class |

### `inner_block` Slot

Custom content for slides.

## Available Options

### Overlay Colors
`base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Text Position
`start`, `end`, `center`

### Content Position
`start`, `end`, `center`, `between`, `around`

## Usage Examples

### Basic Carousel

```heex
<.carousel id="hero-carousel">
  <:slide image="/images/slide1.jpg" title="Welcome" description="First slide" />
  <:slide image="/images/slide2.jpg" title="Features" description="Second slide" />
  <:slide image="/images/slide3.jpg" title="Contact" description="Third slide" />
</.carousel>
```

### With Indicators

```heex
<.carousel id="gallery" indicator={true}>
  <:slide image="/images/photo1.jpg" active={true} />
  <:slide image="/images/photo2.jpg" />
  <:slide image="/images/photo3.jpg" />
</.carousel>
```

### Autoplay Carousel

```heex
<.carousel
  id="promo-carousel"
  autoplay={true}
  autoplay_interval={3000}
  indicator={true}
>
  <:slide image="/images/promo1.jpg" title="Special Offer" />
  <:slide image="/images/promo2.jpg" title="New Arrivals" />
  <:slide image="/images/promo3.jpg" title="Best Sellers" />
</.carousel>
```

### Without Controls

```heex
<.carousel id="auto-carousel" control={false} autoplay={true}>
  <:slide image="/images/banner1.jpg" />
  <:slide image="/images/banner2.jpg" />
</.carousel>
```

### With Navigation Links

```heex
<.carousel id="nav-carousel">
  <:slide
    image="/images/product1.jpg"
    title="Product A"
    description="Click to view"
    navigate={~p"/products/a"}
  />
  <:slide
    image="/images/product2.jpg"
    title="Product B"
    description="Click to view"
    patch={~p"/products/b"}
  />
  <:slide
    image="/images/external.jpg"
    title="External Link"
    href="https://example.com"
  />
</.carousel>
```

### Different Text Positions

```heex
<.carousel id="text-positions" text_position="start">
  <:slide image="/images/slide.jpg" title="Left Aligned" description="Text on left" />
</.carousel>

<.carousel id="text-center" text_position="center">
  <:slide image="/images/slide.jpg" title="Centered" description="Text in center" />
</.carousel>

<.carousel id="text-end" text_position="end">
  <:slide image="/images/slide.jpg" title="Right Aligned" description="Text on right" />
</.carousel>
```

### Different Sizes

```heex
<.carousel id="small-carousel" size="small" padding="small">
  <:slide image="/images/slide.jpg" title="Small" />
</.carousel>

<.carousel id="large-carousel" size="extra_large" padding="extra_large">
  <:slide image="/images/slide.jpg" title="Extra Large" />
</.carousel>
```

### Colored Overlay

```heex
<.carousel id="primary-carousel" overlay="primary">
  <:slide image="/images/slide.jpg" title="Primary Theme" />
</.carousel>

<.carousel id="dark-carousel" overlay="dark">
  <:slide image="/images/slide.jpg" title="Dark Theme" />
</.carousel>
```

### Custom Content Position

```heex
<.carousel id="custom-carousel">
  <:slide
    image="/images/hero.jpg"
    title="Hero Title"
    description="Hero description text"
    content_position="start"
    title_class="text-4xl font-bold"
    description_class="text-lg"
  />
</.carousel>
```

## Common Patterns

### Hero Banner Carousel

```heex
<.carousel
  id="hero-banner"
  autoplay={true}
  autoplay_interval={5000}
  indicator={true}
  size="extra_large"
  class="h-[600px]"
>
  <:slide
    image="/images/hero1.jpg"
    title="Welcome to Our Store"
    description="Discover amazing products"
    content_position="center"
    title_class="text-5xl font-bold mb-4"
    description_class="text-xl mb-6"
  >
    <.button color="primary" size="large">Shop Now</.button>
  </:slide>
  <:slide
    image="/images/hero2.jpg"
    title="New Collection"
    description="Check out our latest arrivals"
    navigate={~p"/new-arrivals"}
  />
</.carousel>
```

### Product Gallery

```heex
<.carousel
  id={"product-gallery-#{@product.id}"}
  indicator={true}
  control={true}
  size="medium"
  class="aspect-square"
>
  <:slide
    :for={image <- @product.images}
    image={image.url}
    image_class="object-contain"
  />
</.carousel>
```

### Testimonials Carousel

```heex
<.carousel
  id="testimonials"
  autoplay={true}
  autoplay_interval={7000}
  overlay="primary"
  text_position="center"
>
  <:slide
    :for={testimonial <- @testimonials}
    image={testimonial.background}
    title={"\\"#{testimonial.quote}\\""}
    description={"— #{testimonial.author}"}
    title_class="text-2xl italic"
  />
</.carousel>
```

## JavaScript Hook

The carousel uses the `Carousel` JavaScript hook for slide navigation. This is automatically configured when you generate the component.

The hook is registered in `assets/js/app.js`:

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```
