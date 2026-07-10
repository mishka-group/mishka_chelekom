# Combobox Hook

JavaScript hook for a searchable dropdown with autocomplete and single/multiple selection.

## Hook Name

```javascript
Combobox
```

## Used By Components

- `combobox`

## Data Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-multiple` | `boolean` | `false` | Enable multiple selection |

## Features

- **Search/Filter**: Type to filter options
- **Single Selection**: Select one option
- **Multiple Selection**: Select multiple with tags
- **Keyboard Navigation**: Full keyboard support
- **Portal Positioning**: Dropdown positions smartly
- **Option Groups**: Support for grouped options
- **Clear Button**: Remove selections easily
- **Accessibility**: ARIA combobox pattern

## Element Structure

The hook manages this DOM structure:

```html
<div phx-hook="Combobox" data-multiple="false" id="combo-1">
  <select class="combo-select hidden" name="field">
    <option value="">Select...</option>
    <option value="1">Option 1</option>
    <option value="2">Option 2</option>
  </select>

  <div class="relative">
    <button class="combobox-trigger" role="combobox">
      <span class="combobox-value">Select...</span>
    </button>

    <div class="combobox-content" role="listbox">
      <input type="text" class="combobox-search" placeholder="Search..." />
      <div class="combobox-options">
        <div role="option" data-value="1">Option 1</div>
        <div role="option" data-value="2">Option 2</div>
      </div>
    </div>
  </div>
</div>
```

## Usage Examples

### Basic (options list, id/name)

```heex
<.combobox
  id="country-select"
  name="country"
  label="Country"
  options={[{"United States", "us"}, {"Canada", "ca"}, {"Mexico", "mx"}]}
/>
```

### Form Field, with description and default value

```heex
<.combobox
  field={@form[:status]}
  label="Status"
  placeholder="Select status..."
  description="Set the task priority level"
  value="active"
  options={[{"Active", "active"}, {"Inactive", "inactive"}, {"Pending", "pending"}]}
/>
```

`options` accepts any enumerable of `{label, value}` tuples, e.g. `Enum.map(@products, &{&1.name, &1.id})`.

### Multiple Selection

```heex
<.combobox
  field={@form[:tags]}
  label="Tags"
  multiple={true}
  placeholder="Select tags..."
  options={@available_tags}
/>
```

### With Option Slot (custom option content)

```heex
<.combobox id="user-select" name="user_id" label="Assign To">
  <:option :for={user <- @users} value={user.id}>
    <div class="flex items-center gap-2">
      <.avatar src={user.avatar} size="small" />
      <span>{user.name}</span>
    </div>
  </:option>
</.combobox>
```

### Grouped Options

```heex
<.combobox id="timezone" name="timezone" label="Timezone">
  <:option value="America/New_York" group="Americas">Eastern Time (ET)</:option>
  <:option value="America/Los_Angeles" group="Americas">Pacific Time (PT)</:option>
  <:option value="Europe/London" group="Europe">Greenwich Mean Time (GMT)</:option>
  <:option value="Europe/Paris" group="Europe">Central European Time (CET)</:option>
</.combobox>
```

## Keyboard Controls

| Key | Action |
|-----|--------|
| `Enter` | Select highlighted option / Open dropdown |
| `Escape` | Close dropdown |
| `ArrowDown` | Highlight next option |
| `ArrowUp` | Highlight previous option |
| `Home` | Highlight first option |
| `End` | Highlight last option |
| `Backspace` | Remove last tag (multiple mode) |

## CSS Classes

| Class | Description |
|-------|-------------|
| `.combobox-trigger` | Trigger button element |
| `.combobox-content` | Dropdown content container |
| `.combobox-search` | Search input field |
| `.combobox-options` | Options list container |
| `.combobox-value` | Selected value display |
| `.combobox-tag` | Selected item tag (multiple) |
| `.combo-select` | Hidden native select |

## Search Behavior

- Case-insensitive matching
- Filters options as you type
- Shows "No results" when empty
- Clears on close (configurable)

## JavaScript Integration

Register the hook in your `app.js`:

```javascript
import Combobox from "./combobox"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { Combobox }
})
```
