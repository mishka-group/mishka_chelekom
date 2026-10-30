# Sidebar Hook

JavaScript hook for sidebar minimize/expand functionality.

## Hook Name

```javascript
Sidebar
```

## Used By Components

- `sidebar` (on its minimize button, rendered with `minimize={true}`)

## Data Attributes

On the minimize button, where the hook is mounted:

| Attribute | Type | Description |
|-----------|------|-------------|
| `data-sidebar-selector` | `string` | CSS selector of the sidebar; required |
| `data-original-width` | `string` | The sidebar's width class; rendered by the component, not read by the hook |

On the sidebar:

| Attribute | Type | Description |
|-----------|------|-------------|
| `data-expanded-width` | `string` | Width when expanded, e.g. `16rem` (`px`, `em`, `rem`, `%`, `vh`, `vw`); default `250px` |
| `data-collapsed-width` | `string` | Width when minimized; default `60px` |
| `data-minimized` | `"true"` / `"false"` | The state; the hook writes it on every toggle |

## Features

- **Minimize/Expand**: each click on the button sets the sidebar's inline `width` to the collapsed or
  the expanded width. The hook adds a 0.3s `width` transition to the transitions the sidebar already
  has, so its slide in and out keeps animating; a sidebar that already transitions `width` or `all`
  keeps its own
- **Cleanup**: `destroyed()` removes the button's click listener
- **Labels**: the `[data-item-label]` elements are hidden while minimized and fade back in on expand
- **Icon Rotation**: the button's `.minimize-icon` toggles `rotate-180`

Opening and closing the sidebar on small screens is not the hook: it is the component's
`show_sidebar/3` and `hide_sidebar/3` (see `components/sidebar.md`).

## Element Structure

The hook is attached to the minimize button:

```html
<aside id="main-sidebar" class="w-80">
  <button
    type="button"
    class="cursor-pointer"
    id="toggle-button-main-sidebar"
    phx-hook="Sidebar"
    data-original-width="w-80"
    data-sidebar-selector="#main-sidebar"
  >
    <span class="minimize-icon hero-chevron-right"></span>
  </button>

  <ul role="list">
    <li>
      <a href="/" class="sidebar-item-link">
        <span class="hero-home"></span>
        <span class="sidebar-text" data-item-label>Home</span>
      </a>
    </li>
  </ul>
</aside>
```

## Usage Examples

### Basic, Minimize, Sizes

```heex
<.sidebar id="app-sidebar">
  <:item icon="hero-home" label="Dashboard" link={~p"/"} />
  <:item icon="hero-users" label="Users" link={~p"/users"} />
  <:item icon="hero-cog-6-tooth" label="Settings" link={~p"/settings"} />
</.sidebar>

<!-- minimize={true} renders the minimize/expand button -->
<.sidebar id="main-sidebar" minimize={true}>
  <:item icon="hero-home" label="Home" link={~p"/"} />
  <:item icon="hero-document" label="Documents" link={~p"/docs"} />
</.sidebar>

<!-- the widths the hook switches between -->
<.sidebar id="small-sidebar" size="small" minimize={true} data-expanded-width="16rem" data-collapsed-width="4rem">
  <:item icon="hero-home" label="Home" link={~p"/"} />
</.sidebar>
```

### Header and Footer Content

The sidebar has no header or footer slot; put them in its content, after the items:

```heex
<.sidebar id="branded-sidebar" minimize={true}>
  <:item icon="hero-home" label="Home" link={~p"/"} />
  <:item icon="hero-inbox" label="Inbox" link={~p"/inbox"} />
  <:item icon="hero-users" label="Users" link={~p"/users"} />

  <div class="p-4 border-t">
    <div class="flex items-center gap-2">
      <.avatar src={@current_user.avatar} size="small" />
      <span class="sidebar-text" data-item-label>{@current_user.name}</span>
    </div>
  </div>
</.sidebar>
```

### Custom Item Content

The slot's content replaces `label`:

```heex
<.sidebar id="custom-sidebar" minimize={true}>
  <:item icon="hero-home" label="Home" link={~p"/"} />
  <:item icon="hero-bell" link={~p"/notifications"}>
    Notifications
    <span class="ml-auto bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">3</span>
  </:item>
</.sidebar>
```

### Mobile Responsive

```heex
<div>
  <button
    type="button"
    class="md:hidden cursor-pointer"
    phx-click={Sidebar.show_sidebar("mobile-sidebar", "left")}
  >
    <.icon name="hero-bars-3" class="size-6" />
  </button>

  <.sidebar id="mobile-sidebar" hide_position="left" minimize={true}>
    <:item icon="hero-home" label="Home" link={~p"/"} />
    <:item icon="hero-folder" label="Files" link={~p"/files"} />
  </.sidebar>
</div>
```

## CSS Classes

| Class | Description |
|-------|-------------|
| `.sidebar-text` | The label of an item (the element also carries `data-item-label`) |
| `.sidebar-item-link` | Navigation item link |
| `.minimize-icon` | Icon that rotates on toggle |
| `.dismiss-sidebar-button` | Close button, shown below `md` |

## Minimized State

When minimized:
- the sidebar's inline `width` is `data-collapsed-width` and `data-minimized` is `"true"`
- every `[data-item-label]` element has `hidden`
- `.minimize-icon` has `rotate-180`

## JavaScript Integration

Register the hook in your `app.js`:

```javascript
import Sidebar from "./sidebar"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { Sidebar }
})
```
