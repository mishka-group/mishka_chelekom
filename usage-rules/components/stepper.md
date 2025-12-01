# Stepper Component

Multi-step progress indicator with horizontal and vertical layouts.

**Documentation**: https://mishka.tools/chelekom/docs/stepper

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component stepper
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `icon` |
| **Optional** | None |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `stepper/1` | Stepper container |
| `stepper_section/1` | Individual step |

## Attributes

### `stepper/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `:string` | `"base"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `size` | `:string` | `"small"` | Step size |
| `margin` | `:string` | `"medium"` | Step margin |
| `vertical` | `:boolean` | `false` | Vertical layout |

### `stepper_section/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `step` | `:string` | `nil` | Step state (`current`, `loading`, `completed`, `canceled`) |
| `title` | `:string` | `nil` | Step title |
| `description` | `:string` | `nil` | Step description |
| `icon` | `:string` | `nil` | Custom icon |

## Available Options

### Variants
`base`, `default`, `gradient`

### Colors
`base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

## Usage Examples

### Basic Stepper

```heex
<.stepper>
  <.stepper_section step="completed" title="Step 1" description="Account created" />
  <.stepper_section step="current" title="Step 2" description="Verify email" />
  <.stepper_section title="Step 3" description="Complete profile" />
</.stepper>
```

### With Colors

```heex
<.stepper color="primary">
  <.stepper_section step="completed" title="Order Placed" />
  <.stepper_section step="current" title="Processing" />
  <.stepper_section title="Shipped" />
  <.stepper_section title="Delivered" />
</.stepper>
```

### Vertical Layout

```heex
<.stepper vertical color="info">
  <.stepper_section step="completed" title="Sign Up" description="Create your account" />
  <.stepper_section step="current" title="Verification" description="Verify your email" />
  <.stepper_section title="Setup" description="Configure your preferences" />
  <.stepper_section title="Done" description="Start using the app" />
</.stepper>
```

### Different Sizes

```heex
<.stepper size="small">
  <.stepper_section step="completed" title="Step 1" />
  <.stepper_section step="current" title="Step 2" />
  <.stepper_section title="Step 3" />
</.stepper>

<.stepper size="large">
  <.stepper_section step="completed" title="Step 1" />
  <.stepper_section step="current" title="Step 2" />
  <.stepper_section title="Step 3" />
</.stepper>
```

### Loading State

```heex
<.stepper color="primary">
  <.stepper_section step="completed" title="Upload" />
  <.stepper_section step="loading" title="Processing" />
  <.stepper_section title="Complete" />
</.stepper>
```

### Canceled State

```heex
<.stepper>
  <.stepper_section step="completed" title="Started" />
  <.stepper_section step="canceled" title="Failed" />
  <.stepper_section title="Complete" />
</.stepper>
```

### With Custom Icons

```heex
<.stepper color="success">
  <.stepper_section step="completed" icon="hero-user" title="Account" />
  <.stepper_section step="current" icon="hero-envelope" title="Email" />
  <.stepper_section icon="hero-check" title="Done" />
</.stepper>
```

## Common Patterns

### Checkout Process

```heex
<.stepper color="primary">
  <.stepper_section
    step={if @step > 1, do: "completed", else: if(@step == 1, do: "current")}
    title="Cart"
    description="Review items"
  />
  <.stepper_section
    step={if @step > 2, do: "completed", else: if(@step == 2, do: "current")}
    title="Shipping"
    description="Enter address"
  />
  <.stepper_section
    step={if @step > 3, do: "completed", else: if(@step == 3, do: "current")}
    title="Payment"
    description="Add payment"
  />
  <.stepper_section
    step={if @step == 4, do: "current"}
    title="Confirm"
    description="Place order"
  />
</.stepper>
```

### Onboarding Flow

```heex
<.stepper vertical size="large" color="info">
  <.stepper_section
    step="completed"
    icon="hero-user-circle"
    title="Create Account"
    description="Sign up with email or social login"
  />
  <.stepper_section
    step="current"
    icon="hero-identification"
    title="Complete Profile"
    description="Add your personal information"
  />
  <.stepper_section
    icon="hero-cog-6-tooth"
    title="Preferences"
    description="Set your notification preferences"
  />
  <.stepper_section
    icon="hero-rocket-launch"
    title="Get Started"
    description="Explore the platform"
  />
</.stepper>
```
