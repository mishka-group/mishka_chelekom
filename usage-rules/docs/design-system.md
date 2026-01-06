# Mishka Chelekom Design System Documentation

## Overview

The Chelekom Design System is a comprehensive collection of reusable components, patterns, and guidelines that ensure consistency and efficiency across your applications. It functions as a centralized resource for both designers and developers, offering standardized elements.

## Core Design Elements

### Typography

The system provides eight predefined typography scales:

| Scale | Usage |
|-------|-------|
| `extra_small` | Fine print, captions |
| `small` | Secondary text, labels |
| `medium` | Body text (default) |
| `large` | Emphasized text |
| `extra_large` | Subheadings |
| `double_large` | Section headings |
| `triple_large` | Page headings |
| `quadruple_large` | Hero text |

These cover headings (H1-H6) through body text, with careful attention to font sizing, weight, and spacing.

### Sizing System

Mishka Chelekom offers five primary size values applicable to borders, text sizes, border radius, and other properties:

- `extra_small`
- `small`
- `medium`
- `large`
- `extra_large`

Certain components support additional larger options: `double_large`, `triple_large`, `quadruple_large`.

### Shadow Options

The system includes five shadow depth levels for consistent depth perception:

| Level | Use Case |
|-------|----------|
| `extra_small` | Subtle elevation |
| `small` | Cards, buttons |
| `medium` | Dropdowns, popovers |
| `large` | Modals, dialogs |
| `extra_large` | Full-screen overlays |

### Font Weights

Available weights applied via Tailwind font weight classes through a `font_weight` prop:

- `thin`
- `light`
- `normal`
- `medium`
- `semibold`
- `bold`
- `extrabold`

### Color Palette

The system features an extensive color palette organized by hue:

| Category | Description |
|----------|-------------|
| Neutrals | Base, natural, white, dark, silver |
| Primary | Brand primary colors (cyan/teal) |
| Secondary | Brand secondary colors (blue) |
| Success | Positive states (green) |
| Warning | Caution states (yellow/orange) |
| Danger | Error states (red) |
| Info | Informational states (light blue) |
| Misc | Purple accent colors |
| Dawn | Warm brown/orange tones |

Each color includes multiple tonal variations for light/dark modes and different states (hover, active, disabled).

## Component Categories

### Navigation Components
- Navbar, Sidebar, Menu, Mega Menu
- Breadcrumb, Pagination, Tabs
- Speed Dial, Footer

### Feedback Components
- Alert, Toast, Banner
- Progress, Spinner, Skeleton
- Rating, Stepper

### Media Components
- Image, Video, Gallery
- Carousel, Avatar
- Device Mockup

### Overlay Components
- Modal, Drawer, Dropdown
- Popover, Tooltip
- Overlay

### General UI Components
- Button, Badge, Card
- Accordion, Collapse
- List, Table, Timeline
- Divider, Indicator
- Typography, Icon

### Form Components
- Input Field, Text Field, Textarea
- Checkbox, Radio, Toggle
- Select, Combobox
- Date/Time Picker
- File Upload, Range Slider
- And more...

## Customization

### CSS Variables

Override design tokens in `priv/mishka_chelekom/config.exs`:

```elixir
config :mishka_chelekom,
  css_overrides: %{
    primary_light: "#your-color",
    primary_dark: "#your-color"
  }
```

### Component Filters

Limit generated variants to reduce bundle size:

```elixir
config :mishka_chelekom,
  component_colors: ["primary", "danger", "success"],
  component_variants: ["default", "outline"],
  component_sizes: ["small", "medium", "large"]
```

## Best Practices

1. **Consistency** - Use design tokens instead of hardcoded values
2. **Accessibility** - Follow WCAG guidelines for color contrast
3. **Responsiveness** - Test components across screen sizes
4. **Dark Mode** - Ensure all components work in both light and dark themes
5. **Performance** - Only generate the variants you need
