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
| `color` | `:string` | `"primary"` | Color theme |
| `size` | `:string` | `"medium"` | Toggle size |
| `rounded` | `:string` | `"full"` | Border radius |
| `border` | `:string` | `"extra_small"` | Border style |
| `label` | `:string` | `nil` | Label text |
| `description` | `:string` | `nil` | Description text |
| `checked` | `:boolean` | `false` | Toggle state |

## Available Options

### Colors
`base`, `white`, `natural`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Toggle

```heex
<.toggle_field name="notifications" label="Enable notifications" />
```

### Checked State

```heex
<.toggle_field name="active" label="Active" checked />
```

### With Form Field

```heex
<.toggle_field
  field={@form[:email_notifications]}
  label="Email notifications"
/>
```

### With Description

```heex
<.toggle_field
  name="marketing"
  label="Marketing emails"
  description="Receive updates about new features and promotions"
/>
```

### Different Colors

```heex
<.toggle_field name="primary" label="Primary" color="primary" checked />
<.toggle_field name="success" label="Success" color="success" checked />
<.toggle_field name="warning" label="Warning" color="warning" checked />
<.toggle_field name="danger" label="Danger" color="danger" checked />
```

### Different Sizes

```heex
<.toggle_field name="xs" label="Extra Small" size="extra_small" />
<.toggle_field name="sm" label="Small" size="small" />
<.toggle_field name="md" label="Medium" size="medium" />
<.toggle_field name="lg" label="Large" size="large" />
<.toggle_field name="xl" label="Extra Large" size="extra_large" />
```

### Dark Theme

```heex
<.toggle_field name="dark" label="Dark mode" color="dark" checked />
```

## Common Patterns

### Settings Page

```heex
<div class="space-y-6">
  <h2 class="text-lg font-bold">Notification Settings</h2>

  <.toggle_field
    field={@form[:email_notifications]}
    label="Email notifications"
    description="Get notified about important updates via email"
  />

  <.toggle_field
    field={@form[:push_notifications]}
    label="Push notifications"
    description="Receive push notifications on your device"
  />

  <.toggle_field
    field={@form[:sms_notifications]}
    label="SMS notifications"
    description="Get text messages for urgent alerts"
  />
</div>
```

### Feature Toggles

```heex
<div class="divide-y">
  <div class="py-4">
    <.toggle_field
      name="dark_mode"
      label="Dark mode"
      description="Use dark theme across the application"
      checked={@dark_mode}
      phx-click="toggle_dark_mode"
    />
  </div>
  <div class="py-4">
    <.toggle_field
      name="compact_view"
      label="Compact view"
      description="Show more items in lists"
      checked={@compact_view}
      phx-click="toggle_compact_view"
    />
  </div>
</div>
```

### Privacy Settings

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
    <.toggle_field
      field={@form[:allow_messages]}
      label="Allow direct messages"
      description="Let anyone send you messages"
      color="primary"
    />
  </div>
  <.button type="submit" class="mt-6">Save Settings</.button>
</.form>
```

### Enable/Disable Feature

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
