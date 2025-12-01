# Sidebar Hook

JavaScript hook for sidebar minimize/expand functionality.

## Hook Name

```javascript
Sidebar
```

## Used By Components

- `sidebar`

## Data Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `data-original-width` | `string` | Original sidebar width class |
| `data-sidebar-selector` | `string` | CSS selector for sidebar element |

## Features

- **Minimize/Expand**: Toggle sidebar width
- **Icon Rotation**: Chevron icon rotates on state change
- **Text Hiding**: Labels hide when minimized
- **Persistent State**: Remembers minimized state
- **Smooth Animation**: CSS transitions for width changes
- **Mobile Support**: Full close on mobile devices

## Element Structure

The hook is attached to the minimize button:

```html
<aside id="main-sidebar" class="w-64">
  <button
    phx-hook="Sidebar"
    data-original-width="w-64"
    data-sidebar-selector="#main-sidebar"
  >
    <span class="minimize-icon">→</span>
  </button>

  <nav>
    <a href="/" class="sidebar-item-link">
      <span class="icon">🏠</span>
      <span class="sidebar-text">Home</span>
    </a>
  </nav>
</aside>
```

## Usage Examples

### Basic Sidebar

```heex
<.sidebar id="app-sidebar">
  <:item icon="hero-home" label="Dashboard" link={~p"/"} />
  <:item icon="hero-users" label="Users" link={~p"/users"} />
  <:item icon="hero-cog-6-tooth" label="Settings" link={~p"/settings"} />
</.sidebar>
```

### With Minimize Button

```heex
<.sidebar id="main-sidebar" minimize={true}>
  <:item icon="hero-home" label="Home" link={~p"/"} />
  <:item icon="hero-document" label="Documents" link={~p"/docs"} />
  <:item icon="hero-chart-bar" label="Analytics" link={~p"/analytics"} />
</.sidebar>
```

### With Header

```heex
<.sidebar id="branded-sidebar" minimize={true}>
  <:header>
    <div class="flex items-center gap-2 p-4">
      <img src="/logo.svg" class="h-8" />
      <span class="sidebar-text font-bold">MyApp</span>
    </div>
  </:header>

  <:item icon="hero-home" label="Home" link={~p"/"} />
  <:item icon="hero-folder" label="Projects" link={~p"/projects"} />
</.sidebar>
```

### With Footer

```heex
<.sidebar id="nav-sidebar">
  <:item icon="hero-home" label="Dashboard" link={~p"/"} />
  <:item icon="hero-users" label="Team" link={~p"/team"} />

  <:footer>
    <div class="p-4 border-t">
      <div class="flex items-center gap-2">
        <.avatar src={@current_user.avatar} size="small" />
        <span class="sidebar-text">{@current_user.name}</span>
      </div>
    </div>
  </:footer>
</.sidebar>
```

### With Groups

```heex
<.sidebar id="grouped-sidebar" minimize={true}>
  <:group title="Main">
    <:item icon="hero-home" label="Home" link={~p"/"} />
    <:item icon="hero-inbox" label="Inbox" link={~p"/inbox"} />
  </:group>

  <:group title="Management">
    <:item icon="hero-users" label="Users" link={~p"/users"} />
    <:item icon="hero-building-office" label="Teams" link={~p"/teams"} />
  </:group>

  <:group title="Settings">
    <:item icon="hero-cog-6-tooth" label="Preferences" link={~p"/settings"} />
    <:item icon="hero-shield-check" label="Security" link={~p"/security"} />
  </:group>
</.sidebar>
```

### Different Sizes

```heex
<.sidebar id="small-sidebar" size="small" minimize={true}>
  <:item icon="hero-home" label="Home" link={~p"/"} />
</.sidebar>

<.sidebar id="large-sidebar" size="large" minimize={true}>
  <:item icon="hero-home" label="Home" link={~p"/"} />
</.sidebar>
```

### With Custom Content

```heex
<.sidebar id="custom-sidebar" minimize={true}>
  <:item icon="hero-home" label="Home" link={~p"/"} />
  <:item icon="hero-bell" label="Notifications" link={~p"/notifications"}>
    <span class="ml-auto bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">
      3
    </span>
  </:item>
  <:item icon="hero-envelope" label="Messages" link={~p"/messages"} />
</.sidebar>
```

### Mobile Responsive

```heex
<div>
  <!-- Mobile toggle button -->
  <button
    class="md:hidden"
    phx-click={JS.toggle(to: "#mobile-sidebar")}
  >
    <.icon name="hero-bars-3" class="size-6" />
  </button>

  <.sidebar
    id="mobile-sidebar"
    class="hidden md:block"
    minimize={true}
  >
    <:item icon="hero-home" label="Home" link={~p"/"} />
    <:item icon="hero-folder" label="Files" link={~p"/files"} />
  </.sidebar>
</div>
```

## CSS Classes

| Class | Description |
|-------|-------------|
| `.sidebar-text` | Text that hides when minimized |
| `.sidebar-item-link` | Navigation item link |
| `.minimize-icon` | Icon that rotates on toggle |
| `.dismiss-sidebar-button` | Mobile close button |

## Minimized State

When minimized:
- Sidebar width reduces (typically to icon-only width)
- `.sidebar-text` elements are hidden
- `.minimize-icon` rotates 180 degrees
- Tooltips can show on hover (optional)

## CSS for Minimized State

```css
/* Minimized sidebar */
.sidebar.minimized {
  width: 4rem; /* Icon-only width */
}

.sidebar.minimized .sidebar-text {
  display: none;
}

.sidebar.minimized .minimize-icon {
  transform: rotate(180deg);
}
```

## JavaScript Integration

Register the hook in your `app.js`:

```javascript
import Sidebar from "./sidebar"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { Sidebar }
})
```
