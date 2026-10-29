# Sidebar Component

Collapsible navigation panel with toggle functionality.

**Documentation**: https://mishka.tools/chelekom/docs/sidebar

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component sidebar
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | `sidebar.js` |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | **required** | Unique identifier; the helpers take it |
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"large"` | Width |
| `border` | `:string` | `"extra_small"` | Border on the inner edge (`base`, `outline` and `bordered` only) |
| `position` | `:string` | `"start"` | Edge it sits on: `start` or `end` |
| `hide_position` | `:string` | `nil` | `left` or `right`: below `md` the sidebar starts closed, off-screen to that side. `nil`: always in view |
| `minimize` | `:boolean` | `false` | Render the minimize button (the `Sidebar` hook) |
| `on_hide` | `JS` | `%JS{}` | Commands run before the close button closes it |
| `on_hide_away` | `JS` | `%JS{}` | Commands run before a click outside closes it |
| `on_show` | `JS` | `%JS{}` | Accepted, not used |
| `class` | `:any` | `nil` | Class of the `<aside>` root |
| `content_class` | `:string` | `nil` | Class of the scrolling content |
| `list_wrapper_class` | `:string` | `nil` | Class of the `item` list |
| `minimize_wrapper_class` | `:string` | `nil` | Class of the minimize button's wrapper |
| `hide_button_class` | `:string` | `nil` | Class of the minimize button |
| `minimize_icon_class` | `:string` | `nil` | Class of the minimize icon |
| `close_wrapper_class` | `:string` | `nil` | Class of the close button's wrapper |
| `close_button_class` | `:string` | `nil` | Class of the close button |
| `close_icon_class` | `:string` | `nil` | Class of the close icon |

Global attributes are passed to the root.

## Slots

- `item` — a navigation link, rendered in a list. Attributes: `link`, `label` (or the slot's own
  content), `icon`, `icon_class`, `label_class`, `link_class`, `class`.
- `inner_block` — content rendered after the items.

## Opening and Closing

With a `hide_position`, the sidebar is a menu that slides in below `md` and a fixed column from
`md` up. The close button is shown below `md` only.

- `show_sidebar(js \\ %JS{}, id, hide_position)` — slides it in.
- `hide_sidebar(js \\ %JS{}, id, hide_position)` — slides it out.

Pass the sidebar's own `hide_position`. With `nil` both helpers do nothing. The close button and a
click outside the sidebar close it. The helpers are not in the catalog's import list, so call them
on the module, e.g. `MyAppWeb.Components.Sidebar.show_sidebar("menu", "left")`.

## Keyboard and Focus

- A closed sidebar is hidden while it is off-screen, so Tab skips its links and screen readers do
  not read them. From `md` up it stays in view and in the Tab order.
- Opening moves focus to the first focusable element inside: the minimize button when there is
  one, otherwise the close button below `md`.
- Closing gives focus back to the element that had it when the sidebar opened, if focus is still
  inside the sidebar. Focus a click outside moved elsewhere stays there.
- The sidebar is not modal: Tab can leave it, and Escape does not close it.

## Available Options

| Group | Values |
|-------|--------|
| Variants | `base`, `default`, `outline`, `transparent`, `bordered`, `gradient` |
| Colors | `base`, `natural`, `white`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| Sizes | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| Border | `none`, `extra_small`, `small`, `medium`, `large`, `extra_large` |

The `base` variant ignores `color`. `white` and `dark` are colors of `default` and `bordered`.

## Usage Examples

### Basic Sidebar (position, size, variant)

```heex
<.sidebar id="main-sidebar" color="dark">
  <:item icon="hero-home" label="Home" link="/" />
  <:item icon="hero-shopping-bag" label="Products" link="/products" />
  <:item icon="hero-cog-6-tooth" label="Settings" link="/settings" />
</.sidebar>

<!-- end edge, slides out to the right below md, small, bordered -->
<.sidebar
  id="right-sidebar"
  position="end"
  hide_position="right"
  size="small"
  variant="bordered"
  color="white"
>
  <div class="p-4">Right sidebar content</div>
</.sidebar>

<!-- gradient variant -->
<.sidebar id="gradient-sidebar" variant="gradient" color="primary">
  Gradient sidebar
</.sidebar>
```

### Toggle Button

```heex
<.button class="md:hidden" phx-click={Sidebar.show_sidebar("main-sidebar", "left")}>
  <.icon name="hero-bars-3" class="size-5" />
</.button>

<.sidebar id="main-sidebar" hide_position="left" color="dark">
  Sidebar content
</.sidebar>
```

## Common Patterns

### App Navigation Sidebar

```heex
<.sidebar id="app-sidebar" color="dark" size="medium">
  <div class="flex flex-col h-full">
    <div class="p-4 border-b border-white/10">
      <img src="/logo.svg" alt="Logo" class="h-8" />
    </div>

    <nav class="flex-1 p-4 space-y-1">
      <a href="/" class="flex items-center gap-3 text-white p-2 rounded-sm hover:bg-white/10">
        <.icon name="hero-home" class="size-5" />
        <span>Dashboard</span>
      </a>
      <a href="/users" class="flex items-center gap-3 text-white p-2 rounded-sm hover:bg-white/10">
        <.icon name="hero-users" class="size-5" />
        <span>Users</span>
      </a>
      <a href="/settings" class="flex items-center gap-3 text-white p-2 rounded-sm hover:bg-white/10">
        <.icon name="hero-cog-6-tooth" class="size-5" />
        <span>Settings</span>
      </a>
    </nav>

    <div class="p-4 border-t border-white/10">
      <.button variant="outline" color="white" full_width>
        Logout
      </.button>
    </div>
  </div>
</.sidebar>
```

### Mobile Menu

```heex
<.button class="md:hidden" phx-click={Sidebar.show_sidebar("mobile-menu", "left")}>
  <.icon name="hero-bars-3" class="size-6" />
</.button>

<.sidebar id="mobile-menu" hide_position="left" color="white">
  <:item label="Home" link="/" />
  <:item label="About" link="/about" />
  <:item label="Contact" link="/contact" />
</.sidebar>
```
