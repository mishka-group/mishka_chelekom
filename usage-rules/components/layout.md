# Layout Component

Flex and grid layout components for building responsive interfaces with Tailwind utilities.

**Documentation**: https://mishka.tools/chelekom/docs/layout

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component layout

# Generate specific component types only
mix mishka.ui.gen.component layout --type flex,grid

# Generate with custom module name
mix mishka.ui.gen.component layout --module MyAppWeb.Components.CustomLayout
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
| `flex/1` | Flexbox container |
| `grid/1` | CSS Grid container |

## Attributes

### `flex/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `direction` | `:string` | `"row"` | Flex direction |
| `justify` | `:string` | `"start"` | Justify content |
| `align` | `:string` | `"stretch"` | Align items |
| `wrap` | `:string` | `"nowrap"` | Flex wrap |
| `gap` | `:string` | `nil` | Gap between items |
| `class` | `:any` | `nil` | Custom CSS class |

### `grid/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `cols` | `:integer` | `1` | Number of columns |
| `rows` | `:integer` | `nil` | Number of rows |
| `gap` | `:string` | `nil` | Gap between items |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Child elements to layout.

## Available Options

### Flex Direction
`row`, `row-reverse`, `col`, `col-reverse`

### Justify Content
`start`, `end`, `center`, `between`, `around`, `evenly`

### Align Items
`start`, `end`, `center`, `baseline`, `stretch`

### Flex Wrap
`nowrap`, `wrap`, `wrap-reverse`

### Gap
`1`, `2`, `3`, `4`, `5`, `6`, `8`, `10`, `12`, etc. (Tailwind spacing scale)

## Usage Examples

### Basic Flex Row

```heex
<.flex gap="4">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</.flex>
```

### Flex Column

```heex
<.flex direction="col" gap="4">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</.flex>
```

### Centered Content

```heex
<.flex justify="center" align="center" class="h-64">
  <div>Centered content</div>
</.flex>
```

### Space Between

```heex
<.flex justify="between" align="center">
  <div>Left</div>
  <div>Right</div>
</.flex>
```

### Wrapping Items

```heex
<.flex wrap="wrap" gap="4">
  <div :for={_i <- 1..10} class="w-24 h-24 bg-gray-200">
    Item
  </div>
</.flex>
```

### Basic Grid

```heex
<.grid cols={3} gap="4">
  <div>Cell 1</div>
  <div>Cell 2</div>
  <div>Cell 3</div>
  <div>Cell 4</div>
  <div>Cell 5</div>
  <div>Cell 6</div>
</.grid>
```

### Two Column Grid

```heex
<.grid cols={2} gap="6">
  <div>Left column</div>
  <div>Right column</div>
</.grid>
```

### Four Column Grid

```heex
<.grid cols={4} gap="4">
  <div :for={_i <- 1..8} class="p-4 bg-gray-100 rounded">
    Grid item
  </div>
</.grid>
```

### Mixed Layout

```heex
<.flex direction="col" gap="8">
  <header>
    <.flex justify="between" align="center">
      <div>Logo</div>
      <nav>Navigation</nav>
    </.flex>
  </header>

  <main>
    <.grid cols={3} gap="6">
      <div class="col-span-2">Main content</div>
      <aside>Sidebar</aside>
    </.grid>
  </main>

  <footer>Footer</footer>
</.flex>
```

## Common Patterns

### Header Layout

```heex
<.flex justify="between" align="center" class="p-4 border-b">
  <.flex align="center" gap="4">
    <img src="/logo.svg" alt="Logo" class="h-8" />
    <nav>
      <.flex gap="4">
        <a href="/">Home</a>
        <a href="/about">About</a>
        <a href="/contact">Contact</a>
      </.flex>
    </nav>
  </.flex>
  <.flex gap="2">
    <.button variant="outline">Login</.button>
    <.button color="primary">Sign Up</.button>
  </.flex>
</.flex>
```

### Card Grid

```heex
<.grid cols={3} gap="6">
  <.card :for={item <- @items}>
    <.card_title title={item.title} />
    <.card_content>{item.description}</.card_content>
  </.card>
</.grid>
```

### Sidebar Layout

```heex
<.flex class="min-h-screen">
  <aside class="w-64 border-r">
    <.flex direction="col" class="h-full">
      <div class="p-4 border-b">Logo</div>
      <nav class="flex-1 p-4">Navigation</nav>
      <div class="p-4 border-t">User</div>
    </.flex>
  </aside>
  <main class="flex-1 p-6">
    Content
  </main>
</.flex>
```

### Form Layout

```heex
<.flex direction="col" gap="6">
  <.grid cols={2} gap="4">
    <.text_field field={@form[:first_name]} label="First Name" />
    <.text_field field={@form[:last_name]} label="Last Name" />
  </.grid>
  <.email_field field={@form[:email]} label="Email" />
  <.flex justify="end" gap="4">
    <.button variant="outline">Cancel</.button>
    <.button type="submit" color="primary">Save</.button>
  </.flex>
</.flex>
```

### Feature Grid

```heex
<.grid cols={3} gap="8">
  <.flex :for={feature <- @features} direction="col" align="center" gap="4" class="text-center">
    <.icon name={feature.icon} class="size-12 text-primary-500" />
    <h3 class="font-bold text-lg">{feature.title}</h3>
    <p class="text-gray-600">{feature.description}</p>
  </.flex>
</.grid>
```
