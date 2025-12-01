# Radio Card Component

Card-based radio selection with rich styling and layout options.

**Documentation**: https://mishka.tools/chelekom/docs/forms/radio-card

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component radio_card
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
| `color` | `:string` | `"natural"` | Color theme |
| `border` | `:string` | `"extra_small"` | Border style |
| `rounded` | `:string` | `"medium"` | Border radius |
| `padding` | `:string` | `"small"` | Card padding |
| `space` | `:string` | `"small"` | Space between elements |
| `cols` | `:string` | `"one"` | Grid columns |
| `name` | `:string` | **required** | Input name |
| `icon` | `:string` | `nil` | Icon for cards |

## Slots

### `radio` Slot

Individual radio card options.

| Attribute | Type | Description |
|-----------|------|-------------|
| `value` | `:string` | Option value |
| `title` | `:string` | Card title |
| `description` | `:string` | Card description |
| `checked` | `:boolean` | Pre-selected state |

## Available Options

### Variants
`base`, `default`, `outline`, `shadow`, `bordered`

### Colors
`base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dark`, `white`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Radio Card

```heex
<.radio_card name="plan">
  <:radio value="basic" title="Basic Plan" description="For individuals" />
  <:radio value="pro" title="Pro Plan" description="For teams" />
</.radio_card>
```

### With Icons

```heex
<.radio_card name="plan" icon="hero-home">
  <:radio value="basic" title="Basic" description="$9/month" />
  <:radio value="pro" title="Pro" description="$29/month" />
</.radio_card>
```

### Grid Layout

```heex
<.radio_card name="plan" cols="three" class="w-full">
  <:radio value="starter" title="Starter" description="For individuals" />
  <:radio value="team" title="Team" description="For small teams" />
  <:radio value="enterprise" title="Enterprise" description="For large orgs" />
</.radio_card>
```

### With Custom Content

```heex
<.radio_card name="plan" variant="shadow">
  <:radio value="basic" title="Basic Plan">
    <p class="text-lg font-bold">$9/month</p>
    <ul class="text-sm mt-2">
      <li>5 projects</li>
      <li>Basic support</li>
    </ul>
  </:radio>
  <:radio value="pro" title="Pro Plan">
    <p class="text-lg font-bold">$29/month</p>
    <ul class="text-sm mt-2">
      <li>Unlimited projects</li>
      <li>Priority support</li>
    </ul>
  </:radio>
</.radio_card>
```

### Different Variants

```heex
<.radio_card name="option" variant="outline" color="primary">
  <:radio value="a" title="Option A" />
  <:radio value="b" title="Option B" />
</.radio_card>
```

## Common Patterns

### Subscription Plans

```heex
<.radio_card name="subscription" cols="three" variant="shadow" class="w-full">
  <:radio value="free" title="Free" description="Forever free">
    <p class="text-2xl font-bold mt-2">$0</p>
  </:radio>
  <:radio value="pro" title="Pro" description="Most popular" checked>
    <p class="text-2xl font-bold mt-2">$19/mo</p>
  </:radio>
  <:radio value="team" title="Team" description="For organizations">
    <p class="text-2xl font-bold mt-2">$49/mo</p>
  </:radio>
</.radio_card>
```

### Shipping Options

```heex
<.radio_card name="shipping" variant="bordered">
  <:radio value="standard" title="Standard Shipping" description="5-7 business days">
    <span class="font-bold">Free</span>
  </:radio>
  <:radio value="express" title="Express Shipping" description="2-3 business days">
    <span class="font-bold">$9.99</span>
  </:radio>
</.radio_card>
```
