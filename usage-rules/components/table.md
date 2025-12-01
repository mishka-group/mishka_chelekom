# Table Component

Customizable data table with headers, rows, and cells.

**Documentation**: https://mishka.tools/chelekom/docs/table

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component table
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `table/1` | Table container |
| `th/1` | Table header cell |
| `tr/1` | Table row |
| `td/1` | Table data cell |

## Attributes

### `table/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `padding` | `:string` | `"small"` | Cell padding |
| `rounded` | `:string` | `"medium"` | Border radius |
| `text_position` | `:string` | `"left"` | Text alignment |
| `border` | `:string` | `nil` | Border style |
| `fixed` | `:boolean` | `false` | Fixed layout |

## Slots

### `header` Slot

Table header cells.

### `footer` Slot

Table footer content.

## Available Options

### Variants
`base`, `outline`, `default`, `shadow`, `bordered`, `transparent`, `hoverable`, `stripped`, `separated`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

### Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Table

```heex
<.table>
  <:header>Name</:header>
  <:header>Email</:header>
  <:header>Role</:header>

  <.tr>
    <.td>John Doe</.td>
    <.td>john@example.com</.td>
    <.td>Admin</.td>
  </.tr>
  <.tr>
    <.td>Jane Smith</.td>
    <.td>jane@example.com</.td>
    <.td>User</.td>
  </.tr>
</.table>
```

### Stripped Table

```heex
<.table variant="stripped">
  <:header>Product</:header>
  <:header>Price</:header>
  <:header>Stock</:header>

  <.tr :for={product <- @products}>
    <.td>{product.name}</.td>
    <.td>${product.price}</.td>
    <.td>{product.stock}</.td>
  </.tr>
</.table>
```

### Hoverable Table

```heex
<.table variant="hoverable">
  <:header>Name</:header>
  <:header>Status</:header>

  <.tr :for={user <- @users}>
    <.td>{user.name}</.td>
    <.td><.badge color={status_color(user.status)}>{user.status}</.badge></.td>
  </.tr>
</.table>
```

### Bordered Table

```heex
<.table variant="bordered" color="natural">
  <:header>Column 1</:header>
  <:header>Column 2</:header>
  <:header>Column 3</:header>

  <.tr>
    <.td>Cell 1</.td>
    <.td>Cell 2</.td>
    <.td>Cell 3</.td>
  </.tr>
</.table>
```

### With Footer

```heex
<.table>
  <:header>Item</:header>
  <:header>Qty</:header>
  <:header>Price</:header>

  <.tr :for={item <- @items}>
    <.td>{item.name}</.td>
    <.td>{item.qty}</.td>
    <.td>${item.price}</.td>
  </.tr>

  <:footer>
    <.tr>
      <.td colspan="2" class="font-bold">Total</.td>
      <.td class="font-bold">${@total}</.td>
    </.tr>
  </:footer>
</.table>
```

### Fixed Layout

```heex
<.table fixed class="w-full">
  <:header>Name</:header>
  <:header>Description</:header>
  <:header>Actions</:header>

  <.tr :for={item <- @items}>
    <.td class="w-1/4">{item.name}</.td>
    <.td class="w-2/4 truncate">{item.description}</.td>
    <.td class="w-1/4">
      <.button size="small">Edit</.button>
    </.td>
  </.tr>
</.table>
```

### Different Padding

```heex
<.table padding="large">
  <:header>Name</:header>
  <:header>Value</:header>

  <.tr>
    <.td>Large Padding</.td>
    <.td>Spacious cells</.td>
  </.tr>
</.table>
```

## Common Patterns

### Data Table with Actions

```heex
<.table variant="hoverable">
  <:header>Name</:header>
  <:header>Email</:header>
  <:header>Status</:header>
  <:header>Actions</:header>

  <.tr :for={user <- @users}>
    <.td>
      <div class="flex items-center gap-2">
        <.avatar src={user.avatar} size="small" />
        <span>{user.name}</span>
      </div>
    </.td>
    <.td>{user.email}</.td>
    <.td><.badge color={status_color(user.status)}>{user.status}</.badge></.td>
    <.td>
      <div class="flex gap-2">
        <.button size="small" variant="outline">Edit</.button>
        <.button size="small" variant="outline" color="danger">Delete</.button>
      </div>
    </.td>
  </.tr>
</.table>
```

### Sortable Headers

```heex
<.table>
  <:header>
    <button phx-click="sort" phx-value-field="name" class="flex items-center gap-1">
      Name
      <.icon name="hero-chevron-up-down" class="size-4" />
    </button>
  </:header>
  <:header>
    <button phx-click="sort" phx-value-field="date" class="flex items-center gap-1">
      Date
      <.icon name="hero-chevron-up-down" class="size-4" />
    </button>
  </:header>

  <.tr :for={item <- @sorted_items}>
    <.td>{item.name}</.td>
    <.td>{item.date}</.td>
  </.tr>
</.table>
```

### Empty State

```heex
<.table>
  <:header>Name</:header>
  <:header>Email</:header>

  <.tr :if={@users == []}>
    <.td colspan="2" class="text-center py-8 text-gray-500">
      No users found
    </.td>
  </.tr>

  <.tr :for={user <- @users}>
    <.td>{user.name}</.td>
    <.td>{user.email}</.td>
  </.tr>
</.table>
```
