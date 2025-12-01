# Tabs Component

Tabbed interface for organizing content into panels.

**Documentation**: https://mishka.tools/chelekom/docs/tabs

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component tabs
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `badge`, `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Tab size |
| `padding` | `:string` | `"small"` | Panel padding |
| `gap` | `:string` | `"small"` | Space between tabs |
| `vertical` | `:boolean` | `false` | Vertical layout |

## Slots

### `tab` Slot

Tab buttons.

| Attribute | Type | Description |
|-----------|------|-------------|
| `icon` | `:string` | Tab icon |
| `active` | `:boolean` | Initially active |

### `panel` Slot

Tab panel content.

## Available Options

### Variants
`base`, `default`, `pills`

### Colors
`base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Tabs

```heex
<.tabs id="basic-tabs">
  <:tab>Tab 1</:tab>
  <:tab>Tab 2</:tab>
  <:tab>Tab 3</:tab>

  <:panel>Content for Tab 1</:panel>
  <:panel>Content for Tab 2</:panel>
  <:panel>Content for Tab 3</:panel>
</.tabs>
```

### With Active Tab

```heex
<.tabs id="active-tabs">
  <:tab>First</:tab>
  <:tab active>Second</:tab>
  <:tab>Third</:tab>

  <:panel>First panel</:panel>
  <:panel>Second panel (active by default)</:panel>
  <:panel>Third panel</:panel>
</.tabs>
```

### With Icons

```heex
<.tabs id="icon-tabs" color="primary">
  <:tab icon="hero-home">Home</:tab>
  <:tab icon="hero-user">Profile</:tab>
  <:tab icon="hero-cog-6-tooth">Settings</:tab>

  <:panel>Home content</:panel>
  <:panel>Profile content</:panel>
  <:panel>Settings content</:panel>
</.tabs>
```

### Pills Variant

```heex
<.tabs id="pills-tabs" variant="pills" color="primary">
  <:tab>Overview</:tab>
  <:tab>Details</:tab>
  <:tab>Reviews</:tab>

  <:panel>Overview content</:panel>
  <:panel>Details content</:panel>
  <:panel>Reviews content</:panel>
</.tabs>
```

### Vertical Tabs

```heex
<.tabs id="vertical-tabs" vertical color="info">
  <:tab icon="hero-home">Dashboard</:tab>
  <:tab icon="hero-chart-bar">Analytics</:tab>
  <:tab icon="hero-document">Reports</:tab>

  <:panel>Dashboard panel</:panel>
  <:panel>Analytics panel</:panel>
  <:panel>Reports panel</:panel>
</.tabs>
```

### Different Sizes

```heex
<.tabs id="small-tabs" size="small">
  <:tab>Small 1</:tab>
  <:tab>Small 2</:tab>
  <:panel>Small panel 1</:panel>
  <:panel>Small panel 2</:panel>
</.tabs>

<.tabs id="large-tabs" size="large">
  <:tab>Large 1</:tab>
  <:tab>Large 2</:tab>
  <:panel>Large panel 1</:panel>
  <:panel>Large panel 2</:panel>
</.tabs>
```

## Common Patterns

### Product Details

```heex
<.tabs id="product-tabs" variant="default" color="primary">
  <:tab icon="hero-document-text">Description</:tab>
  <:tab icon="hero-list-bullet">Specifications</:tab>
  <:tab icon="hero-star">Reviews ({@review_count})</:tab>

  <:panel>
    <div class="prose">
      {raw(@product.description)}
    </div>
  </:panel>
  <:panel>
    <.table>
      <.tr :for={{key, value} <- @product.specs}>
        <.td class="font-medium">{key}</.td>
        <.td>{value}</.td>
      </.tr>
    </.table>
  </:panel>
  <:panel>
    <div :for={review <- @reviews} class="border-b py-4">
      <div class="flex items-center gap-2">
        <.rating select={review.rating} size="small" />
        <span class="font-medium">{review.author}</span>
      </div>
      <p class="mt-2">{review.content}</p>
    </div>
  </:panel>
</.tabs>
```

### Settings Page

```heex
<.tabs id="settings-tabs" vertical variant="pills" color="natural" class="min-h-96">
  <:tab icon="hero-user">Profile</:tab>
  <:tab icon="hero-bell">Notifications</:tab>
  <:tab icon="hero-shield-check">Security</:tab>
  <:tab icon="hero-credit-card">Billing</:tab>

  <:panel>
    <h2 class="text-xl font-bold mb-4">Profile Settings</h2>
    <!-- Profile form -->
  </:panel>
  <:panel>
    <h2 class="text-xl font-bold mb-4">Notification Preferences</h2>
    <!-- Notification settings -->
  </:panel>
  <:panel>
    <h2 class="text-xl font-bold mb-4">Security Settings</h2>
    <!-- Security settings -->
  </:panel>
  <:panel>
    <h2 class="text-xl font-bold mb-4">Billing Information</h2>
    <!-- Billing settings -->
  </:panel>
</.tabs>
```

## Helper Functions

```elixir
# Show a specific tab programmatically
show_tab(js \\ %JS{}, id, index)

# Hide a specific tab programmatically
hide_tab(js \\ %JS{}, id, index)
```
