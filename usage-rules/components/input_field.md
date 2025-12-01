# Input Field Component

Generic input field component supporting multiple input types with form integration.

**Documentation**: https://mishka.tools/chelekom/docs/forms/input-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component input_field

# Generate with custom module name
mix mishka.ui.gen.component input_field --module MyAppWeb.Components.CustomInputField
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
| `input/1` | Generic input element |
| `error/1` | Error message display |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:any` | `nil` | Unique identifier |
| `name` | `:any` | `nil` | Input field name |
| `value` | `:any` | `nil` | Input value |
| `type` | `:string` | `"text"` | Input type |
| `field` | `Phoenix.HTML.FormField` | `nil` | Form field struct |
| `label` | `:string` | `nil` | Label text |
| `errors` | `:list` | `[]` | Error messages |
| `checked` | `:boolean` | `false` | For checkboxes |
| `prompt` | `:string` | `nil` | Select placeholder |
| `options` | `:list` | `nil` | Select options |
| `multiple` | `:boolean` | `false` | Multiple selection |
| `class` | `:any` | `nil` | Custom CSS class |

## Supported Input Types

- `text`
- `email`
- `password`
- `number`
- `tel`
- `url`
- `date`
- `time`
- `datetime-local`
- `checkbox`
- `select`
- `textarea`

## Usage Examples

### Basic Text Input

```heex
<.input type="text" name="username" label="Username" />
```

### With Form Field

```heex
<.input field={@form[:email]} type="email" label="Email Address" />
```

### Select Input

```heex
<.input
  type="select"
  name="country"
  label="Country"
  options={[{"United States", "us"}, {"Canada", "ca"}, {"Mexico", "mx"}]}
  prompt="Select a country"
/>
```

### Textarea

```heex
<.input type="textarea" name="message" label="Message" rows={5} />
```

### Checkbox

```heex
<.input type="checkbox" name="terms" label="I accept the terms" />
```

### Password

```heex
<.input type="password" name="password" label="Password" />
```

### Number

```heex
<.input type="number" name="quantity" label="Quantity" min={1} max={100} />
```

### With Errors

```heex
<.input
  field={@form[:email]}
  type="email"
  label="Email"
/>
```

### Error Component

```heex
<.error :for={msg <- @form[:email].errors}>
  {translate_error(msg)}
</.error>
```

## Common Patterns

### Simple Form

```heex
<.form for={@form} phx-submit="save">
  <.input field={@form[:name]} type="text" label="Name" />
  <.input field={@form[:email]} type="email" label="Email" />
  <.input field={@form[:password]} type="password" label="Password" />
  <.input field={@form[:role]} type="select" label="Role" options={@roles} />
  <.input field={@form[:bio]} type="textarea" label="Bio" />
  <.input field={@form[:newsletter]} type="checkbox" label="Subscribe to newsletter" />
  <.button type="submit">Save</.button>
</.form>
```

### Dynamic Form Fields

```heex
<.input
  :for={{field, opts} <- @fields}
  field={@form[field]}
  type={opts.type}
  label={opts.label}
  options={opts[:options]}
/>
```

## Note

For more specialized input components with additional styling options, consider using:
- `text_field` - Styled text input
- `email_field` - Styled email input
- `password_field` - Styled password input
- `number_field` - Styled number input
- `textarea_field` - Styled textarea
- `native_select` - Styled select

The `input` component provides basic Phoenix form integration while the specialized field components offer more customization options.
