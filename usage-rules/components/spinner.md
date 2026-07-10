# Spinner Component

Animated loading indicator with multiple styles.

**Documentation**: https://mishka.tools/chelekom/docs/spinner

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component spinner
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Options |
|-----------|------|---------|---------|
| `type` | `:string` | `"default"` | `default`, `dots`, `bars`, `pinging` |
| `color` | `:string` | `"base"` | `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"medium"` | `extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large` |

## Usage Examples

### Basic

```heex
<.spinner />
```

### Type / Color / Size

```heex
<.spinner type="default" />
<.spinner type="dots" />
<.spinner type="bars" />
<.spinner type="pinging" />

<.spinner color="primary" />
<.spinner color="success" />
<.spinner color="warning" />
<.spinner color="danger" />

<.spinner size="extra_small" />
<.spinner size="small" />
<.spinner size="medium" />
<.spinner size="large" />
<.spinner size="extra_large" />
```

### Combined (type + color + size)

```heex
<.spinner type="pinging" color="primary" size="large" />
<.spinner type="dots" color="info" size="medium" />
<.spinner type="bars" color="success" size="large" />
```

## Common Patterns

### Button Loading State

```heex
<.button disabled={@loading}>
  <.spinner :if={@loading} size="extra_small" color="white" />
  <span :if={!@loading}>Submit</span>
  <span :if={@loading}>Loading...</span>
</.button>
```

### Full Page Loading

```heex
<div :if={@loading} class="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
  <div class="bg-white p-8 rounded-lg flex flex-col items-center gap-4">
    <.spinner size="extra_large" color="primary" />
    <p class="text-gray-600">Loading...</p>
  </div>
</div>
```

### Inline Loading

```heex
<div class="flex items-center gap-2">
  <.spinner size="small" color="primary" />
  <span>Loading data...</span>
</div>
```

### Card Loading

```heex
<div class="border rounded-lg p-6">
  <div :if={@loading} class="flex justify-center py-8">
    <.spinner size="large" color="primary" />
  </div>
  <div :if={!@loading}>
    {render_content()}
  </div>
</div>
```

### Table Loading Row

```heex
<.tr :if={@loading}>
  <.td colspan="5" class="text-center py-8">
    <.spinner color="primary" />
  </.td>
</.tr>
```
