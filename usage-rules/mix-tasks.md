# Rules for Mishka Chelekom Mix Tasks

Mishka Chelekom provides several Mix tasks for generating, configuring, and managing UI components in Phoenix and Phoenix LiveView projects. Always read this guide before using any Mishka mix task.

**Full CLI Documentation**: https://mishka.tools/chelekom/docs/cli

> **For LLM Agents**: If you need more details about CLI options or task behavior not covered here, fetch the full documentation from the URL above.

## Prerequisites

Before using any Mishka Chelekom mix task:

- Install Mishka Chelekom in your `mix.exs` (dev only):
  ```elixir
  {:mishka_chelekom, "~> 0.0.9", only: :dev}
  ```
- Ensure Phoenix 1.8.0 or higher is installed
- Ensure Tailwind CSS 4.0 or higher is configured in `config.exs`
- Run tasks from your Phoenix project root directory (not umbrella root)
- Mishka Chelekom does NOT support umbrella projects directly - navigate to the specific Phoenix app first

**Installation Guide**: https://mishka.tools/chelekom/docs

## mix mishka.ui.gen.component

Generates a single component with customizable options.

### Basic Usage

```bash
# Generate with all default options
mix mishka.ui.gen.component button

# Generate with specific variants
mix mishka.ui.gen.component button --color primary,danger --variant default,outline

# Windows users must use quotes for multiple values
mix mishka.ui.gen.component button --color "primary,danger"
```

### Available Options

| Option | Alias | Description |
|--------|-------|-------------|
| `--variant` | `-v` | Component variant (e.g., default, outline, shadow) |
| `--color` | `-c` | Component color (e.g., primary, danger, success) |
| `--size` | `-s` | Component size (e.g., small, medium, large) |
| `--padding` | `-p` | Component padding |
| `--space` | `-sp` | Component spacing |
| `--type` | `-t` | Component type |
| `--rounded` | `-r` | Border radius option |
| `--module` | `-m` | Custom module name |
| `--module-prefix` | - | Prefix for module names |
| `--component-prefix` | - | Prefix for function names |
| `--yes` | - | Skip all confirmation prompts |
| `--no-deps` | - | Skip generating dependent components |
| `--no-sub-config` | - | Use default settings for dependencies |
| `--no-save` | - | Don't save prefixes to config |

### Component Dependencies

Some components have **necessary** dependencies that must be generated:

```bash
# Button requires Icon component
mix mishka.ui.gen.component button
# Will prompt to also generate: icon
```

Some components have **optional** dependencies (suggested but not required):

```bash
# After generating, you'll see suggestions for optional components
```

### Best Practices

- Generate components with only the colors/variants you need to minimize CSS output
- Use `--yes` flag in CI/CD pipelines for non-interactive generation
- Use `--module-prefix` when you want namespaced components (e.g., `MishkaButton`)
- Use `--component-prefix` when you want prefixed function names (e.g., `mishka_button/1`)

### Common Patterns

```bash
# Minimal button with only primary color
mix mishka.ui.gen.component button --color primary --variant default

# Full-featured alert with all variants
mix mishka.ui.gen.component alert

# Custom module name
mix mishka.ui.gen.component modal --module MyAppWeb.Components.CustomModal

# With module prefix (creates MishkaButton module)
mix mishka.ui.gen.component button --module-prefix mishka_
```

## mix mishka.ui.gen.components

Generates multiple components at once.

### Basic Usage

```bash
# Generate ALL available components
mix mishka.ui.gen.components

# Generate specific components
mix mishka.ui.gen.components button,alert,modal

# Generate all with import file
mix mishka.ui.gen.components --import --yes

# Recommended: Generate with global imports
mix mishka.ui.gen.components --import --helpers --global --yes
```

### Available Options

| Option | Alias | Description |
|--------|-------|-------------|
| `--import` | `-i` | Generate an import macro file |
| `--helpers` | `-h` | Include helper functions in import file |
| `--global` | `-g` | Replace Phoenix CoreComponents with Mishka components |
| `--exclude` | `-e` | Comma-separated list of components to skip |
| `--component-prefix` | - | Prefix for all function names |
| `--module-prefix` | - | Prefix for all module names |
| `--yes` | - | Skip all prompts |
| `--no-save` | - | Don't save prefixes to config |

### Import File Generation

When using `--import`, creates `lib/your_app_web/components/mishka_components.ex`:

```elixir
defmodule YourAppWeb.Components.MishkaComponents do
  defmacro __using__(_) do
    quote do
      import YourAppWeb.Components.Button, only: [button: 1, button_group: 1]
      import YourAppWeb.Components.Alert, only: [alert: 1, flash: 1, flash_group: 1]
      # ... all components
    end
  end
end
```

### Global Mode

