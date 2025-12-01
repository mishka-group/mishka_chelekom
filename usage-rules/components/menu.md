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
| `space` | `:string` | `"small"` | Space between items |
| `padding` | `:string` | `"small"` | Item padding |
| `class` | `:any` | `nil` | Custom CSS class |

## Menu Item Structure

Each menu item is a map with these keys:

| Key | Type | Description |
|-----|------|-------------|
| `label` | `:string` | Display text |
| `link` | `:string` | Navigation URL |
| `icon` | `:string` | Icon name |
| `submenu` | `:list` | Nested menu items |
| `active` | `:boolean` | Active state |

## Slots

### `inner_block` Slot

Custom menu content.

## Available Options

### Space
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

## Usage Examples

### Basic Menu

```heex
<.menu items={[
  %{label: "Home", link: "/", icon: "hero-home"},
  %{label: "About", link: "/about", icon: "hero-information-circle"},
  %{label: "Contact", link: "/contact", icon: "hero-envelope"}
]} />
```

### With Nested Submenu

```heex
<.menu items={[
  %{label: "Dashboard", link: "/dashboard", icon: "hero-home"},
  %{
    label: "Products",
    icon: "hero-cube",
    submenu: [
      %{label: "All Products", link: "/products"},
      %{label: "Add Product", link: "/products/new"},
      %{label: "Categories", link: "/categories"}
    ]
  },
  %{
    label: "Users",
    icon: "hero-users",
    submenu: [
      %{label: "All Users", link: "/users"},
      %{label: "Roles", link: "/roles"}
    ]
  },
  %{label: "Settings", link: "/settings", icon: "hero-cog-6-tooth"}
]} />
```

### With Active State

```heex
<.menu items={[
  %{label: "Home", link: "/", icon: "hero-home", active: @current_path == "/"},
  %{label: "Dashboard", link: "/dashboard", icon: "hero-chart-bar", active: @current_path == "/dashboard"},
  %{label: "Profile", link: "/profile", icon: "hero-user", active: @current_path == "/profile"}
]} />
```

### Custom Spacing

```heex
<.menu
  items={@menu_items}
  space="medium"
  padding="medium"
/>
```

### Deep Nesting

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
          %{label: "Security", link: "/settings/account/security"},
          %{label: "Notifications", link: "/settings/account/notifications"}
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

## Common Patterns

### Sidebar Navigation

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
        %{
          label: "E-commerce",
          icon: "hero-shopping-cart",
          submenu: [
            %{label: "Products", link: "/products"},
            %{label: "Orders", link: "/orders"},
            %{label: "Customers", link: "/customers"}
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

### Admin Panel Menu

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
        %{label: "Articles", link: "/admin/articles"},
        %{label: "Categories", link: "/admin/categories"},
        %{label: "Tags", link: "/admin/tags"}
      ]
    },
    %{
      label: "System",
      icon: "hero-server",
      submenu: [
        %{label: "Configuration", link: "/admin/config"},
        %{label: "Logs", link: "/admin/logs"},
        %{label: "Backups", link: "/admin/backups"}
      ]
    }
  ]}
/>
```

### Dynamic Menu from Database

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
