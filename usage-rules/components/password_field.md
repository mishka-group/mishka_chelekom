# Password Field Component

Password input with show/hide toggle and customizable styling.

**Documentation**: https://mishka.tools/chelekom/docs/forms/password-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component password_field
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
| `variant` | `:string` | `"base"` | Style variant — `base`, `default`, `outline`, `shadow`, `bordered`, `transparent` |
| `color` | `:string` | `"base"` | Color theme — `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver` |
| `size` | `:string` | `"medium"` | Input size — `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `label` | `:string` | `nil` | Label text |
| `show_toggle` | `:boolean` | `true` | Show/hide toggle |
| `floating` | `:string` | `nil` | Floating label (e.g. `"outer"`) |
| `autocomplete` | `:string` | `"current-password"` | Autocomplete |

## Slots

- `start_section` / `end_section` — content before/after the input.

## Usage Examples

```heex
<%!-- Basic --%>
<.password_field name="password" label="Password" />

<%!-- With form field --%>
<.password_field field={@form[:password]} label="Password" autocomplete="new-password" />

<%!-- Without toggle --%>
<.password_field name="password" label="Password" show_toggle={false} />

<%!-- Floating label --%>
<.password_field name="password" floating="outer" label="Password" />

<%!-- Variants --%>
<.password_field variant="default" label="Default" />
<.password_field variant="outline" label="Outline" />
<.password_field variant="bordered" label="Bordered" />

<%!-- With start section --%>
<.password_field name="password" label="Password">
  <:start_section>
    <.icon name="hero-lock-closed" class="size-5" />
  </:start_section>
</.password_field>
```

## Common Patterns

### Login Form

```heex
<.form for={@form} phx-submit="login">
  <.email_field field={@form[:email]} label="Email" />
  <.password_field field={@form[:password]} label="Password" autocomplete="current-password" />
  <.button type="submit" color="primary" full_width>Sign In</.button>
</.form>
```

### Registration Form (with confirmation)

```heex
<.password_field
  field={@form[:password]}
  label="Password"
  autocomplete="new-password"
  description="Must be at least 8 characters"
/>
<.password_field
  field={@form[:password_confirmation]}
  label="Confirm Password"
  autocomplete="new-password"
/>
```

### Change Password (current + new)

```heex
<.password_field field={@form[:current_password]} label="Current Password" autocomplete="current-password" />
<.password_field field={@form[:new_password]} label="New Password" autocomplete="new-password" />
```
