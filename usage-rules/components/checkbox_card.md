# Checkbox Card Component

Card-based checkbox selection component with rich styling options for grouped selections.

**Documentation**: https://mishka.tools/chelekom/docs/forms/checkbox-card

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component checkbox_card

# Generate with specific options
mix mishka.ui.gen.component checkbox_card --variant default,outline --color primary,natural

# Generate with custom module name
mix mishka.ui.gen.component checkbox_card --module MyAppWeb.Components.CustomCheckboxCard
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
| `checkbox_card/1` | Card-based checkbox group |

## Attributes

### `checkbox_card/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `name` | `:string` | **required** | Input field name |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"small"` | Overall size |
| `rounded` | `:string` | `"medium"` | Border radius |
| `padding` | `:string` | `"small"` | Internal padding |
| `space` | `:string` | `"small"` | Vertical spacing |
| `cols` | `:string` | `"one"` | Grid columns |
| `cols_gap` | `:string` | `"small"` | Grid gap |
| `border` | `:string` | `"extra_small"` | Border width |
| `show_checkbox` | `:boolean` | `false` | Show checkbox input |
| `reverse` | `:boolean` | `false` | Reverse element order |
| `label` | `:string` | `nil` | Group label |
| `description` | `:string` | `nil` | Group description |
| `icon` | `:string` | `nil` | Default icon for cards |
| `icon_class` | `:string` | `nil` | Icon styling |
| `error_icon` | `:string` | `nil` | Error state icon |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `checkbox` Slot

| Attribute | Type | Description |
|-----------|------|-------------|
| `value` | `:string` | **Required** - Selection value |
| `title` | `:string` | Card title |
| `description` | `:string` | Card description |
| `icon` | `:string` | Card icon |
| `icon_class` | `:string` | Icon styling |
| `checked` | `:boolean` | Pre-selected state |
| `content_class` | `:string` | Content wrapper class |
| `class` | `:string` | Card wrapper class |

### `inner_block` Slot

Custom content within checkbox cards.

## Available Options

### Variants
`base`, `default`, `outline`, `shadow`, `bordered`

### Colors
`base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dark`, `white`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Columns
`one`, `two`, `three`, `four`, `five`, `six`, `seven`, `eight`, `nine`, `ten`, `eleven`, `twelve`

## Helper Functions

### `checkbox_card_check/3`

Check if a value is selected in the form.

```elixir
checkbox_card_check(form, field, value)
```

## Usage Examples

### Basic Checkbox Card

```heex
<.checkbox_card name="plan">
  <:checkbox value="basic" title="Basic Plan" description="For individuals" />
  <:checkbox value="pro" title="Pro Plan" description="For teams" />
  <:checkbox value="enterprise" title="Enterprise" description="For large organizations" />
</.checkbox_card>
```

### With Icons

```heex
<.checkbox_card name="features" icon="hero-check-circle">
  <:checkbox value="analytics" title="Analytics" icon="hero-chart-bar" />
  <:checkbox value="reports" title="Reports" icon="hero-document-chart-bar" />
  <:checkbox value="api" title="API Access" icon="hero-code-bracket" />
</.checkbox_card>
```

### Multi-Column Grid

```heex
<.checkbox_card name="options" cols="three" cols_gap="medium">
  <:checkbox value="option1" title="Option 1" />
  <:checkbox value="option2" title="Option 2" />
  <:checkbox value="option3" title="Option 3" />
  <:checkbox value="option4" title="Option 4" />
  <:checkbox value="option5" title="Option 5" />
  <:checkbox value="option6" title="Option 6" />
</.checkbox_card>
```

### With Visible Checkboxes

```heex
<.checkbox_card name="permissions" show_checkbox={true} color="primary">
  <:checkbox value="read" title="Read" description="View content" />
  <:checkbox value="write" title="Write" description="Create content" />
  <:checkbox value="delete" title="Delete" description="Remove content" />
</.checkbox_card>
```

### With Custom Content

```heex
<.checkbox_card name="pricing" cols="two">
  <:checkbox value="monthly">
    <div class="text-center">
      <p class="text-2xl font-bold">$10</p>
      <p class="text-sm">per month</p>
    </div>
  </:checkbox>
  <:checkbox value="yearly">
    <div class="text-center">
      <p class="text-2xl font-bold">$100</p>
      <p class="text-sm">per year</p>
      <span class="text-green-500 text-xs">Save 17%</span>
    </div>
  </:checkbox>
</.checkbox_card>
```

### Different Variants

```heex
<.checkbox_card name="v1" variant="default" color="primary">
  <:checkbox value="1" title="Default variant" />
</.checkbox_card>

<.checkbox_card name="v2" variant="outline" color="success">
  <:checkbox value="1" title="Outline variant" />
</.checkbox_card>

<.checkbox_card name="v3" variant="shadow" color="info">
  <:checkbox value="1" title="Shadow variant" />
</.checkbox_card>

<.checkbox_card name="v4" variant="bordered" color="warning">
  <:checkbox value="1" title="Bordered variant" />
</.checkbox_card>
```

### With Form Integration

```heex
<.form for={@form} phx-submit="save">
  <.checkbox_card
    field={@form[:features]}
    label="Select Features"
    description="Choose the features you need"
    color="primary"
    cols="two"
  >
    <:checkbox value="feature1" title="Feature 1" checked={true} />
    <:checkbox value="feature2" title="Feature 2" />
    <:checkbox value="feature3" title="Feature 3" />
  </.checkbox_card>
  <.button type="submit">Save</.button>
</.form>
```

## Common Patterns

### Pricing Tier Selection

```heex
<.checkbox_card
  name="subscription"
  cols="three"
  variant="bordered"
  color="primary"
  show_checkbox={true}
>
  <:checkbox value="starter" title="Starter" description="$9/month">
    <ul class="text-sm mt-2">
      <li>5 projects</li>
      <li>Basic support</li>
    </ul>
  </:checkbox>
  <:checkbox value="professional" title="Professional" description="$29/month" checked={true}>
    <ul class="text-sm mt-2">
      <li>Unlimited projects</li>
      <li>Priority support</li>
    </ul>
  </:checkbox>
  <:checkbox value="enterprise" title="Enterprise" description="Custom">
    <ul class="text-sm mt-2">
      <li>Custom solutions</li>
      <li>Dedicated support</li>
    </ul>
  </:checkbox>
</.checkbox_card>
```

### Permission Selection

```heex
<.checkbox_card
  field={@form[:permissions]}
  label="User Permissions"
  cols="two"
  variant="outline"
  color="natural"
>
  <:checkbox
    :for={permission <- @available_permissions}
    value={permission.id}
    title={permission.name}
    description={permission.description}
    icon={permission.icon}
    checked={permission.id in @user_permissions}
  />
</.checkbox_card>
```
