# Breadcrumb Component

Navigation component for displaying hierarchical page paths with customizable separators and icons.

**Documentation**: https://mishka.tools/chelekom/docs/breadcrumb

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component breadcrumb

# Generate with specific options
mix mishka.ui.gen.component breadcrumb --color primary,natural --size small,medium

# Generate with custom module name
mix mishka.ui.gen.component breadcrumb --module MyAppWeb.Components.CustomBreadcrumb
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"small"` | Overall size |
| `separator_icon` | `:string` | `"hero-chevron-right"` | Icon between items |
| `separator_icon_class` | `:string` | `"rtl:rotate-180"` | Separator icon styling |
| `separator_text` | `:string` | `nil` | Text separator (replaces icon) |
| `separator_text_class` | `:string` | `nil` | Text separator styling |
| `class` | `:any` | `nil` | Custom CSS class |
| `items_wrapper_class` | `:string` | `nil` | Items wrapper styling |

## Slots

### `item` Slot

| Attribute | Type | Description |
|-----------|------|-------------|
| `icon` | `:string` | Icon before item text |
| `link` | `:string` | Navigation URL (uses `navigate`) |
| `title` | `:string` | Tooltip text |
| `class` | `:any` | Item wrapper class |
| `icon_class` | `:string` | Icon styling class |
| `link_class` | `:string` | Link styling class |

### `inner_block` Slot

Additional custom content.

## Available Options

### Colors
`base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Breadcrumb

```heex
<.breadcrumb>
  <:item link="/">Home</:item>
  <:item link="/products">Products</:item>
  <:item link="/products/electronics">Electronics</:item>
  <:item>Laptops</:item>
</.breadcrumb>
```

### With Icons

```heex
<.breadcrumb>
  <:item icon="hero-home" link="/">Home</:item>
  <:item icon="hero-folder" link="/documents">Documents</:item>
  <:item icon="hero-document" link="/documents/reports">Reports</:item>
  <:item icon="hero-document-text">Annual Report 2024</:item>
</.breadcrumb>
```

### Different Colors

```heex
<.breadcrumb color="primary">
  <:item link="/">Home</:item>
  <:item link="/dashboard">Dashboard</:item>
  <:item>Settings</:item>
</.breadcrumb>

<.breadcrumb color="success">
  <:item link="/">Home</:item>
  <:item>Completed</:item>
</.breadcrumb>
```

### Different Sizes

```heex
<.breadcrumb size="extra_small">
  <:item link="/">Home</:item>
  <:item>Page</:item>
</.breadcrumb>

<.breadcrumb size="medium">
  <:item link="/">Home</:item>
  <:item>Page</:item>
</.breadcrumb>

<.breadcrumb size="extra_large">
  <:item link="/">Home</:item>
  <:item>Page</:item>
</.breadcrumb>
```

### Text Separator

```heex
<.breadcrumb separator_icon={nil} separator_text="/">
  <:item link="/">Home</:item>
  <:item link="/blog">Blog</:item>
  <:item>Article</:item>
</.breadcrumb>

<.breadcrumb separator_icon={nil} separator_text="•">
  <:item link="/">Home</:item>
  <:item link="/shop">Shop</:item>
  <:item>Cart</:item>
</.breadcrumb>
```

### Custom Separator Icon

```heex
<.breadcrumb separator_icon="hero-arrow-right">
  <:item link="/">Home</:item>
  <:item link="/step-1">Step 1</:item>
  <:item link="/step-2">Step 2</:item>
  <:item>Complete</:item>
</.breadcrumb>
```

### With Tooltips

```heex
<.breadcrumb>
  <:item link="/" title="Go to homepage">Home</:item>
  <:item link="/products" title="Browse all products">Products</:item>
  <:item title="Current page">Electronics</:item>
</.breadcrumb>
```

### Custom Styling

```heex
<.breadcrumb
  color="natural"
  size="medium"
  class="bg-gray-100 dark:bg-gray-800 p-3 rounded-lg"
>
  <:item link="/" icon="hero-home" icon_class="text-primary-500">Home</:item>
  <:item link="/dashboard" link_class="font-medium">Dashboard</:item>
  <:item class="font-bold">Current Page</:item>
</.breadcrumb>
```

## Common Patterns

### Dynamic Breadcrumb

```heex
<.breadcrumb color="natural">
  <:item :for={crumb <- @breadcrumbs} link={crumb.path} icon={crumb[:icon]}>
    {crumb.label}
  </:item>
  <:item>{@current_page}</:item>
</.breadcrumb>
```

### E-commerce Path

```heex
<.breadcrumb size="small" color="natural">
  <:item link="/" icon="hero-home">Home</:item>
  <:item link="/categories">Categories</:item>
  <:item link={~p"/categories/#{@category.slug}"}>{@category.name}</:item>
  <:item link={~p"/categories/#{@category.slug}/#{@subcategory.slug}"}>
    {@subcategory.name}
  </:item>
  <:item>{@product.name}</:item>
</.breadcrumb>
```

### Admin Panel Navigation

```heex
<.breadcrumb color="primary" size="small">
  <:item link="/admin" icon="hero-cog-6-tooth">Admin</:item>
  <:item link="/admin/users" icon="hero-users">Users</:item>
  <:item icon="hero-user">Edit User</:item>
</.breadcrumb>
```
