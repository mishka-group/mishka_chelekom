# Chelekom Phoenix UIKit - Getting Started Guide

## Overview

Chelekom is a zero-configuration component library for Phoenix development. Rather than installing complex dependencies, developers can add only needed components to their projects using mix tasks, keeping production builds lightweight.

The library's name has symbolic meaning: "Mishka" translates to "sparrow," while "Chelekom" refers to "neatly arranged cut logs."

## Installation Steps

### Step 1: Add to Dependencies

Update your `mix.exs` file to include:

```elixir
def deps do
  [
    {:mishka_chelekom, "~> 0.0.8", only: :dev}
  ]
end
```

### Step 2: Generate Components

Generate individual components with customization options:

```bash
mix mishka.ui.gen.component alert
mix mishka.ui.gen.component alert --color info --variant default
```

Or install all components at once:

```bash
mix mishka.ui.gen.components
```

### Step 3: Import Configuration (Optional)

Generate components with automatic importing:

```bash
mix mishka.ui.gen.components --import --helpers --global --yes
```

## Quick Install

For immediate setup without manual configuration:

```bash
mix mishka.ui.gen.components --import --helpers --global --yes
```

## Key Features

- **Zero-configuration approach** - no setup beyond library installation
- **Development-only dependency** - completely removed from production builds
- **Customizable components** - configure colors, variants, and functionality
- **Mix task automation** - streamlined component generation
- **Helper functions included** - optional utility imports available

## Compatibility Requirements

- Elixir 1.17+
- Erlang/OTP 27+
- Tailwind 4+
- Phoenix 1.8+
- Phoenix LiveView 1.1+

## Next Steps

- [CLI Documentation](https://mishka.tools/chelekom/docs/cli) - Learn all mix commands
- [Design System](https://mishka.tools/chelekom/docs/design-system) - Understand the design principles
- [Component List](https://mishka.tools/chelekom/docs) - Browse all available components
