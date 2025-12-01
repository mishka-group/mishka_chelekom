# URL Field Component

URL input with customizable styling and validation.

**Documentation**: https://mishka.tools/chelekom/docs/forms/url-field

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component url_field
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
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `size` | `:string` | `"medium"` | Input size |
| `rounded` | `:string` | `"small"` | Border radius |
| `space` | `:string` | `"medium"` | Space between elements |
| `label` | `:string` | `nil` | Label text |
| `placeholder` | `:string` | `nil` | Placeholder text |
| `description` | `:string` | `nil` | Description text |
| `floating` | `:string` | `nil` | Floating label |

## Slots

### `start_section` / `end_section` Slots

Content before/after input.

## Available Options

### Variants
`base`, `default`, `outline`, `shadow`, `bordered`, `transparent`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic URL Field

```heex
<.url_field name="website" label="Website" />
```

### With Placeholder

```heex
<.url_field
  name="website"
  label="Website URL"
  placeholder="https://example.com"
/>
```

### With Form Field

```heex
<.url_field
  field={@form[:website]}
  label="Website"
  placeholder="Enter your website URL"
/>
```

### With Description

```heex
<.url_field
  name="portfolio"
  label="Portfolio URL"
  description="Link to your online portfolio or personal website"
/>
```

### Floating Label

```heex
<.url_field
  name="website"
  floating="outer"
  label="Website URL"
/>
```

### Different Variants

```heex
<.url_field name="url" variant="default" label="Default" />
<.url_field name="url" variant="outline" label="Outline" />
<.url_field name="url" variant="bordered" label="Bordered" />
```

### With Link Icon

```heex
<.url_field name="website" label="Website">
  <:start_section>
    <.icon name="hero-link" class="size-5" />
  </:start_section>
</.url_field>
```

### With Protocol Prefix

```heex
<.url_field name="website" label="Website">
  <:start_section>
    <span class="text-gray-500 text-sm">https://</span>
  </:start_section>
</.url_field>
```

## Common Patterns

### Social Links Form

```heex
<div class="space-y-4">
  <.url_field field={@form[:website]} label="Website">
    <:start_section>
      <.icon name="hero-globe-alt" class="size-5" />
    </:start_section>
  </.url_field>

  <.url_field field={@form[:linkedin]} label="LinkedIn">
    <:start_section>
      <.icon name="hero-link" class="size-5" />
    </:start_section>
  </.url_field>

  <.url_field field={@form[:github]} label="GitHub">
    <:start_section>
      <.icon name="hero-code-bracket" class="size-5" />
    </:start_section>
  </.url_field>
</div>
```

### Profile Links

```heex
<.form for={@form} phx-submit="save_profile">
  <.text_field field={@form[:name]} label="Name" />
  <.email_field field={@form[:email]} label="Email" />

  <div class="mt-6">
    <h3 class="font-medium mb-4">Social Links</h3>

    <.url_field
      field={@form[:website]}
      label="Personal Website"
      placeholder="https://yoursite.com"
    />

    <.url_field
      field={@form[:portfolio]}
      label="Portfolio"
      placeholder="https://portfolio.com/username"
    />
  </div>

  <.button type="submit" color="primary" class="mt-6">
    Save Profile
  </.button>
</.form>
```

### Company Information

```heex
<fieldset class="space-y-4">
  <legend class="font-medium mb-2">Company Links</legend>

  <.url_field
    field={@form[:company_website]}
    label="Company Website"
    placeholder="https://company.com"
  >
    <:start_section>
      <.icon name="hero-building-office" class="size-5" />
    </:start_section>
  </.url_field>

  <.url_field
    field={@form[:careers_page]}
    label="Careers Page"
    placeholder="https://company.com/careers"
  >
    <:start_section>
      <.icon name="hero-briefcase" class="size-5" />
    </:start_section>
  </.url_field>
</fieldset>
```
