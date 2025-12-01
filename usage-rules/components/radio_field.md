# Radio Field Component

Customizable radio button input with labels and error handling.

**Documentation**: https://mishka.tools/chelekom/docs/forms/radio-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component radio_field
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
| `radio_field/1` | Single radio button |
| `group_radio/1` | Grouped radio buttons |

## Attributes

### `radio_field/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Radio size |
| `space` | `:string` | `"medium"` | Label spacing |
| `name` | `:string` | **required** | Input name |
| `value` | `:string` | **required** | Option value |
| `label` | `:string` | `nil` | Label text |
| `checked` | `:boolean` | `false` | Selected state |
| `reverse` | `:boolean` | `false` | Reverse layout |
| `errors` | `:list` | `[]` | Error messages |

## Available Options

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Radio Field

```heex
<.radio_field name="gender" value="male" label="Male" />
<.radio_field name="gender" value="female" label="Female" />
<.radio_field name="gender" value="other" label="Other" />
```

### With Form Field

```heex
<.radio_field
  field={@form[:status]}
  value="active"
  label="Active"
  checked={@form[:status].value == "active"}
/>
<.radio_field
  field={@form[:status]}
  value="inactive"
  label="Inactive"
  checked={@form[:status].value == "inactive"}
/>
```

### Different Colors

```heex
<.radio_field name="option" value="primary" label="Primary" color="primary" checked />
<.radio_field name="option" value="success" label="Success" color="success" />
<.radio_field name="option" value="danger" label="Danger" color="danger" />
```

### Different Sizes

```heex
<.radio_field name="size" value="small" label="Small" size="small" />
<.radio_field name="size" value="medium" label="Medium" size="medium" />
<.radio_field name="size" value="large" label="Large" size="large" />
```

### Reversed Layout

```heex
<.radio_field name="option" value="reversed" label="Label on left" reverse />
```

### With Errors

```heex
<.radio_field
  name="terms"
  value="agree"
  label="I agree to terms"
  errors={["You must accept the terms"]}
/>
```

### Group Radio

```heex
<.group_radio name="priority" label="Priority Level">
  <:radio value="low" label="Low" />
  <:radio value="medium" label="Medium" checked />
  <:radio value="high" label="High" />
</.group_radio>
```

## Common Patterns

### Survey Question

```heex
<fieldset class="space-y-2">
  <legend class="font-medium mb-2">How did you hear about us?</legend>
  <.radio_field name="referral" value="search" label="Search Engine" />
  <.radio_field name="referral" value="social" label="Social Media" />
  <.radio_field name="referral" value="friend" label="Friend/Colleague" />
  <.radio_field name="referral" value="other" label="Other" />
</fieldset>
```

### Inline Radio Group

```heex
<div class="flex items-center gap-4">
  <.radio_field name="status" value="active" label="Active" checked />
  <.radio_field name="status" value="inactive" label="Inactive" />
  <.radio_field name="status" value="pending" label="Pending" />
</div>
```
