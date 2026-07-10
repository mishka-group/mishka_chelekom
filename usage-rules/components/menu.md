# Menu Component

Hierarchical menu for navigation with nested sub-menus and accordion support.

**Documentation**: https://mishka.tools/chelekom/docs/menu

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component menu

# Generate with specific options
mix mishka.ui.gen.component menu --space small,medium --padding small,medium

# Generate with custom module name
mix mishka.ui.gen.component menu --module MyAppWeb.Components.CustomMenu
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `collapse`, `button` |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `items` | `:list` | `[]` | Menu items as list of maps |
| `space` | `:string` | `"small"` | Space between items — `extra_small`, `small`, `medium`, `large`, `extra_large`, `none` |
| `padding` | `:string` | `"small"` | Item padding — `extra_small`, `small`, `medium`, `large`, `extra_large`, `none` |
| `class` | `:any` | `nil` | Custom CSS class |

## Menu Item Structure

Each menu item is a map with these keys:

| Key | Type | Description |
|-----|------|-------------|
| `label` | `:string` | Display text |
| `link` | `:string` | Navigation URL |
| `icon` | `:string` | Icon name |
| `submenu` | `:list` | Nested menu items (same map shape, can nest arbitrarily deep) |
| `active` | `:boolean` | Active state |

## Slots

### `inner_block` Slot

Custom menu content.

## Usage Examples

### Basic menu with active state

```heex
<.menu items={[
  %{label: "Home", link: "/", icon: "hero-home", active: @current_path == "/"},
  %{label: "Dashboard", link: "/dashboard", icon: "hero-chart-bar", active: @current_path == "/dashboard"},
  %{label: "Profile", link: "/profile", icon: "hero-user", active: @current_path == "/profile"}
]} />
```

### With nested submenu and custom spacing

```heex
<.menu
  items={[
    %{label: "Overview", link: "/admin", icon: "hero-home"},
    %{
      label: "Users",
      icon: "hero-users",
      submenu: [
        %{label: "All Users", link: "/admin/users"},
        %{label: "Add User", link: "/admin/users/new"},
        %{label: "Roles & Permissions", link: "/admin/roles"}
      ]
    },
    %{
      label: "Content",
      icon: "hero-document-text",
      submenu: [
        %{label: "Articles", link: "/admin/articles", active: @page == :articles},
        %{label: "Categories", link: "/admin/categories"},
        %{label: "Tags", link: "/admin/tags"}
      ]
    }
  ]}
  space="medium"
  padding="medium"
/>
```

### Deep nesting (submenu within submenu)

```heex
<.menu items={[
  %{
    label: "Settings",
    icon: "hero-cog-6-tooth",
    submenu: [
      %{
        label: "Account",
        submenu: [
          %{label: "Profile", link: "/settings/account/profile"},
          %{label: "Security", link: "/settings/account/security"}
        ]
      },
      %{
        label: "Preferences",
        submenu: [
          %{label: "Theme", link: "/settings/preferences/theme"},
          %{label: "Language", link: "/settings/preferences/language"}
        ]
      }
    ]
  }
]} />
```

### Dynamic menu from database

```heex
<.menu items={
  Enum.map(@nav_items, fn item ->
    %{
      label: item.title,
      link: item.path,
      icon: item.icon,
      active: @current_path == item.path,
      submenu: Enum.map(item.children || [], fn child ->
        %{label: child.title, link: child.path, active: @current_path == child.path}
      end)
    }
  end)
} />
```

### Sidebar navigation

```heex
<aside class="w-64 border-r h-screen">
  <div class="p-4 border-b">
    <img src="/logo.svg" alt="Logo" class="h-8" />
  </div>
  <nav class="p-4">
    <.menu
      items={[
        %{label: "Dashboard", link: "/dashboard", icon: "hero-home", active: @page == :dashboard},
        %{label: "Analytics", link: "/analytics", icon: "hero-chart-bar", active: @page == :analytics},
        %{
          label: "Content",
          icon: "hero-document-text",
          submenu: [
            %{label: "Posts", link: "/posts", active: @page == :posts},
            %{label: "Pages", link: "/pages", active: @page == :pages},
            %{label: "Media", link: "/media", active: @page == :media}
          ]
        },
        %{label: "Settings", link: "/settings", icon: "hero-cog-6-tooth", active: @page == :settings}
      ]}
      space="small"
      padding="small"
    />
  </nav>
</aside>
```
