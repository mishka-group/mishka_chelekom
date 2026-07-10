# Carousel Component

Dynamic image/media carousel with navigation controls, indicators, and autoplay support.

**Documentation**: https://mishka.tools/chelekom/docs/carousel

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component carousel
mix mishka.ui.gen.component carousel --color primary,natural --size medium,large
mix mishka.ui.gen.component carousel --module MyAppWeb.Components.CustomCarousel
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `image`, `icon` |
| **Optional** | None |
| **JavaScript** | `carousel.js` |

## Attributes

| Attribute | Type | Default | Description / Allowed values |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `overlay` | `:string` | `"natural"` | `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"large"` | `extra_small`, `small`, `medium`, `large`, `extra_large` — text/content size |
| `padding` | `:string` | `"medium"` | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `text_position` | `:string` | `"center"` | `start`, `end`, `center` |
| `indicator` | `:boolean` | `false` | Show navigation dots |
| `control` | `:boolean` | `true` | Show navigation arrows |
| `autoplay` | `:boolean` | `false` | Auto-advance slides |
| `autoplay_interval` | `:integer` | `5000` | Milliseconds between slides |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `slide`

| Attribute | Type | Description |
|-----------|------|-------------|
| `image` | `:string` | Slide image URL |
| `image_class` | `:string` | Image styling class |
| `title` | `:string` | Slide title |
| `title_class` | `:string` | Title styling class |
| `description` | `:string` | Slide description |
| `description_class` | `:string` | Description styling class |
| `content_position` | `:string` | `start`, `end`, `center`, `between`, `around` |
| `active` | `:boolean` | Initially active slide |
| `navigate` | `:string` | LiveView navigation path |
| `patch` | `:string` | LiveView patch path |
| `href` | `:string` | External URL |
| `wrapper_class` | `:string` | Slide wrapper class |

### `inner_block`

Custom content for a slide (e.g. a `<.button>`), rendered inside the slide slot.

## Usage Examples

### Basic

```heex
<.carousel id="hero-carousel">
  <:slide image="/images/slide1.jpg" title="Welcome" description="First slide" />
  <:slide image="/images/slide2.jpg" title="Features" description="Second slide" />
  <:slide image="/images/slide3.jpg" title="Contact" description="Third slide" />
</.carousel>
```

### Indicators, autoplay, no controls

```heex
<.carousel id="gallery" indicator={true}>
  <:slide image="/images/photo1.jpg" active={true} />
  <:slide image="/images/photo2.jpg" />
</.carousel>

<.carousel id="promo-carousel" autoplay={true} autoplay_interval={3000} indicator={true}>
  <:slide image="/images/promo1.jpg" title="Special Offer" />
  <:slide image="/images/promo2.jpg" title="New Arrivals" />
</.carousel>

<.carousel id="auto-carousel" control={false} autoplay={true}>
  <:slide image="/images/banner1.jpg" />
  <:slide image="/images/banner2.jpg" />
</.carousel>
```

### Navigation links (`navigate`, `patch`, `href`)

```heex
<.carousel id="nav-carousel">
  <:slide image="/images/product1.jpg" title="Product A" navigate={~p"/products/a"} />
  <:slide image="/images/product2.jpg" title="Product B" patch={~p"/products/b"} />
  <:slide image="/images/external.jpg" title="External Link" href="https://example.com" />
</.carousel>
```

### Text position, size/padding, overlay color

```heex
<.carousel id="text-start" text_position="start">
  <:slide image="/images/slide.jpg" title="Left Aligned" description="Text on left" />
</.carousel>

<.carousel id="small-carousel" size="small" padding="small">
  <:slide image="/images/slide.jpg" title="Small" />
</.carousel>

<.carousel id="primary-carousel" overlay="primary">
  <:slide image="/images/slide.jpg" title="Primary Theme" />
</.carousel>
```

### Custom content position/classes and `inner_block`

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
  <:slide image="/images/hero2.jpg" title="New Collection" navigate={~p"/new-arrivals"} />
</.carousel>
```

## Common Patterns

### Product gallery (looped slides)

```heex
<.carousel
  id={"product-gallery-#{@product.id}"}
  indicator={true}
  control={true}
  size="medium"
  class="aspect-square"
>
  <:slide :for={image <- @product.images} image={image.url} image_class="object-contain" />
</.carousel>
```

### Testimonials

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

Uses the `Carousel` JS hook for slide navigation, auto-configured on generation. Registered in `assets/js/app.js`:

```javascript
import MishkaComponents from "../vendor/mishka_components.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...MishkaComponents }
});
```
