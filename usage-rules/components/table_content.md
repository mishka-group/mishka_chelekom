# Table Content Component

Structured content display within table-like layouts.

**Documentation**: https://mishka.tools/chelekom/docs/table-content

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component table_content
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
| `table_content/1` | Content container |
| `content_wrapper/1` | Nested content wrapper |
| `content_item/1` | Individual content item |

## Attributes

### `table_content/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"base"` | Color theme |
| `rounded` | `:string` | `"medium"` | Border radius |
| `space` | `:string` | `"small"` | Space between items |
| `size` | `:string` | `"medium"` | Content size |
| `padding` | `:string` | `"small"` | Container padding |
| `title` | `:string` | `nil` | Section title |
| `animated` | `:boolean` | `false` | Animation effect |

### `content_item/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `:string` | `nil` | Item icon |
| `title` | `:string` | `nil` | Item title |
| `active` | `:boolean` | `false` | Active state |
| `font_weight` | `:string` | `nil` | Text weight |

## Available Options

### Variants
`base`, `outline`, `default`, `bordered`, `transparent`, `gradient`

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

## Usage Examples

### Basic Table Content

```heex
<.table_content title="Contents">
  <.content_item icon="hero-hashtag">
    <.link href="#introduction">Introduction</.link>
  </.content_item>
  <.content_item icon="hero-hashtag">
    <.link href="#getting-started">Getting Started</.link>
  </.content_item>
  <.content_item icon="hero-hashtag">
    <.link href="#examples">Examples</.link>
  </.content_item>
</.table_content>
```

### With Nested Content

```heex
<.table_content color="primary">
  <.content_item icon="hero-hashtag">
    <.link href="#intro">Introduction</.link>
  </.content_item>

  <.content_item title="Components">
    <.content_wrapper>
      <.content_item icon="hero-hashtag">
        <.link href="#buttons">Buttons</.link>
      </.content_item>
      <.content_item icon="hero-hashtag">
        <.link href="#forms">Forms</.link>
      </.content_item>
    </.content_wrapper>
  </.content_item>

  <.content_item icon="hero-hashtag">
    <.link href="#api">API Reference</.link>
  </.content_item>
</.table_content>
```

### With Animation

```heex
<.table_content animated color="info">
  <.content_item icon="hero-document">Chapter 1</.content_item>
  <.content_item icon="hero-document">Chapter 2</.content_item>
  <.content_item icon="hero-document">Chapter 3</.content_item>
</.table_content>
```

### Active State

```heex
<.table_content>
  <.content_item icon="hero-hashtag" active>Current Section</.content_item>
  <.content_item icon="hero-hashtag">Next Section</.content_item>
  <.content_item icon="hero-hashtag">Final Section</.content_item>
</.table_content>
```

### Different Variants

```heex
<.table_content variant="bordered" color="natural">
  <.content_item>Bordered Style</.content_item>
</.table_content>

<.table_content variant="outline" color="primary">
  <.content_item>Outline Style</.content_item>
</.table_content>
```

## Common Patterns

### Documentation Sidebar

```heex
<aside class="w-64">
  <.table_content title="Documentation" color="natural">
    <.content_item icon="hero-home">
      <.link navigate="/">Overview</.link>
    </.content_item>

    <.content_item title="Getting Started">
      <.content_wrapper>
        <.content_item icon="hero-arrow-right">
          <.link navigate="/installation">Installation</.link>
        </.content_item>
        <.content_item icon="hero-arrow-right">
          <.link navigate="/quickstart">Quick Start</.link>
        </.content_item>
      </.content_wrapper>
    </.content_item>

    <.content_item title="Components">
      <.content_wrapper>
        <.content_item :for={component <- @components} icon="hero-cube">
          <.link navigate={component.path}>{component.name}</.link>
        </.content_item>
      </.content_wrapper>
    </.content_item>
  </.table_content>
</aside>
```

### Article Table of Contents

```heex
<.table_content title="On this page" variant="transparent" animated>
  <.content_item
    :for={heading <- @headings}
    icon="hero-hashtag"
    active={@current_section == heading.id}
  >
    <.link href={"##{heading.id}"}>{heading.text}</.link>
  </.content_item>
</.table_content>
```
