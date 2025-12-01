# Pagination Component

Page navigation with customizable controls, siblings, and boundaries.

**Documentation**: https://mishka.tools/chelekom/docs/pagination

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component pagination
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
| `size` | `:string` | `"medium"` | Button size |
| `rounded` | `:string` | `"medium"` | Border radius |
| `space` | `:string` | `"small"` | Space between buttons |
| `total` | `:integer` | **required** | Total pages |
| `current` | `:integer` | `1` | Current page |
| `siblings` | `:integer` | `1` | Pages on each side |
| `boundaries` | `:integer` | `1` | Pages at edges |
| `show_edges` | `:boolean` | `true` | Show first/last |
| `show_controls` | `:boolean` | `true` | Show prev/next |
| `on_change` | `:string` | `nil` | Change event |

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `subtle`, `shadow`, `inverted`, `gradient`, `bordered`

### Colors
`base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`, `dark`, `white`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `full`, `none`

## Usage Examples

### Basic Pagination

```heex
<.pagination total={10} current={@page} on_change="page_changed" />
```

### Different Variants

```heex
<.pagination variant="default" total={10} current={1} />
<.pagination variant="outline" total={10} current={1} />
<.pagination variant="shadow" total={10} current={1} />
```

### Different Colors

```heex
<.pagination color="primary" total={10} current={1} />
<.pagination color="success" total={10} current={1} />
```

### With More Siblings

```heex
<.pagination total={20} current={10} siblings={2} boundaries={2} />
```

### Without Edge Controls

```heex
<.pagination total={10} current={5} show_edges={false} />
```

### Compact (No Controls)

```heex
<.pagination total={5} current={3} show_controls={false} />
```

### Rounded Full

```heex
<.pagination total={10} current={1} rounded="full" variant="default" />
```

## Common Patterns

### Table Pagination

```heex
<div class="flex items-center justify-between mt-4">
  <p class="text-sm text-gray-600">
    Showing {(@page - 1) * @per_page + 1} to {min(@page * @per_page, @total_count)} of {@total_count} results
  </p>
  <.pagination
    total={@total_pages}
    current={@page}
    on_change="paginate"
    variant="outline"
    color="primary"
  />
</div>
```

### Blog Post Pagination

```heex
<.pagination
  total={@total_pages}
  current={@page}
  on_change="page_changed"
  variant="default"
  color="primary"
  rounded="full"
  size="large"
/>
```
