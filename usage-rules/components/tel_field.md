# Tel Field Component

Telephone input with customizable styling and validation.

**Documentation**: https://mishka.tools/chelekom/docs/forms/tel-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component tel_field
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
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `label` | `:string` | `nil` | Label text |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `description` | `:string` | `nil` | Description text |
| `floating` | `:string` | `nil` | Floating label |

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

### Basic Tel Field

```heex
<.tel_field name="phone" label="Phone Number" />
```

### With Placeholder

```heex
<.tel_field
  name="phone"
  label="Phone"
  placeholder="+1 (555) 123-4567"
/>
```

### With Form Field

```heex
<.tel_field
  field={@form[:phone]}
  label="Phone Number"
  placeholder="Enter your phone"
/>
```

### With Description

```heex
<.tel_field
  name="phone"
  label="Phone Number"
  description="We'll only use this for account recovery"
/>
```

### Floating Label

```heex
<.tel_field
  name="phone"
  floating="outer"
  label="Phone Number"
/>
```

### Different Variants

```heex
<.tel_field name="phone" variant="default" label="Default" />
<.tel_field name="phone" variant="outline" label="Outline" />
<.tel_field name="phone" variant="bordered" label="Bordered" />
```

### With Country Code Icon

```heex
<.tel_field name="phone" label="Phone Number">
  <:start_section>
    <.icon name="hero-phone" class="size-5" />
  </:start_section>
</.tel_field>
```

### With Country Selector

```heex
<.tel_field name="phone" label="Phone Number">
  <:start_section>
    <select class="bg-transparent border-none text-sm">
      <option>+1</option>
      <option>+44</option>
      <option>+49</option>
    </select>
  </:start_section>
</.tel_field>
```

## Common Patterns

### Contact Form

```heex
<.form for={@form} phx-submit="submit">
  <.text_field field={@form[:name]} label="Full Name" />
  <.email_field field={@form[:email]} label="Email" />
  <.tel_field
    field={@form[:phone]}
    label="Phone Number"
    placeholder="+1 (555) 123-4567"
    description="Optional - for urgent matters only"
  />
  <.button type="submit" color="primary">Submit</.button>
</.form>
```

### Phone Verification

```heex
<div class="space-y-4">
  <.tel_field
    name="phone"
    label="Phone Number"
    placeholder="Enter your phone number"
    variant="outline"
  >
    <:start_section>
      <.icon name="hero-device-phone-mobile" class="size-5" />
    </:start_section>
  </.tel_field>

  <.button color="primary" full_width phx-click="send_code">
    Send Verification Code
  </.button>
</div>
```

### Multiple Phone Numbers

```heex
<div class="space-y-4">
  <.tel_field
    field={@form[:mobile]}
    label="Mobile Phone"
    placeholder="Mobile number"
  >
    <:start_section>
      <.icon name="hero-device-phone-mobile" class="size-5" />
    </:start_section>
  </.tel_field>

  <.tel_field
    field={@form[:work]}
    label="Work Phone"
    placeholder="Work number (optional)"
  >
    <:start_section>
      <.icon name="hero-building-office" class="size-5" />
    </:start_section>
  </.tel_field>
</div>
```
