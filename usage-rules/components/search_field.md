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
| `variant` | `:string` | `"base"` | Style variant — `base`, `default`, `outline`, `shadow`, `bordered`, `transparent` |
| `color` | `:string` | `"base"` | Color theme — `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver` |
| `size` | `:string` | `"medium"` | Input size — `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `rounded` | `:string` | `"medium"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `label` | `:string` | `nil` | Label text |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `description` | `:string` | `nil` | Description text |
| `floating` | `:string` | `nil` | Floating label |
| `search_button` | `:boolean` | `false` | Show search button |

## Slots

- `start_section` — content before input (e.g. search icon)
- `end_section` — content after input (e.g. loading spinner)

## Usage Examples

### Basic, label, button, icon

```heex
<.search_field name="query" placeholder="Search..." />

<.search_field name="search" label="Search" placeholder="Type to search..." />

<.search_field name="query" placeholder="Search..." search_button />

<.search_field name="query" placeholder="Search...">
  <:start_section>
    <.icon name="hero-magnifying-glass" class="size-4" />
  </:start_section>
</.search_field>
```

### Variants and colors

```heex
<.search_field name="query" variant="outline" color="primary" placeholder="Outline primary" />
<.search_field name="query" variant="shadow" color="success" placeholder="Shadow success" />
```

### Floating label and description

```heex
<.search_field name="query" floating="outer" label="Search" placeholder="Type here..." />

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

### Live Search (debounced, with loading indicator)

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

### Filter Search (paired with external button)

```heex
<div class="flex gap-2">
  <.search_field name="query" placeholder="Filter items..." class="flex-1" />
  <.button variant="outline">
    <.icon name="hero-funnel" class="size-4" />
  </.button>
</div>
```
