# Rating Component

Star-based rating display with interactive selection support.

**Documentation**: https://mishka.tools/chelekom/docs/rating

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component rating
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
| `color` | `:string` | `"warning"` | Star color |
| `size` | `:string` | `"small"` | Star size |
| `gap` | `:string` | `"small"` | Space between stars |
| `count` | `:integer` | `5` | Number of stars |
| `select` | `:integer` | `0` | Selected stars |
| `interactive` | `:boolean` | `false` | Allow selection |
| `on_select` | `:string` | `nil` | Selection event |

## Available Options

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large`

## Usage Examples

### Basic Rating (Display)

```heex
<.rating select={4} />
```

### Interactive Rating

```heex
<.rating interactive on_select="rate_item" />
```

### Different Colors

```heex
<.rating select={4} color="warning" />
<.rating select={4} color="primary" />
<.rating select={4} color="danger" />
```

### Different Sizes

```heex
<.rating select={3} size="small" />
<.rating select={3} size="medium" />
<.rating select={3} size="large" />
```

### Custom Star Count

```heex
<.rating count={10} select={7} size="small" />
```

### With Gap Sizes

```heex
<.rating select={4} gap="small" />
<.rating select={4} gap="large" />
<.rating select={4} gap="extra_large" />
```

### Pre-selected Interactive

```heex
<.rating select={3} interactive color="primary" />
```

## Common Patterns

### Product Rating Display

```heex
<div class="flex items-center gap-2">
  <.rating select={@product.rating} size="small" />
  <span class="text-sm text-gray-600">({@product.review_count} reviews)</span>
</div>
```

### User Review Form

```heex
<div class="space-y-2">
  <label class="font-medium">Your Rating</label>
  <.rating
    interactive
    select={@user_rating}
    on_select="set_rating"
    size="large"
    color="warning"
  />
</div>
```

### Rating with Value

```heex
<div class="flex items-center gap-3">
  <.rating select={@rating} />
  <span class="font-bold">{@rating}/5</span>
</div>
```

### Compact Rating

```heex
<div class="flex items-center gap-1">
  <.rating select={1} count={1} size="small" />
  <span class="text-sm">{@rating}</span>
</div>
```

### Rating Summary

```heex
<div class="space-y-1">
  <div :for={i <- 5..1} class="flex items-center gap-2">
    <span class="w-4 text-sm">{i}</span>
    <.rating select={i} count={5} size="extra_small" />
    <div class="flex-1 bg-gray-200 rounded-full h-2">
      <div class={"bg-warning-500 h-2 rounded-full"} style={"width: #{@ratings[i]}%"} />
    </div>
    <span class="w-8 text-sm text-gray-600">{@ratings[i]}%</span>
  </div>
</div>
```
