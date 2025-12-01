# Typography Component

Styled text elements including headings, paragraphs, and semantic text.

**Documentation**: https://mishka.tools/chelekom/docs/typography

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component typography
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `h1/1` - `h6/1` | Heading elements |
| `p/1` | Paragraph |
| `strong/1` | Bold text |
| `em/1` | Italic text |
| `small/1` | Small text |
| `mark/1` | Highlighted text |
| `del/1` | Deleted text |
| `s/1` | Strikethrough text |
| `u/1` | Underlined text |
| `cite/1` | Citation |
| `abbr/1` | Abbreviation |
| `dl/1`, `dt/1`, `dd/1` | Description list |
| `figure/1`, `figcaption/1` | Figure with caption |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `:string` | `"inherit"` | Text color |
| `size` | `:string` | varies | Text size |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |

## Available Options

### Colors
`base`, `primary`, `white`, `natural`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`, `inherit`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large`

## Usage Examples

### Headings

```heex
<.h1>Heading 1</.h1>
<.h2>Heading 2</.h2>
<.h3>Heading 3</.h3>
<.h4>Heading 4</.h4>
<.h5>Heading 5</.h5>
<.h6>Heading 6</.h6>
```

### With Colors

```heex
<.h1 color="primary">Primary Heading</.h1>
<.h2 color="secondary">Secondary Heading</.h2>
<.p color="danger">Danger text paragraph</.p>
```

### With Sizes

```heex
<.h1 size="quadruple_large">Extra Large Heading</.h1>
<.h2 size="triple_large">Large Heading</.h2>
<.p size="large">Large paragraph</.p>
<.p size="small">Small paragraph</.p>
```

### With Font Weight

```heex
<.h1 font_weight="font-bold">Bold Heading</.h1>
<.h2 font_weight="font-semibold">Semibold Heading</.h2>
<.p font_weight="font-medium">Medium weight text</.p>
```

### Paragraphs

```heex
<.p>
  This is a paragraph with regular text. It can contain multiple sentences
  and will wrap according to its container.
</.p>

<.p color="natural" size="small">
  A smaller, muted paragraph for secondary information.
</.p>
```

### Semantic Text

```heex
<.p>
  This is <.strong>important</.strong> text with <.em>emphasis</.em>.
</.p>

<.p>
  <.mark>Highlighted text</.mark> stands out from the rest.
</.p>

<.p>
  <.del>Deleted text</.del> and <.s>strikethrough text</.s>.
</.p>

<.p>
  <.u>Underlined text</.u> for special notation.
</.p>

<.p>
  <.small>Small print for legal text or footnotes.</.small>
</.p>
```

### Abbreviation

```heex
<.p>
  The <.abbr title="HyperText Markup Language">HTML</.abbr> specification
  defines the structure of web pages.
</.p>
```

### Citation

```heex
<blockquote>
  <.p>The only way to do great work is to love what you do.</.p>
  <.cite>— Steve Jobs</.cite>
</blockquote>
```

### Description List

```heex
<.dl>
  <.dt>Term 1</.dt>
  <.dd>Definition for term 1</.dd>

  <.dt>Term 2</.dt>
  <.dd>Definition for term 2</.dd>
</.dl>
```

### Figure with Caption

```heex
<.figure>
  <img src="/image.jpg" alt="Description" class="rounded-lg" />
  <.figcaption>Caption describing the image above</.figcaption>
</.figure>
```

## Common Patterns

### Article Header

```heex
<header class="mb-8">
  <.h1 size="quadruple_large" font_weight="font-bold">
    Article Title Here
  </.h1>
  <.p color="natural" size="large" class="mt-2">
    A brief description or subtitle for the article.
  </.p>
</header>
```

### Section with Heading

```heex
<section class="space-y-4">
  <.h2 color="primary" font_weight="font-semibold">Section Title</.h2>
  <.p>
    Section content goes here with regular paragraph text.
  </.p>
</section>
```

### Feature List

```heex
<.dl class="space-y-4">
  <div>
    <.dt font_weight="font-semibold">Feature One</.dt>
    <.dd color="natural">Description of the first feature.</.dd>
  </div>
  <div>
    <.dt font_weight="font-semibold">Feature Two</.dt>
    <.dd color="natural">Description of the second feature.</.dd>
  </div>
</.dl>
```

### Card Content

```heex
<.card>
  <.h3 font_weight="font-semibold">Card Title</.h3>
  <.p color="natural" size="small" class="mt-2">
    Card description with secondary styling.
  </.p>
</.card>
```
