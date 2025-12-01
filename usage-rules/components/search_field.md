# Search Field Component

Search input with customizable styling and optional search button.

**Documentation**: https://mishka.tools/chelekom/docs/forms/search-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component search_field
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
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Input size |
| `rounded` | `:string` | `"medium"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `label` | `:string` | `nil` | Label text |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `description` | `:string` | `nil` | Description text |
| `floating` | `:string` | `nil` | Floating label |
| `search_button` | `:boolean` | `false` | Show search button |

## Slots

### `start_section` / `end_section` Slots

Content before/after input.

## Available Options

### Variants
`base`, `default`, `outline`, `shadow`, `bordered`, `transparent`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Search Field

```heex
<.search_field name="query" placeholder="Search..." />
```

### With Label

```heex
<.search_field name="search" label="Search" placeholder="Type to search..." />
```

### With Search Button

```heex
<.search_field name="query" placeholder="Search..." search_button />
```

### With Icon

```heex
<.search_field name="query" placeholder="Search...">
  <:start_section>
    <.icon name="hero-magnifying-glass" class="size-4" />
  </:start_section>
</.search_field>
```

### Different Variants

```heex
<.search_field name="query" variant="default" placeholder="Default" />
<.search_field name="query" variant="outline" placeholder="Outline" />
<.search_field name="query" variant="shadow" placeholder="Shadow" />
```

### Different Colors

```heex
<.search_field name="query" color="primary" placeholder="Primary" />
<.search_field name="query" color="success" placeholder="Success" />
```

### Floating Label

```heex
<.search_field
  name="query"
  floating="outer"
  label="Search"
  placeholder="Type here..."
/>
```

### With Description

```heex
<.search_field
  name="query"
  label="Search"
  description="Search for products, categories, or brands"
  placeholder="What are you looking for?"
/>
```

## Common Patterns

### Header Search

```heex
<.form for={%{}} action="/search" method="get" class="flex-1 max-w-md">
  <.search_field
    name="q"
    placeholder="Search products..."
    variant="outline"
    rounded="full"
    search_button
  >
    <:start_section>
      <.icon name="hero-magnifying-glass" class="size-4" />
    </:start_section>
  </.search_field>
</.form>
```

### Live Search

```heex
<.search_field
  name="query"
  placeholder="Search..."
  phx-debounce="300"
  phx-change="search"
  value={@query}
>
  <:start_section>
    <.icon name="hero-magnifying-glass" class="size-4" />
  </:start_section>
  <:end_section>
    <.icon :if={@searching} name="hero-arrow-path" class="size-4 animate-spin" />
  </:end_section>
</.search_field>
```

### Filter Search

```heex
<div class="flex gap-2">
  <.search_field name="query" placeholder="Filter items..." class="flex-1" />
  <.button variant="outline">
    <.icon name="hero-funnel" class="size-4" />
  </.button>
</div>
```
