# Carousel Hook

JavaScript hook for carousel/slideshow functionality with autoplay, touch navigation, and keyboard controls.

## Hook Name

```javascript
Carousel
```

## Used By Components

- `carousel`

## Data Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-active-index` | `number` | `1` | Initial active slide (1-indexed) |
| `data-autoplay` | `string` | `"false"` | Enable automatic slideshow |
| `data-autoplay-interval` | `number` | `5000` | Autoplay interval in milliseconds |
| `data-active-slide-class` | `string` | `"active-slide"` | CSS class for active slide |
| `data-hidden-slide-class` | `string` | `""` | CSS class for hidden slides |
| `data-active-indicator-class` | `string` | `""` | CSS class for active indicator |

## Features

- **Slide Navigation**: Next/previous buttons and dot indicators
- **Autoplay**: Automatic slide advancement with configurable interval
- **Touch Support**: Swipe gestures for mobile navigation
- **Keyboard Navigation**: Arrow keys for slide control
- **Pause on Hover**: Autoplay pauses when hovering
- **Indicator Sync**: Dot indicators stay in sync with current slide
- **Accessibility**: ARIA attributes for screen readers

## Element Structure

The hook expects this DOM structure:

```html
<div id="carousel-1" phx-hook="Carousel" data-autoplay="true">
  <!-- Navigation Buttons -->
  <button id="carousel-1-carousel-prev">Previous</button>
  <button id="carousel-1-carousel-next">Next</button>

  <!-- Slides -->
  <div id="carousel-1-carousel-slide-1" class="slide">Slide 1</div>
  <div id="carousel-1-carousel-slide-2" class="slide">Slide 2</div>

  <!-- Indicators -->
  <div class="carousel-indicators">
    <button data-carousel-indicator="1"></button>
    <button data-carousel-indicator="2"></button>
  </div>
</div>
```

## Usage Examples

### Basic Carousel

```heex
<.carousel id="my-carousel">
  <:slide image="/images/slide1.jpg">
    <h2>Slide 1</h2>
  </:slide>
  <:slide image="/images/slide2.jpg">
    <h2>Slide 2</h2>
  </:slide>
</.carousel>
```

### With Autoplay

```heex
<.carousel
  id="auto-carousel"
  autoplay={true}
  autoplay_interval={3000}
>
  <:slide image="/images/promo1.jpg" />
  <:slide image="/images/promo2.jpg" />
  <:slide image="/images/promo3.jpg" />
</.carousel>
```

### With Indicators

```heex
<.carousel id="hero-slider" indicator={true}>
  <:slide image="/images/hero1.jpg">
    <h1>Welcome</h1>
  </:slide>
  <:slide image="/images/hero2.jpg">
    <h1>Features</h1>
  </:slide>
</.carousel>
```

### Custom Slide Classes

```heex
<.carousel
  id="custom-carousel"
  active_slide_class="opacity-100 scale-100"
  hidden_slide_class="opacity-0 scale-95"
>
  <:slide image="/images/1.jpg" />
  <:slide image="/images/2.jpg" />
</.carousel>
```

## Keyboard Controls

| Key | Action |
|-----|--------|
| `ArrowLeft` | Go to previous slide |
| `ArrowRight` | Go to next slide |

## Touch Gestures

| Gesture | Action |
|---------|--------|
| Swipe Left | Go to next slide |
| Swipe Right | Go to previous slide |

## JavaScript Integration

Register the hook in your `app.js`:

```javascript
import Carousel from "./carousel"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { Carousel }
})
```
