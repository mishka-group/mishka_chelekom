# Rules for Working with Mishka Chelekom

Mishka Chelekom is a UI component library for Phoenix and Phoenix LiveView. It generates fully customizable components directly into your project - no hidden dependencies, no runtime library code.

**Important**: Always read these rules and the relevant sub-rules before using Mishka Chelekom with an LLM agent.

## For LLM Agents: Fetching Additional Documentation

If you cannot find specific information in these rules (attributes, slots, examples, edge cases), **fetch the documentation from mishka.tools**:

- **Component docs**: `https://mishka.tools/chelekom/docs/{component-name}` (use hyphens, not underscores)
- **Form component docs**: `https://mishka.tools/chelekom/docs/forms/{component-name}`
- **CLI docs**: `https://mishka.tools/chelekom/docs/cli`
- **Main docs**: `https://mishka.tools/chelekom/docs`

**URL Pattern Notes**:
- Use hyphens instead of underscores: `text_field` → `text-field`
- Form components use `/forms/` prefix: `https://mishka.tools/chelekom/docs/forms/text-field`
- Non-form components: `https://mishka.tools/chelekom/docs/button`

For example:
```
Button: https://mishka.tools/chelekom/docs/button
Text Field: https://mishka.tools/chelekom/docs/forms/text-field
Device Mockup: https://mishka.tools/chelekom/docs/device-mockup
```

Always prefer the official documentation over guessing or hallucinating component attributes.

## Using with usage_rules Package