Using `--global` replaces `import YourAppWeb.CoreComponents` with `use YourAppWeb.Components.MishkaComponents` in your web module's `html_helpers/0` function.

### Best Practices

- Use `--import --helpers --global --yes` for new projects
- Use `--exclude` to skip components you don't need
- Components are generated with default arguments (all colors, variants, etc.)

### Common Patterns

```bash
# New project setup (recommended)
mix mishka.ui.gen.components --import --helpers --global --yes

# Generate only form-related components
mix mishka.ui.gen.components input_field,text_field,checkbox_field,radio_field,native_select

# Exclude heavy components
mix mishka.ui.gen.components --exclude carousel,gallery,sidebar --yes

# With custom prefixes
mix mishka.ui.gen.components --module-prefix ui_ --component-prefix ui_ --yes
```

## mix mishka.ui.uninstall

Removes installed Mishka Chelekom components from your project.

### Basic Usage

```bash
# Remove a single component
mix mishka.ui.uninstall accordion

# Remove multiple components
mix mishka.ui.uninstall accordion,button,alert

# Remove all installed components
mix mishka.ui.uninstall --all

# Preview what will be removed (no changes made)
mix mishka.ui.uninstall accordion --dry-run

# Skip confirmation prompts
mix mishka.ui.uninstall accordion --yes
```

### Available Options

| Option | Alias | Description |
|--------|-------|-------------|
| `--all` | `-a` | Remove all installed Mishka components |
| `--dry-run` | `-d` | Preview removal without making changes |
| `--yes` | `-y` | Skip confirmation prompts |
| `--force` | `-f` | Force removal even when other components depend on them |
| `--keep-js` | - | Keep JavaScript files even if unused |
| `--include-css` | - | Also remove CSS files (only with --all) |
| `--include-config` | - | Also remove config file (only with --all) |
| `--verbose` | `-V` | Show detailed output |

### Component Dependencies

Some components depend on other components (e.g., button uses icon). The uninstaller handles this:

```bash
# Interactive mode: asks if you want to also remove dependent components
mix mishka.ui.uninstall icon
# Shows: "The following components depend on 'icon': button, badge"
# Offers: cascade removal or cancel

# With --yes but no --force: blocks removal if dependencies exist
mix mishka.ui.uninstall icon --yes
# Error: Cannot remove components that other components depend on

# Force removal regardless of dependencies
mix mishka.ui.uninstall icon --yes --force
# Removes icon, warns that button and badge may have issues
```

### JavaScript Hook Management

The uninstaller intelligently handles shared JavaScript hooks:

```bash
# If accordion and collapse both use collapsible.js:
mix mishka.ui.uninstall accordion --yes
# Result: accordion.ex removed, collapsible.js KEPT (collapse still uses it)

mix mishka.ui.uninstall collapse --yes
# Result: collapse.ex removed, collapsible.js REMOVED (no component uses it)
```

Use `--keep-js` to preserve all JS files regardless:

```bash
mix mishka.ui.uninstall accordion --yes --keep-js
```

### Module Prefix Support

If you used `module_prefix` when generating components, the uninstaller finds them automatically:

```bash
# Config has: module_prefix: "mishka_"
# File is: lib/app_web/components/mishka_accordion.ex

mix mishka.ui.uninstall accordion --yes
# Correctly finds and removes mishka_accordion.ex
```

### Full Cleanup

Using `--all` completely removes all Mishka Chelekom files:

```bash
mix mishka.ui.uninstall --all --yes
```

This removes:
- All component files
- `assets/vendor/mishka_components.js`
- `assets/vendor/mishka_chelekom.css`
- `priv/mishka_chelekom/config.exs`
- Import from `mishka_components.ex`

### Common Patterns

```bash
# Preview full uninstall
mix mishka.ui.uninstall --all --dry-run

# Remove specific components, keep JS
mix mishka.ui.uninstall modal,drawer --yes --keep-js

# Complete removal
mix mishka.ui.uninstall --all --yes
```

---

## mix mishka.ui.add

Imports components from external sources (community components, custom repos).

### Basic Usage

```bash
# From official community repository
mix mishka.ui.add component_custom_button

# From GitHub URL
mix mishka.ui.add https://github.com/user/repo/blob/main/component.json

# From raw GitHub content
mix mishka.ui.add https://raw.githubusercontent.com/user/repo/main/component.json

# From GitHub Gist
mix mishka.ui.add https://gist.github.com/user/gist_id

# From local file
mix mishka.ui.add ./path/to/component.json
```

### Available Options

| Option | Description |
|--------|-------------|
| `--no-github` | Don't convert GitHub URLs to API format |
| `--headers` | Custom request headers (e.g., for private repos) |

### Security Warning

When downloading from external sources, you'll see a security prompt:

```
This is a security message, please pay attention to it!!!
You are directly requesting from an address that the Mishka team cannot validate.
```

