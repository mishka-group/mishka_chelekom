# File Field Component

File upload component with dropzone support, progress indicators, and live upload integration.

**Documentation**: https://mishka.tools/chelekom/docs/forms/file-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component file_field

# Generate with specific options
mix mishka.ui.gen.component file_field --variant default,outline --color primary,natural

# Generate with custom module name
mix mishka.ui.gen.component file_field --module MyAppWeb.Components.CustomFileField
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `spinner`, `progress`, `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `name` | `:string` | `nil` | Input field name |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Component size |
| `space` | `:string` | `"medium"` | Space between elements |
| `rounded` | `:string` | `"medium"` | Border radius |
| `upload` | `:any` | `nil` | Phoenix LiveView upload reference |
| `accept` | `:string` | `nil` | Accepted file types |
| `multiple` | `:boolean` | `false` | Allow multiple files |
| `max_size` | `:integer` | `nil` | Max file size in bytes |
| `dropzone` | `:boolean` | `false` | Enable drag-and-drop area |
| `dropzone_icon` | `:string` | `"hero-cloud-arrow-up"` | Dropzone icon |
| `dropzone_title` | `:string` | `nil` | Dropzone title text |
| `dropzone_description` | `:string` | `nil` | Dropzone description |
| `error_icon` | `:string` | `nil` | Error icon |
| `errors` | `:list` | `[]` | Error messages |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Custom content for the dropzone.

## Available Options

### Variants
`base`, `default`, `outline`, `bordered`, `shadow`, `gradient`, `transparent`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Space / Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic File Input

```heex
<.file_field name="document" />
```

### With Label and Accept Types

```heex
<.file_field
  name="avatar"
  label="Profile Photo"
  accept="image/*"
  description="PNG, JPG up to 5MB"
/>
```

### Multiple Files

```heex
<.file_field
  name="documents"
  label="Upload Documents"
  multiple={true}
  accept=".pdf,.doc,.docx"
/>
```

### Dropzone Style

```heex
<.file_field
  name="files"
  dropzone={true}
  dropzone_title="Drop files here"
  dropzone_description="or click to browse"
/>
```

### With Live Upload

```heex
<.file_field
  upload={@uploads.avatar}
  dropzone={true}
  dropzone_title="Upload your photo"
  dropzone_description="PNG, JPG up to 10MB"
/>
```

### Different Variants

```heex
<.file_field name="f1" variant="default" label="Default" />
<.file_field name="f2" variant="outline" label="Outline" />
<.file_field name="f3" variant="bordered" label="Bordered" />
<.file_field name="f4" variant="shadow" label="Shadow" />
```

### Different Colors

```heex
<.file_field name="f1" dropzone={true} color="primary" />
<.file_field name="f2" dropzone={true} color="success" />
<.file_field name="f3" dropzone={true} color="info" />
```

### Custom Dropzone Content

```heex
<.file_field upload={@uploads.files} dropzone={true}>
  <div class="text-center">
    <.icon name="hero-photo" class="size-12 mx-auto text-gray-400" />
    <p class="mt-2 font-medium">Upload Images</p>
    <p class="text-sm text-gray-500">Drag photos here or click to browse</p>
  </div>
</.file_field>
```

## Common Patterns

### Profile Photo Upload

```heex
<.form for={@form} phx-submit="save" phx-change="validate">
  <.file_field
    upload={@uploads.avatar}
    dropzone={true}
    color="primary"
    rounded="large"
  >
    <div class="text-center py-8">
      <.avatar
        :if={@preview_url}
        src={@preview_url}
        size="extra_large"
        rounded="full"
        class="mx-auto mb-4"
      />
      <.icon :if={!@preview_url} name="hero-user-circle" class="size-16 mx-auto text-gray-300" />
      <p class="mt-2">Click or drag to upload photo</p>
    </div>
  </.file_field>
</.form>
```

### Document Upload with Preview

```heex
<.form for={@form} phx-submit="upload" phx-change="validate">
  <.file_field
    upload={@uploads.documents}
    dropzone={true}
    dropzone_title="Upload Documents"
    dropzone_description="PDF, DOC, DOCX up to 25MB each"
    multiple={true}
  />

  <div :if={@uploads.documents.entries != []} class="mt-4 space-y-2">
    <div :for={entry <- @uploads.documents.entries} class="flex items-center gap-4 p-3 bg-gray-50 rounded">
      <.icon name="hero-document" class="size-6" />
      <div class="flex-1">
        <p class="font-medium">{entry.client_name}</p>
        <.progress value={entry.progress} size="small" color="primary" />
      </div>
      <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
        <.icon name="hero-x-mark" class="size-5" />
      </button>
    </div>
  </div>

  <.button type="submit" class="mt-4">Upload Files</.button>
</.form>
```

### Image Gallery Upload

```heex
<.file_field
  upload={@uploads.gallery}
  dropzone={true}
  multiple={true}
  accept="image/*"
  variant="outline"
  color="primary"
>
  <div class="py-12 text-center">
    <.icon name="hero-photo" class="size-16 mx-auto text-primary-400" />
    <p class="mt-4 text-lg font-medium">Add photos to gallery</p>
    <p class="text-gray-500">Drop images or click to select</p>
  </div>
</.file_field>
```
