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

## Supported `type` values

`text`, `email`, `password`, `number`, `tel`, `url`, `date`, `time`, `datetime-local`, `checkbox`, `select`, `textarea`

## Usage Examples

```heex
<!-- Basic text input -->
<.input type="text" name="username" label="Username" />

<!-- With form field (errors are pulled from the field automatically) -->
<.input field={@form[:email]} type="email" label="Email Address" />

<!-- Select -->
<.input
  type="select"
  name="country"
  label="Country"
  options={[{"United States", "us"}, {"Canada", "ca"}, {"Mexico", "mx"}]}
  prompt="Select a country"
/>

<!-- Textarea -->
<.input type="textarea" name="message" label="Message" rows={5} />

<!-- Checkbox -->
<.input type="checkbox" name="terms" label="I accept the terms" />

<!-- Password -->
<.input type="password" name="password" label="Password" />

<!-- Number -->
<.input type="number" name="quantity" label="Quantity" min={1} max={100} />
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

For more specialized input components with additional styling options, consider:
`text_field`, `email_field`, `password_field`, `number_field`, `textarea_field`, `native_select` (styled versions of each type).

`input` gives basic Phoenix form integration; the specialized field components offer more customization.
