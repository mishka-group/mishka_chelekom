# Chelekom CLI Documentation

## Overview

The Chelekom library is powered by the Igniter project, providing a zero-configuration experience with helper tools for Elixir mix tasks. The system enables developers to create components quickly with minimal configuration.

## Component Generation

### Single Component

```bash
mix mishka.ui.gen.component alert
mix mishka.ui.gen.component button --size large -c primary
```

### Multiple Components

```bash
mix mishka.ui.gen.components
mix mishka.ui.gen.components alert,divider,footer
mix mishka.ui.gen.components --import --yes
mix mishka.ui.gen.components --import --helpers --global --yes
```

The `--import` flag creates a file importing all components for project-wide use.

## Component Customization Options

| Option | Alias | Purpose |
|--------|-------|---------|
| `--variant` | `-v` | Specifies component variant |
| `--color` | `-c` | Specifies component color |
| `--size` | `-s` | Specifies component size |
| `--padding` | `-p` | Specifies component padding |
| `--space` | `-sp` | Specifies component space |
| `--type` | `-t` | Specifies component type |
| `--rounded` | `-r` | Specifies component rounded style |
| `--no-sub-config` | - | Creates dependent components with defaults |
| `--module` | `-m` | Specifies custom module name |
| `--sub` | - | Marks as a sub task |
| `--no-deps` | - | Creates without sub tasks |
| `--global` | - | Makes components accessible project-wide |
| `--yes` | - | Executes without prompts |
| `--exclude` | - | Comma-separated exclusion list |

## Asset Dependency Installation

The `mix mishka.assets.install` task manages npm, yarn, and bun dependencies:

```bash
mix mishka.assets.install npm install tailwindcss
mix mishka.assets.install yarn remove some-package
```

The system automatically normalizes commands across package managers and installs Bun if no manager exists.

## Repository Component Integration

The `mix mishka.ui.add` task downloads components from external repositories:

```bash
mix mishka.ui.add https://github.com/user/repo/component.json
```

**Options:**
- `--no-github` - Use URL without GitHub replacement
- `--headers` - Specify custom request headers

**Security Note:** Always verify external component sources before integration.

## Component Export to JSON

The `mix mishka.ui.export` task generates shareable JSON files:

```bash
mix mishka.ui.export --name my-components.json --base64
```

**Options:**
- `--base64` / `-b` - Encode content as Base64
- `--name` / `-n` - Define output filename (default: template.json)
- `--org` / `-o` - Organize file structure
- `--template` / `-t` - Create default template

**Requirements:** Components need both `.eex` and `.exs` files; names must start with `component_`, `preset_`, or `template_`.

## Component Uninstall

The `mix mishka.ui.uninstall` task removes components from your project:

```bash
mix mishka.ui.uninstall accordion
mix mishka.ui.uninstall accordion,button,alert
mix mishka.ui.uninstall --all
mix mishka.ui.uninstall accordion --dry-run
mix mishka.ui.uninstall accordion --force
```

**Options:**
- `--all` - Uninstall all Mishka components
- `--dry-run` - Preview what will be removed
- `--force` - Force removal even if other components depend on it
- `--keep-js` - Keep JavaScript files even if unused
- `--yes` - Skip confirmation prompts

## CSS Configuration Management

The `mix mishka.ui.css.config` task manages styling configuration:

```bash
mix mishka.ui.css.config --init
mix mishka.ui.css.config --regenerate
mix mishka.ui.css.config --validate
mix mishka.ui.css.config --show
```

**Options:**
- `--init` - Create sample configuration
- `--force` - Overwrite existing setup
- `--regenerate` - Rebuild CSS with custom settings
- `--validate` - Check current configuration
- `--show` - Display active settings

Configuration stores settings in Elixir format within the project's `priv` directory, enabling brand-specific color customization without modifying component code directly.

## Quick Reference

| Task | Description |
|------|-------------|
| `mix mishka.ui.gen.component NAME` | Generate a single component |
| `mix mishka.ui.gen.components` | Generate all/multiple components |
| `mix mishka.ui.add URL` | Add from external repository |
| `mix mishka.ui.uninstall NAME` | Remove component(s) |
| `mix mishka.ui.export` | Export components to JSON |
| `mix mishka.ui.css.config` | Manage CSS configuration |
| `mix mishka.assets.install` | Manage npm/yarn/bun dependencies |
