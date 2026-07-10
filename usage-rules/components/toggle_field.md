# Toggle Field Component

Binary on/off switch input with customizable styling.

**Documentation**: https://mishka.tools/chelekom/docs/forms/toggle

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component toggle_field
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
| `color` | `:string` | `"primary"` | Color theme — `base`, `white`, `natural`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"medium"` | Toggle size — `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `rounded` | `:string` | `"full"` | Border radius |
| `border` | `:string` | `"extra_small"` | Border style |
| `label` | `:string` | `nil` | Label text |
| `description` | `:string` | `nil` | Description text |
| `checked` | `:boolean` | `false` | Toggle state |

## Usage Examples

### Basic / Checked / Form Field / Description

```heex
<.toggle_field name="notifications" label="Enable notifications" />
<.toggle_field name="active" label="Active" checked />
<.toggle_field field={@form[:email_notifications]} label="Email notifications" />
<.toggle_field
  name="marketing"
  label="Marketing emails"
  description="Receive updates about new features and promotions"
/>
```

### Colors

```heex
<.toggle_field name="primary" label="Primary" color="primary" checked />
<.toggle_field name="success" label="Success" color="success" checked />
<.toggle_field name="warning" label="Warning" color="warning" checked />
<.toggle_field name="danger" label="Danger" color="danger" checked />
```

### Sizes

```heex
<.toggle_field name="xs" label="Extra Small" size="extra_small" />
<.toggle_field name="sm" label="Small" size="small" />
<.toggle_field name="md" label="Medium" size="medium" />
<.toggle_field name="lg" label="Large" size="large" />
<.toggle_field name="xl" label="Extra Large" size="extra_large" />
```

## Common Patterns

### Form-Based Settings (grouped, submits via `field`)

```heex
<.form for={@form} phx-submit="save_privacy">
  <div class="space-y-4">
    <.toggle_field
      field={@form[:profile_public]}
      label="Public profile"
      description="Allow others to view your profile"
      color="primary"
    />
    <.toggle_field
      field={@form[:show_online_status]}
      label="Show online status"
      description="Let others see when you're online"
      color="primary"
    />
  </div>
  <.button type="submit" class="mt-6">Save Settings</.button>
</.form>
```

### Live Toggle (assign-driven, `phx-click`)

```heex
<div class="flex items-center justify-between p-4 border rounded-lg">
  <div>
    <h3 class="font-medium">Two-factor authentication</h3>
    <p class="text-sm text-gray-600">Add an extra layer of security</p>
  </div>
  <.toggle_field
    name="2fa"
    checked={@two_factor_enabled}
    phx-click="toggle_2fa"
    color="success"
  />
</div>
```
