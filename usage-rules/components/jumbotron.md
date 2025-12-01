# Jumbotron Component

Large, prominent hero section for showcasing important content.

**Documentation**: https://mishka.tools/chelekom/docs/jumbotron

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component jumbotron

# Generate with specific options
mix mishka.ui.gen.component jumbotron --variant default,gradient --color primary,dark

# Generate with custom module name
mix mishka.ui.gen.component jumbotron --module MyAppWeb.Components.CustomJumbotron
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
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Text size |
| `space` | `:string` | `"medium"` | Space between elements |
| `padding` | `:string` | `"large"` | Content padding |
| `border` | `:string` | `"none"` | Border size |
| `border_position` | `:string` | `nil` | Border position: `top`, `bottom`, `left`, `right` |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Content to display inside the jumbotron (headings, text, buttons, images).

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `shadow`, `bordered`, `gradient`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large`, `none`

## Usage Examples

### Basic Jumbotron

```heex
<.jumbotron>
  <h1 class="text-4xl font-bold">Welcome to Our App</h1>
  <p class="text-lg mt-4">The best solution for your needs.</p>
</.jumbotron>
```

### With Call to Action

```heex
<.jumbotron color="primary" variant="default" padding="quadruple_large">
  <div class="text-center text-white">
    <h1 class="text-5xl font-bold mb-4">Get Started Today</h1>
    <p class="text-xl mb-8">Join thousands of satisfied customers.</p>
    <.button color="white" size="large">Sign Up Free</.button>
  </div>
</.jumbotron>
```

### Different Variants

```heex
<.jumbotron variant="default" color="natural">Default</.jumbotron>
<.jumbotron variant="outline" color="primary">Outline</.jumbotron>
<.jumbotron variant="shadow" color="white">Shadow</.jumbotron>
<.jumbotron variant="gradient" color="primary">Gradient</.jumbotron>
```

### With Border

```heex
<.jumbotron variant="transparent" border="medium" border_position="left" color="primary">
  <h2 class="text-2xl font-bold">Featured Content</h2>
  <p>Important announcement or highlight.</p>
</.jumbotron>
```

### Dark Theme

```heex
<.jumbotron color="dark" variant="default" padding="triple_large">
  <div class="text-center">
    <h1 class="text-4xl font-bold text-white">Dark Mode Hero</h1>
    <p class="text-gray-300 mt-4">Elegant dark theme for your landing page.</p>
  </div>
</.jumbotron>
```

### With Background Image

```heex
<.jumbotron
  class="bg-cover bg-center relative"
  style="background-image: url('/images/hero-bg.jpg')"
  padding="quadruple_large"
>
  <div class="absolute inset-0 bg-black/50" />
  <div class="relative z-10 text-center text-white">
    <h1 class="text-5xl font-bold">Stunning Visuals</h1>
    <p class="text-xl mt-4">Create memorable experiences.</p>
  </div>
</.jumbotron>
```

## Common Patterns

### Landing Page Hero

```heex
<.jumbotron
  color="primary"
  variant="gradient"
  padding="quadruple_large"
  class="min-h-[600px] flex items-center"
>
  <div class="max-w-4xl mx-auto text-center text-white">
    <h1 class="text-6xl font-bold mb-6">Build Amazing Products</h1>
    <p class="text-xl mb-8 opacity-90">
      The all-in-one platform for modern teams to collaborate, create, and ship.
    </p>
    <div class="flex gap-4 justify-center">
      <.button color="white" size="large">Get Started</.button>
      <.button variant="outline" color="white" size="large">Learn More</.button>
    </div>
  </div>
</.jumbotron>
```

### Announcement Banner

```heex
<.jumbotron
  variant="default"
  color="info"
  padding="medium"
  class="text-center"
>
  <p class="flex items-center justify-center gap-2">
    <.icon name="hero-megaphone" class="size-5" />
    <span>New feature released! Check out our latest update.</span>
    <a href="/updates" class="underline font-semibold">Learn more</a>
  </p>
</.jumbotron>
```

### Feature Highlight

```heex
<.jumbotron
  variant="outline"
  color="success"
  padding="extra_large"
  border="small"
  border_position="left"
>
  <div class="flex items-start gap-4">
    <.icon name="hero-check-badge" class="size-10 text-success-500" />
    <div>
      <h3 class="text-2xl font-bold">100% Secure</h3>
      <p class="text-gray-600 mt-2">
        Your data is protected with enterprise-grade security.
      </p>
    </div>
  </div>
</.jumbotron>
```

### Pricing Header

```heex
<.jumbotron
  color="natural"
  variant="default"
  padding="triple_large"
  class="text-center"
>
  <h1 class="text-4xl font-bold">Simple, Transparent Pricing</h1>
  <p class="text-lg text-gray-600 mt-4 max-w-2xl mx-auto">
    No hidden fees. No surprises. Choose the plan that works for you.
  </p>
</.jumbotron>
```