Always verify the source before accepting external components.

### Community Repository Naming

- Components: `component_name` (e.g., `component_custom_card`)
- Presets: `preset_name` (e.g., `preset_dashboard`)
- Templates: `template_name` (e.g., `template_auth`)

## mix mishka.ui.export

Exports components to JSON format for sharing.

### Basic Usage

```bash
# Export components from a directory
mix mishka.ui.export ./my_components

# Export with Base64 encoding (for special characters)
mix mishka.ui.export ./my_components --base64

# Create a template JSON file
mix mishka.ui.export ./my_components --template

# Custom output name
mix mishka.ui.export ./my_components --name my_preset
```

### Available Options

| Option | Alias | Description |
|--------|-------|-------------|
| `--base64` | `-b` | Encode content as Base64 |
| `--name` | `-n` | Output filename (default: template.json) |
| `--org` | `-o` | Organization type (component/preset/template) |
| `--template` | `-t` | Create empty template JSON |

### File Naming Convention

Components must follow this naming pattern:

```
component_name.eex  # Template file
component_name.exs  # Configuration file

preset_name.eex
preset_name.exs

template_name.eex
template_name.exs
```

JavaScript files only need the `.js` extension.

## mix mishka.ui.css.config

Manages CSS configuration and customization.

### Basic Usage

```bash
# Initialize configuration file
mix mishka.ui.css.config --init

# Force overwrite existing config
mix mishka.ui.css.config --init --force

# Regenerate CSS with current config
mix mishka.ui.css.config --regenerate

# Validate configuration
mix mishka.ui.css.config --validate

# Show current configuration
mix mishka.ui.css.config --show
```

### Available Options

| Option | Alias | Description |
|--------|-------|-------------|
| `--init` | `-i` | Create sample config file |
| `--force` | `-f` | Force overwrite existing config |
| `--regenerate` | `-r` | Regenerate CSS with config |
| `--validate` | `-v` | Validate current config |
| `--show` | `-s` | Display current config |

### Configuration File

Creates `priv/mishka_chelekom/config.exs` with options:

```elixir
[
  # Exclude specific components
  exclude_components: [],

  # Limit generated options
  component_colors: [],      # e.g., ["primary", "danger"]
  component_variants: [],    # e.g., ["default", "outline"]
  component_sizes: [],       # e.g., ["small", "medium"]
  component_rounded: [],
  component_padding: [],
  component_space: [],

  # Prefix settings
  component_prefix: nil,     # e.g., "mishka_"
  module_prefix: nil,        # e.g., "Mishka"

  # CSS customization
  css_merge_strategy: :merge,  # :merge or :replace
  custom_css_path: nil,
  css_overrides: %{
    # "--primary": "#custom-color"
  }
]
```

## mix mishka.assets.install

Runs package manager install or remove commands directly in the assets directory.

### Basic Usage

```bash
# Run npm install in assets directory
mix mishka.assets.install npm

# Run yarn install
mix mishka.assets.install yarn

# Run bun install
mix mishka.assets.install bun

# Run mix bun install (using bun hex package)
mix mishka.assets.install bun mix

# Remove a package with npm
mix mishka.assets.install npm pkg remove lodash

# Remove a package with yarn
mix mishka.assets.install yarn pkg remove lodash
```

### Command Format

```bash
mix mishka.assets.install <package_manager> [pkg_type] [command] [packages...]
```

| Argument | Description |
|----------|-------------|
| `package_manager` | npm, yarn, or bun |
| `pkg_type` | `pkg` (system) or `mix` (hex package) |
| `command` | `install` or `remove` |
| `packages` | Package names (for remove command) |

### Package Manager Command Mapping

| Manager | Install Command | Remove Command |
|---------|-----------------|----------------|
| npm | `install` | `uninstall` |
| yarn | `add` | `remove` |
| bun | `install` | `remove` |

### When to Use

- Use `mishka.assets.install` for direct package manager operations
- Use `mishka.assets.deps` (below) for managing `package.json` with automatic package manager detection

---

## mix mishka.assets.deps

Manages JavaScript dependencies in `assets/package.json`.

### Basic Usage

```bash
# Add dependencies (auto-detects npm/yarn/bun)
mix mishka.assets.deps lodash,axios

# Add with specific version
mix mishka.assets.deps lodash@4.17.21

# Add as dev dependency
mix mishka.assets.deps eslint --dev

# Remove dependencies
mix mishka.assets.deps lodash --remove

# Use specific package manager
mix mishka.assets.deps lodash --npm
mix mishka.assets.deps lodash --yarn
mix mishka.assets.deps lodash --bun
mix mishka.assets.deps lodash --mix-bun
```

### Available Options

