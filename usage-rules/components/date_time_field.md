# Date Time Field Component

Date and time input component supporting multiple input types with customizable styling.

**Documentation**: https://mishka.tools/chelekom/docs/forms/date-time-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component date_time_field

# Generate with specific options
mix mishka.ui.gen.component date_time_field --variant default,outline --color primary,natural

# Generate with custom module name
mix mishka.ui.gen.component date_time_field --module MyAppWeb.Components.CustomDateTimeField
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
| `id` | `:string` | `nil` | Unique identifier |
| `name` | `:string` | `nil` | Input field name |
| `type` | `:string` | `"date"` | Input type: `date`, `datetime-local`, `time`, `week`, `month` |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Input size |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `floating` | `:string` | `nil` | Floating label: `inner`, `outer` |
| `label` | `:string` | `nil` | Label text |
| `description` | `:string` | `nil` | Description text |
| `min` | `:string` | `nil` | Minimum value |
| `max` | `:string` | `nil` | Maximum value |
| `error_icon` | `:string` | `nil` | Error icon |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `start_section` Slot

Content before the input.

### `end_section` Slot

Content after the input.

## Available Options

### Variants
`base`, `default`, `outline`, `bordered`, `shadow`, `transparent`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Input Types
`date`, `datetime-local`, `time`, `week`, `month`

## Usage Examples

### Date Input

```heex
<.date_time_field
  name="birth_date"
  type="date"
  label="Birth Date"
/>
```

### DateTime Input

```heex
<.date_time_field
  name="appointment"
  type="datetime-local"
  label="Appointment Time"
/>
```

### Time Input

```heex
<.date_time_field
  name="start_time"
  type="time"
  label="Start Time"
/>
```

### Week Input

```heex
<.date_time_field
  name="week"
  type="week"
  label="Select Week"
/>
```

### Month Input

```heex
<.date_time_field
  name="month"
  type="month"
  label="Select Month"
/>
```

### With Floating Label

```heex
<.date_time_field
  name="event_date"
  type="date"
  floating="outer"
  label="Event Date"
/>
```

### With Min/Max

```heex
<.date_time_field
  name="booking_date"
  type="date"
  label="Booking Date"
  min={Date.to_string(Date.utc_today())}
  max={Date.to_string(Date.add(Date.utc_today(), 30))}
/>
```

### Different Variants

```heex
<.date_time_field name="d1" type="date" variant="default" label="Default" />
<.date_time_field name="d2" type="date" variant="outline" label="Outline" />
<.date_time_field name="d3" type="date" variant="shadow" label="Shadow" />
<.date_time_field name="d4" type="date" variant="bordered" label="Bordered" />
```

### Different Colors

```heex
<.date_time_field name="d1" type="date" color="primary" label="Primary" />
<.date_time_field name="d2" type="date" color="success" label="Success" />
<.date_time_field name="d3" type="date" color="danger" label="Danger" />
```

### With Form Integration

```heex
<.form for={@form} phx-submit="save">
  <.date_time_field
    field={@form[:start_date]}
    type="date"
    label="Start Date"
    description="When should this begin?"
  />
  <.date_time_field
    field={@form[:end_date]}
    type="date"
    label="End Date"
  />
</.form>
```

## Common Patterns

### Date Range

```heex
<div class="flex gap-4">
  <.date_time_field
    field={@form[:start_date]}
    type="date"
    label="From"
  />
  <.date_time_field
    field={@form[:end_date]}
    type="date"
    label="To"
  />
</div>
```

### Event Scheduling

```heex
<div class="space-y-4">
  <.date_time_field
    field={@form[:event_date]}
    type="date"
    label="Event Date"
  />
  <div class="flex gap-4">
    <.date_time_field
      field={@form[:start_time]}
      type="time"
      label="Start Time"
    />
    <.date_time_field
      field={@form[:end_time]}
      type="time"
      label="End Time"
    />
  </div>
</div>
```
