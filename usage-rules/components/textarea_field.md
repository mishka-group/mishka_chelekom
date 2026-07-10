# Textarea Field Component

Multi-line text input with customizable styling and resize control.

**Documentation**: https://mishka.tools/chelekom/docs/forms/textarea-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component textarea_field
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
| `size` | `:string` | `"medium"` | Textarea height — `extra_small`, `small`, `medium`, `large`, `extra_large`, `auto` |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `label` | `:string` | `nil` | Label text |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `description` | `:string` | `nil` | Description text |
| `floating` | `:string` | `nil` | Floating label |
| `disable_resize` | `:boolean` | `false` | Disable resizing |

## Slots

- `start_section` / `end_section` — content before/after the textarea.

## Usage Examples

### Basic / field / description

```heex
<.textarea_field name="message" label="Message" placeholder="Tell us about yourself..." />

<.textarea_field
  field={@form[:description]}
  label="Description"
  placeholder="Enter a description"
  description="Maximum 500 characters"
/>
```

### Floating label

```heex
<.textarea_field name="comment" floating="outer" label="Your Comment" />
```

### Disable resize

```heex
<.textarea_field name="message" label="Message" disable_resize />
```

### Sizes, variants, auto height

```heex
<.textarea_field name="small" label="Small" size="small" />
<.textarea_field name="large" label="Large" size="large" />
<.textarea_field name="content" label="Content" size="auto" />

<.textarea_field name="text" variant="default" label="Default" />
<.textarea_field name="text" variant="outline" label="Outline" />
<.textarea_field name="text" variant="bordered" label="Bordered" />
```

## Common Patterns

### Contact form message

```heex
<.form for={@form} phx-submit="submit">
  <.text_field field={@form[:name]} label="Name" />
  <.email_field field={@form[:email]} label="Email" />
  <.textarea_field
    field={@form[:message]}
    label="Message"
    placeholder="How can we help you?"
    size="large"
    description="Please provide as much detail as possible"
  />
  <.button type="submit" color="primary">Send Message</.button>
</.form>
```

### Blog post editor

```heex
<.textarea_field
  field={@form[:content]}
  label="Post Content"
  size="extra_large"
  variant="bordered"
  placeholder="Write your post content here..."
/>
```

### Review form

```heex
<div class="space-y-4">
  <.rating interactive select={@rating} on_select="set_rating" />
  <.textarea_field
    field={@form[:review]}
    label="Your Review"
    placeholder="Share your experience..."
    size="medium"
  />
</div>
```

### Character counter

```heex
<div class="relative">
  <.textarea_field
    name="bio"
    label="Bio"
    value={@bio}
    phx-change="update_bio"
    maxlength="500"
  />
  <span class="absolute bottom-2 right-2 text-sm text-gray-500">
    {String.length(@bio)}/500
  </span>
</div>
```