| Option | Description |
|--------|-------------|
| `--npm` | Use npm |
| `--yarn` | Use yarn |
| `--bun` | Use bun |
| `--mix-bun` | Use bun via Mix (hex package) |
| `--dev` | Add to devDependencies |
| `--remove` | Remove dependencies |
| `--yes` | Skip prompts |

### Fallback Behavior

If no package manager is found, the task will offer to install `{:bun, "~> 1.0"}` as a Mix dependency.

---

## mix mishka.mcp.server

Starts the Mishka Chelekom MCP Server as a standalone service for AI tools integration.

### Basic Usage

```bash
# Start with default port (4003)
mix mishka.mcp.server

# Start with custom port
mix mishka.mcp.server --port 5000
```

### Available Options

| Option | Alias | Description |
|--------|-------|-------------|
| `--port` | `-p` | HTTP port to listen on (default: 4003) |

### Connecting AI Tools

After starting the server, connect your AI tools:

**Claude Code:**
```bash
claude mcp add --transport http mishka-chelekom http://localhost:4003/mcp
```

**Cursor/VS Code (.mcp.json):**
```json
{
  "mcpServers": {
    "mishka-chelekom": {
      "type": "http",
      "url": "http://localhost:4003/mcp"
    }
  }
}
```

### Available MCP Tools

- `generate_component` - Generate mix command for a single component
- `generate_components` - Generate mix command for multiple components
- `get_component_info` - Get component configuration options
- `get_example` - Get HEEx code examples with usage patterns
- `get_js_hook_info` - Get JavaScript hook documentation
- `get_mix_task_info` - Get mix task documentation
- `search_components` - Search components by name or functionality
- `uninstall_component` - Generate uninstall command
- `update_config` - Update project configuration settings
- `validate_config` - Validate configuration file for errors
- `get_docs` - Fetch documentation from mishka.tools

### Available MCP Resources

- `list_components` - List all available components with categories
- `list_colors` - List color variants with CSS variables
- `list_variants` - List style variants
- `list_sizes` - List size options
- `list_spaces` - List spacing options
- `list_scripts` - List JavaScript hooks
- `list_dependencies` - List component dependencies
- `list_css_variables` - List all CSS custom properties
- `get_config` - Get current project configuration

---

## mix mishka.mcp.setup

Integrates the MCP Server directly into your Phoenix router.

### Basic Usage

```bash
# Add MCP endpoint to router with defaults
mix mishka.mcp.setup

# Custom endpoint path
mix mishka.mcp.setup --path /api/mcp

# Enable in all environments (not just dev)
mix mishka.mcp.setup --dev-only=false

# Skip confirmation prompts
mix mishka.mcp.setup --yes
```

### Available Options

| Option | Alias | Description |
|--------|-------|-------------|
| `--path` | `-p` | Custom MCP endpoint path (default: "/mcp") |
| `--dev-only` | | Only enable in development (default: true) |
| `--yes` | | Skip confirmation prompts |

### What This Task Does

1. Adds the MCP route to your Phoenix router
2. Configures the route to use `Anubis.Server.Transport.StreamableHTTP.Plug`
3. Wraps it in a dev_routes condition (unless `--dev-only=false`)

### After Setup

The MCP endpoint runs on your **Phoenix port** (default 4000), not 4003:

```bash
claude mcp add --transport http mishka-chelekom http://localhost:4000/mcp
```

### Standalone vs Phoenix Integration

| Feature | `mix mishka.mcp.server` | `mix mishka.mcp.setup` |
|---------|-------------------------|------------------------|
| Port | Separate (4003) | Phoenix port (4000) |
| Usage | Any Elixir project | Phoenix projects |
| Control | Manual start/stop | Runs with Phoenix |

---

## Generated File Locations

| File Type | Location |
|-----------|----------|
| Components | `lib/your_app_web/components/` |
| Import macro | `lib/your_app_web/components/mishka_components.ex` |
| CSS vendor | `assets/vendor/mishka_chelekom.css` |
| JS vendor | `assets/vendor/mishka_components.js` |
| Theme CSS | Injected into `assets/css/app.css` |
| Config | `priv/mishka_chelekom/config.exs` |

## Troubleshooting

### "Phoenix is not installed"
Ensure `{:phoenix, "~> 1.8"}` is in your `mix.exs` dependencies.

### "Tailwind version not compatible"
Add to `config/config.exs`:
```elixir
config :tailwind, version: "4.0.0"
```

### "Component not found"
- Check component name spelling (use snake_case)
- Ensure you're in the correct directory
- Run `mix deps.get` to ensure mishka_chelekom is installed

### "Web module path not found"
- Ensure `lib/your_app_web/components/` directory exists
- Check your app naming follows Phoenix conventions

### Components not updating
Run with `--yes` flag to force regeneration:
```bash
mix mishka.ui.gen.component button --yes
```