This library supports the [usage_rules](https://hexdocs.pm/usage_rules/) package for LLM agent integration.

### Setup

```elixir
# Add to mix.exs
{:usage_rules, "~> 0.2"}

# Sync rules to your project
mix usage_rules.sync
```

### Configuration

In `config/config.exs`:

```elixir
config :usage_rules,
  output_file: "CLAUDE.md",  # or "CURSOR.md", "AGENTS.md", etc.
  packages: [:mishka_chelekom]
```

This will automatically include Mishka Chelekom's usage rules in your agent's context.

## Compatibility

Mishka Chelekom is designed to work **alongside any other library**:

- **Standalone**: Use only the components you need - generate just one component or all 71
- **Mix with other UI libraries**: Mishka components coexist with Phoenix CoreComponents, Surface, or any other library
- **No conflicts**: Components are generated into your codebase, not imported from a runtime dependency
- **Selective generation**: Generate `button` only, or `button,alert,modal`, or everything

```bash
# Use just one component
mix mishka.ui.gen.component button

# Use a few components
mix mishka.ui.gen.components button,alert,modal

# Use all components
mix mishka.ui.gen.components
```

## Core Principles

- Components are generated into your project's source code, giving you full control
- This library is **development-only** - it has no presence in production
- All components use Tailwind CSS 4.0+ for styling
- Components are Phoenix function components compatible with LiveView

## Requirements

- **Phoenix**: 1.8.0 or higher
- **Tailwind CSS**: 4.0 or higher
- **Elixir**: Compatible with your Phoenix version

## Quick Start

```bash
# Add to mix.exs (dev only)
{:mishka_chelekom, "~> 0.0.9", only: :dev}

# Generate a single component
mix mishka.ui.gen.component button

# Generate all components with global imports (recommended for new projects)
mix mishka.ui.gen.components --import --helpers --global --yes
```

## Sub-Rules

This package includes detailed rules for specific topics:

- **[Mix Tasks](usage-rules/mix-tasks.md)**: Complete guide for all mix tasks
- **[Components](usage-rules/components/)**: Detailed rules for each component

For comprehensive documentation, visit: https://mishka.tools/chelekom/docs

## All Components (71 total)

### Complete List with Generation Commands

| Component | Generate Command | Documentation |
|-----------|------------------|---------------|
| `accordion` | `mix mishka.ui.gen.component accordion` | [Docs](https://mishka.tools/chelekom/docs/accordion) |
| `alert` | `mix mishka.ui.gen.component alert` | [Docs](https://mishka.tools/chelekom/docs/alert) |
| `avatar` | `mix mishka.ui.gen.component avatar` | [Docs](https://mishka.tools/chelekom/docs/avatar) |
| `badge` | `mix mishka.ui.gen.component badge` | [Docs](https://mishka.tools/chelekom/docs/badge) |
| `banner` | `mix mishka.ui.gen.component banner` | [Docs](https://mishka.tools/chelekom/docs/banner) |
| `blockquote` | `mix mishka.ui.gen.component blockquote` | [Docs](https://mishka.tools/chelekom/docs/blockquote) |
| `breadcrumb` | `mix mishka.ui.gen.component breadcrumb` | [Docs](https://mishka.tools/chelekom/docs/breadcrumb) |
| `button` | `mix mishka.ui.gen.component button` | [Docs](https://mishka.tools/chelekom/docs/button) |
| `card` | `mix mishka.ui.gen.component card` | [Docs](https://mishka.tools/chelekom/docs/card) |
| `carousel` | `mix mishka.ui.gen.component carousel` | [Docs](https://mishka.tools/chelekom/docs/carousel) |
| `chat` | `mix mishka.ui.gen.component chat` | [Docs](https://mishka.tools/chelekom/docs/chat) |
| `checkbox_card` | `mix mishka.ui.gen.component checkbox_card` | [Docs](https://mishka.tools/chelekom/docs/forms/checkbox-card) |
| `checkbox_field` | `mix mishka.ui.gen.component checkbox_field` | [Docs](https://mishka.tools/chelekom/docs/forms/checkbox-field) |
| `clipboard` | `mix mishka.ui.gen.component clipboard` | [Docs](https://mishka.tools/chelekom/docs/clipboard) |
| `collapse` | `mix mishka.ui.gen.component collapse` | [Docs](https://mishka.tools/chelekom/docs/collapse) |
| `color_field` | `mix mishka.ui.gen.component color_field` | [Docs](https://mishka.tools/chelekom/docs/forms/color-field) |
| `combobox` | `mix mishka.ui.gen.component combobox` | [Docs](https://mishka.tools/chelekom/docs/forms/combobox) |
| `date_time_field` | `mix mishka.ui.gen.component date_time_field` | [Docs](https://mishka.tools/chelekom/docs/forms/date-time-field) |
| `device_mockup` | `mix mishka.ui.gen.component device_mockup` | [Docs](https://mishka.tools/chelekom/docs/device-mockup) |
| `divider` | `mix mishka.ui.gen.component divider` | [Docs](https://mishka.tools/chelekom/docs/divider) |
| `drawer` | `mix mishka.ui.gen.component drawer` | [Docs](https://mishka.tools/chelekom/docs/drawer) |
| `dropdown` | `mix mishka.ui.gen.component dropdown` | [Docs](https://mishka.tools/chelekom/docs/dropdown) |
| `email_field` | `mix mishka.ui.gen.component email_field` | [Docs](https://mishka.tools/chelekom/docs/forms/email-field) |
| `fieldset` | `mix mishka.ui.gen.component fieldset` | [Docs](https://mishka.tools/chelekom/docs/forms/fieldset) |
| `file_field` | `mix mishka.ui.gen.component file_field` | [Docs](https://mishka.tools/chelekom/docs/forms/file-field) |
| `footer` | `mix mishka.ui.gen.component footer` | [Docs](https://mishka.tools/chelekom/docs/footer) |
| `form_wrapper` | `mix mishka.ui.gen.component form_wrapper` | [Docs](https://mishka.tools/chelekom/docs/forms) |
| `gallery` | `mix mishka.ui.gen.component gallery` | [Docs](https://mishka.tools/chelekom/docs/gallery) |
| `image` | `mix mishka.ui.gen.component image` | [Docs](https://mishka.tools/chelekom/docs/image) |
| `indicator` | `mix mishka.ui.gen.component indicator` | [Docs](https://mishka.tools/chelekom/docs/indicator) |
| `input_field` | `mix mishka.ui.gen.component input_field` | [Docs](https://mishka.tools/chelekom/docs/forms/input-field) |
| `jumbotron` | `mix mishka.ui.gen.component jumbotron` | [Docs](https://mishka.tools/chelekom/docs/jumbotron) |
| `keyboard` | `mix mishka.ui.gen.component keyboard` | [Docs](https://mishka.tools/chelekom/docs/keyboard) |
| `layout` | `mix mishka.ui.gen.component layout` | [Docs](https://mishka.tools/chelekom/docs/layout) |
| `list` | `mix mishka.ui.gen.component list` | [Docs](https://mishka.tools/chelekom/docs/list) |
| `mega_menu` | `mix mishka.ui.gen.component mega_menu` | [Docs](https://mishka.tools/chelekom/docs/mega-menu) |
| `menu` | `mix mishka.ui.gen.component menu` | [Docs](https://mishka.tools/chelekom/docs/menu) |
| `modal` | `mix mishka.ui.gen.component modal` | [Docs](https://mishka.tools/chelekom/docs/modal) |
| `native_select` | `mix mishka.ui.gen.component native_select` | [Docs](https://mishka.tools/chelekom/docs/forms/native-select) |
| `navbar` | `mix mishka.ui.gen.component navbar` | [Docs](https://mishka.tools/chelekom/docs/navbar) |
| `number_field` | `mix mishka.ui.gen.component number_field` | [Docs](https://mishka.tools/chelekom/docs/forms/number-field) |
| `overlay` | `mix mishka.ui.gen.component overlay` | [Docs](https://mishka.tools/chelekom/docs/overlay) |
| `pagination` | `mix mishka.ui.gen.component pagination` | [Docs](https://mishka.tools/chelekom/docs/pagination) |
| `password_field` | `mix mishka.ui.gen.component password_field` | [Docs](https://mishka.tools/chelekom/docs/forms/password-field) |
| `popover` | `mix mishka.ui.gen.component popover` | [Docs](https://mishka.tools/chelekom/docs/popover) |
| `progress` | `mix mishka.ui.gen.component progress` | [Docs](https://mishka.tools/chelekom/docs/progress) |
| `radio_card` | `mix mishka.ui.gen.component radio_card` | [Docs](https://mishka.tools/chelekom/docs/forms/radio-card) |
| `radio_field` | `mix mishka.ui.gen.component radio_field` | [Docs](https://mishka.tools/chelekom/docs/forms/radio-field) |
| `range_field` | `mix mishka.ui.gen.component range_field` | [Docs](https://mishka.tools/chelekom/docs/forms/range-field) |
| `rating` | `mix mishka.ui.gen.component rating` | [Docs](https://mishka.tools/chelekom/docs/rating) |
| `scroll_area` | `mix mishka.ui.gen.component scroll_area` | [Docs](https://mishka.tools/chelekom/docs/scroll-area) |
| `search_field` | `mix mishka.ui.gen.component search_field` | [Docs](https://mishka.tools/chelekom/docs/forms/search-field) |
| `sidebar` | `mix mishka.ui.gen.component sidebar` | [Docs](https://mishka.tools/chelekom/docs/sidebar) |
| `skeleton` | `mix mishka.ui.gen.component skeleton` | [Docs](https://mishka.tools/chelekom/docs/skeleton) |
| `speed_dial` | `mix mishka.ui.gen.component speed_dial` | [Docs](https://mishka.tools/chelekom/docs/speed-dial) |
| `spinner` | `mix mishka.ui.gen.component spinner` | [Docs](https://mishka.tools/chelekom/docs/spinner) |
| `stepper` | `mix mishka.ui.gen.component stepper` | [Docs](https://mishka.tools/chelekom/docs/stepper) |
| `table` | `mix mishka.ui.gen.component table` | [Docs](https://mishka.tools/chelekom/docs/table) |
| `table_content` | `mix mishka.ui.gen.component table_content` | [Docs](https://mishka.tools/chelekom/docs/table-content) |
| `tabs` | `mix mishka.ui.gen.component tabs` | [Docs](https://mishka.tools/chelekom/docs/tabs) |
| `tel_field` | `mix mishka.ui.gen.component tel_field` | [Docs](https://mishka.tools/chelekom/docs/forms/tel-field) |
| `text_field` | `mix mishka.ui.gen.component text_field` | [Docs](https://mishka.tools/chelekom/docs/forms/text-field) |
| `textarea_field` | `mix mishka.ui.gen.component textarea_field` | [Docs](https://mishka.tools/chelekom/docs/forms/textarea-field) |
| `timeline` | `mix mishka.ui.gen.component timeline` | [Docs](https://mishka.tools/chelekom/docs/timeline) |
| `toast` | `mix mishka.ui.gen.component toast` | [Docs](https://mishka.tools/chelekom/docs/toast) |
| `toggle_field` | `mix mishka.ui.gen.component toggle_field` | [Docs](https://mishka.tools/chelekom/docs/forms/toggle) |
| `tooltip` | `mix mishka.ui.gen.component tooltip` | [Docs](https://mishka.tools/chelekom/docs/tooltip) |
| `typography` | `mix mishka.ui.gen.component typography` | [Docs](https://mishka.tools/chelekom/docs/typography) |
| `url_field` | `mix mishka.ui.gen.component url_field` | [Docs](https://mishka.tools/chelekom/docs/forms/url-field) |
| `video` | `mix mishka.ui.gen.component video` | [Docs](https://mishka.tools/chelekom/docs/video) |

### Components by Category

#### Form Components (22)
`checkbox_card`, `checkbox_field`, `color_field`, `combobox`, `date_time_field`, `email_field`, `fieldset`, `file_field`, `form_wrapper`, `input_field`, `native_select`, `number_field`, `password_field`, `radio_card`, `radio_field`, `range_field`, `search_field`, `tel_field`, `text_field`, `textarea_field`, `toggle_field`, `url_field`

#### Navigation Components (10)
`breadcrumb`, `dropdown`, `mega_menu`, `menu`, `navbar`, `pagination`, `sidebar`, `speed_dial`, `stepper`, `tabs`

#### Feedback Components (10)
`alert`, `badge`, `banner`, `indicator`, `progress`, `rating`, `skeleton`, `spinner`, `toast`, `tooltip`

#### Layout Components (14)
`accordion`, `card`, `collapse`, `divider`, `drawer`, `footer`, `jumbotron`, `layout`, `modal`, `overlay`, `popover`, `table`, `table_content`, `timeline`

#### Media Components (9)
`avatar`, `carousel`, `clipboard`, `device_mockup`, `gallery`, `icon`, `image`, `scroll_area`, `video`

#### Typography Components (4)
`blockquote`, `keyboard`, `list`, `typography`

#### Specialized Components (2)
`button`, `chat`

## JavaScript Files (9 total)

Components that require JavaScript hooks use these files in `priv/assets/js/`:

| File | Used By | Purpose |
|------|---------|---------|
| `carousel.js` | carousel | Slide navigation and autoplay |
| `clipboard.js` | clipboard | Copy to clipboard functionality |
| `collapsible.js` | accordion, collapse | Expand/collapse animations |
| `combobox.js` | combobox | Autocomplete and filtering |
| `floating.js` | dropdown, popover, tooltip | Positioning and floating UI |
| `galleryFilter.js` | gallery | Image filtering |
| `mishka_components.js` | All JS components | Main entry point for hooks |
| `scrollArea.js` | scroll_area | Custom scrollbar |
| `sidebar.js` | sidebar | Mobile sidebar toggle |

## Component Customization Options

When generating components, you can customize:

| Option | Values |
|--------|--------|
| `--variant` | base, default, outline, transparent, subtle, shadow, inverted, bordered, gradient |
| `--color` | natural, white, dark, primary, secondary, success, warning, danger, info, silver, misc, dawn |
| `--size` | extra_small, small, medium, large, extra_large, full |
| `--rounded` | extra_small, small, medium, large, extra_large, full, none |
| `--padding` | extra_small, small, medium, large, extra_large, none |
| `--space` | extra_small, small, medium, large, extra_large |

## Best Practices

### DO

- Generate only the components you need
- Use `--color` and `--variant` flags to limit generated CSS
- Use `--import --helpers --global` for new projects
- Configure `priv/mishka_chelekom/config.exs` for project-wide defaults
- Read component documentation before customizing

### DON'T

- Don't install mishka_chelekom in production (use `only: :dev`)
- Don't manually edit generated components if you plan to regenerate them
- Don't use umbrella project root - navigate to specific Phoenix app
- Don't mix custom module names inconsistently

## Configuration

Create `priv/mishka_chelekom/config.exs` to set project-wide defaults:

```elixir
[
  # Only generate these colors across all components
  component_colors: ["primary", "secondary", "danger"],

  # Only generate these variants
  component_variants: ["default", "outline"],

  # Exclude components you don't need
  exclude_components: ["device_mockup", "mega_menu"],

  # Prefix all function names
  component_prefix: "ui_",

  # CSS variable overrides
  css_overrides: %{
    "--primary": "oklch(0.7 0.15 200)"
  }
]
```

## Generated Files

| Purpose | Location |
|---------|----------|
| Components | `lib/your_app_web/components/*.ex` |
| Import macro | `lib/your_app_web/components/mishka_components.ex` |
| Vendor CSS | `assets/vendor/mishka_chelekom.css` |
| Vendor JS | `assets/vendor/mishka_components.js` |
| Config | `priv/mishka_chelekom/config.exs` |

## Using Components in Templates

After generation, use components in your HEEx templates:

```heex
<%# If using --global flag, components are available everywhere %>
<.button color="primary" variant="default">Click Me</.button>

<.alert color="success">
  <:icon><.icon name="hero-check-circle" /></:icon>
  Operation completed successfully!
</.alert>

<.card>
  <.card_header>
    <.card_title>Welcome</.card_title>
  </.card_header>
  <.card_content>
    Your content here
  </.card_content>
</.card>
```

## JavaScript Hooks

Some components require JavaScript hooks (carousel, clipboard, combobox, etc.). These are automatically:

1. Copied to `assets/vendor/`
2. Imported in `assets/vendor/mishka_components.js`
3. Added to LiveSocket hooks in `assets/js/app.js`

## Updating Components

To update a component with new options:

```bash
# Regenerate with additional colors
mix mishka.ui.gen.component button --color primary,danger,success --yes
```

The `--yes` flag overwrites existing files.

## Community Components

Share or import community components:

```bash
# Import from community
mix mishka.ui.add component_custom_button

# Export your components
mix mishka.ui.export ./my_components --name my_preset
```

## Troubleshooting

### Components not styled correctly
- Ensure Tailwind CSS 4.0+ is configured
- Check that `assets/vendor/mishka_chelekom.css` is imported in `app.css`

### JavaScript hooks not working
- Verify `assets/vendor/mishka_components.js` exists
- Check `assets/js/app.js` imports MishkaComponents
- Ensure LiveSocket includes `...MishkaComponents` in hooks

### Generation fails
- Run `mix deps.get` to ensure mishka_chelekom is installed
- Check Phoenix version is 1.8+
- Ensure `lib/your_app_web/components/` directory exists

## Support

If you have questions or encounter problems, open an issue:
https://github.com/mishka-group/mishka_chelekom/issues

## Custom Components

Need a component or JavaScript functionality that isn't available in Mishka Chelekom? Request custom development:
https://mishka.tools/chelekom/custom-service

## Links

- Documentation: https://mishka.tools/chelekom/docs
- CLI Documentation: https://mishka.tools/chelekom/docs/cli
- Design System: https://mishka.tools/chelekom/docs/design-system
- Security: https://mishka.tools/chelekom/docs/security
- Roadmap: https://mishka.tools/chelekom/docs/roadmap
- GitHub: https://github.com/mishka-group/mishka_chelekom
- Issues: https://github.com/mishka-group/mishka_chelekom/issues
- Community: https://github.com/mishka-group/mishka_chelekom_community
- usage_rules Package: https://hexdocs.pm/usage_rules/
