# 🤖 MCP Server for AI Tools

> **Model Context Protocol (MCP)** integration for Mishka Chelekom - Connect your favorite AI tools directly to the component library.

Mishka Chelekom includes a built-in MCP server that enables AI assistants like **Claude Code**, **Cursor**, and **Claude Desktop** to browse components, generate code, and access documentation seamlessly.

---

## 🚀 Quick Start

### Option 1: Standalone Server

Start the MCP server independently:

```bash
mix mishka.mcp.server
```

> 📍 Server runs at `http://localhost:4003/mcp`

**Options:**

| Option | Alias | Description | Default |
|:-------|:------|:------------|:--------|
| `--port` | `-p` | HTTP port to listen on | `4003` |

**Example:**

```bash
mix mishka.mcp.server --port 5000
```

---

### Option 2: Integrate with Phoenix

Add the MCP endpoint directly to your Phoenix router:

```bash
mix mishka.mcp.setup
```

> 📍 Adds endpoint at `/mcp` on your **Phoenix port** (default `http://localhost:4000/mcp`)

**Options:**

| Option | Alias | Description | Default |
|:-------|:------|:------------|:--------|
| `--path` | `-p` | Custom MCP endpoint path | `/mcp` |
| `--dev-only` | | Only enable in development | `true` |
| `--yes` | | Skip confirmation prompts | `false` |

**Examples:**

```bash
# Custom path
mix mishka.mcp.setup --path /api/mcp

# Enable in all environments
mix mishka.mcp.setup --dev-only=false

# Skip prompts
mix mishka.mcp.setup --yes
```

---

## 🔌 Connect Your AI Tools

> **Important:** Use the correct URL based on your setup:
> - **Standalone server:** `http://localhost:4003/mcp`
> - **Phoenix integration:** `http://localhost:4000/mcp` (your Phoenix port)

### Claude Code

```bash
# For standalone server
claude mcp add --transport http mishka-chelekom http://localhost:4003/mcp

# For Phoenix integration
claude mcp add --transport http mishka-chelekom http://localhost:4000/mcp
```

### Cursor / VS Code

Create `.mcp.json` in your project root:

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

> For Phoenix integration, change port to `4000` (or your Phoenix port).

### Cursor / VS Code (via MCP Proxy)

If your editor doesn't support HTTP transport directly, use [mcp_proxy_rust](https://github.com/tidewave-ai/mcp_proxy_rust) to bridge stdio and HTTP:

```json
{
  "mcpServers": {
    "mishka-chelekom": {
      "command": "mcp-proxy",
      "args": ["--transport", "http", "http://localhost:4003/mcp"]
    }
  }
}
```

> 💡 Install the proxy with: `cargo install mcp-proxy` or download from [releases](https://github.com/tidewave-ai/mcp_proxy_rust/releases)

### Claude Desktop

Add to your Claude Desktop configuration:

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

> For Phoenix integration, change port to `4000` (or your Phoenix port).

---

## 🛠️ Available Tools (11)

> Tools are actions the AI can perform on your behalf.

| Tool | Description |
|:-----|:------------|
| `generate_component` | Generate mix command for a single component |
| `generate_components` | Generate mix command for multiple components |
| `get_component_info` | Get component configuration options (variants, colors, sizes) |
| `get_example` | Get HEEx code examples with usage patterns |
| `get_js_hook_info` | Get JavaScript hook documentation |
| `get_mix_task_info` | Get mix task documentation |
| `search_components` | Search components by name or functionality |
| `uninstall_component` | Generate uninstall command |
| `update_config` | Update project configuration settings |
| `validate_config` | Validate configuration file for errors |
| `get_docs` | Fetch documentation from mishka.tools |

---

## 📚 Available Resources (9)

> Resources are read-only data the AI can access.

| Resource | Description |
|:---------|:------------|
| `list_components` | List all available components with categories |
| `list_colors` | List color variants with CSS variables |
| `list_variants` | List style variants (default, outline, shadow, etc.) |
| `list_sizes` | List size options (small, medium, large, etc.) |
| `list_spaces` | List spacing options |
| `list_scripts` | List JavaScript hooks (Carousel, Clipboard, etc.) |
| `list_dependencies` | List component dependencies |
| `list_css_variables` | List all CSS custom properties |
| `get_config` | Get current project configuration |

---

## 💡 Example Usage

Once connected, you can ask your AI assistant things like:

- *"Show me all available button variants"*
- *"Generate a modal component with primary color"*
- *"What JavaScript hooks does the carousel need?"*
- *"Search for form-related components"*
- *"Show me an example of the alert component"*

---

## ⚠️ Note for AI Tools

AI assistants may initially try incorrect resource URIs before discovering the correct ones. This is normal behavior - the AI will automatically recover by listing available resources and using the correct URIs.

---

## 📖 Learn More

- [Mishka Chelekom Documentation](https://mishka.tools/chelekom/docs)
- [CLI Documentation](https://mishka.tools/chelekom/docs/cli)
- [GitHub Repository](https://github.com/mishka-group/mishka_chelekom)
