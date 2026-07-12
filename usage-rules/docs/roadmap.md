# Chelekom Phoenix UIKit - Roadmap

## Current Version: v0.0.9

### Version 0.0.9

Key updates include:

- Added AI-native tooling: an entry-level MCP server exposing components, docs and CLIs to AI agents, with an stdio transport (`mix mishka.mcp.setup --stdio`)
- Introduced entry-level headless (unstyled) components ported from Base UI — full WAI-ARIA wiring and behavior hooks, coexisting with the styled set
- Added `MishkaChelekom.Kit` — one Spark DSL to reuse and restyle existing components (`customize`/`from`), vendorable to production via `mix mishka.ui.gen.kit`
- Added comprehensive LLM-ready usage rules for every component and JavaScript hook
- Expanded the CLI and catalog: component/module name prefixes and `--no-save`, a full `mix mishka.ui.uninstall` (with `--headless`), new dock/shape/stat components, and Combobox (creatable + server push), vertical Tabs and rating upgrades

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/9)

### Version 0.0.8

Key updates include:

- Migrated from Tailwind CSS 3 to Tailwind CSS 4 for improved performance
- Introduced a CLI tool for custom CSS configuration
- Added comprehensive test suite for the CLI
- Fixed compatibility issues with Phoenix Framework and LiveView

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/8)

### Version 0.0.7

- Resolved reported issues to enhance stability
- Implemented Flash group restrictions specifically tailored for Phoenix version 1.8

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/7)

### Version 0.0.6

- Preparing for custom design systems support
- Enhancing components for Phoenix 1.8
- Optimizing components for custom requirements

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/6)

### Version 0.0.5

- Enhanced dynamic behavior of core components
- Improved Tailwind version compatibility
- Added basic accessibility support
- Addressed GitHub issue requirements

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/5)

### Version 0.0.4

- Added scroll area and combobox components
- Introduced radio card and checkbox card components
- Added global component installation support
- Bug fixes and refactoring

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/4)

### Version 0.0.3

- Added new stateless base components
- Implemented demo pages with copy-and-use functionality
- Fixed developer-reported issues

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/3)

### Version 0.0.2

- Implemented dark mode for all components
- Enhanced CLI performance
- Added initial JavaScript support (Beta)
- Updated templates for Phoenix LiveView 1.0.0

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/2)

### Version 0.0.1

- Launched approximately 80 components across 43 collections
- Complete documentation with code copy functionality
- Light mode only support
- All components are stateless

**Milestones**: [View on GitHub](https://github.com/mishka-group/mishka_chelekom/milestone/1)
