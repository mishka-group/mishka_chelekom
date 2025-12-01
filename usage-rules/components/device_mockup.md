# Device Mockup Component

Device frame mockups for displaying images or content within iPhone, Android, Watch, Laptop, iPad, and iMac frames.

**Documentation**: https://mishka.tools/chelekom/docs/device-mockup

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component device_mockup

# Generate with specific options
mix mishka.ui.gen.component device_mockup --color natural,primary --type iphone,laptop

# Generate with custom module name
mix mishka.ui.gen.component device_mockup --module MyAppWeb.Components.CustomDeviceMockup
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | `image` |
| **Optional** | None |
| **JavaScript** | None |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `type` | `:string` | `"iphone"` | Device type |
| `color` | `:string` | `"natural"` | Frame color theme |
| `image` | `:string` | `nil` | Screen image URL |
| `alt` | `:string` | `nil` | Image alt text |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `inner_block` Slot

Custom content to display inside the device screen.

## Available Options

### Device Types
`iphone`, `android`, `watch`, `laptop`, `ipad`, `imac`

### Colors
`base`, `natural`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `misc`, `dawn`, `silver`

## Usage Examples

### iPhone Mockup

```heex
<.device_mockup image="/images/app-screenshot.png" />
```

### Android Mockup

```heex
<.device_mockup type="android" image="/images/android-screenshot.png" />
```

### Watch Mockup

```heex
<.device_mockup type="watch" image="/images/watch-screen.png" />
```

### Laptop Mockup

```heex
<.device_mockup type="laptop" image="/images/website-screenshot.png" />
```

### iPad Mockup

```heex
<.device_mockup type="ipad" image="/images/tablet-screenshot.png" />
```

### iMac Mockup

```heex
<.device_mockup type="imac" image="/images/desktop-screenshot.png" />
```

### With Custom Content

```heex
<.device_mockup type="iphone">
  <div class="flex items-center justify-center h-full bg-gradient-to-b from-blue-500 to-purple-600">
    <p class="text-white text-xl">App Preview</p>
  </div>
</.device_mockup>
```

### Different Colors

```heex
<.device_mockup color="natural" image="/images/screen.png" />
<.device_mockup color="primary" image="/images/screen.png" />
<.device_mockup color="silver" image="/images/screen.png" />
```

### iPad with Content

```heex
<.device_mockup type="ipad" image="/images/tablet-mockup.png">
  <div class="text-center p-4">
    <p>Additional overlay content</p>
  </div>
</.device_mockup>
```

## Common Patterns

### App Showcase

```heex
<div class="flex justify-center gap-8">
  <.device_mockup type="iphone" image="/images/ios-app.png" />
  <.device_mockup type="android" image="/images/android-app.png" />
</div>
```

### Responsive Preview

```heex
<div class="flex flex-wrap justify-center gap-8 items-end">
  <.device_mockup type="iphone" image="/images/mobile.png" />
  <.device_mockup type="ipad" image="/images/tablet.png" />
  <.device_mockup type="laptop" image="/images/desktop.png" />
</div>
```

### Feature Demonstration

```heex
<div class="grid grid-cols-1 md:grid-cols-2 gap-8">
  <div>
    <h3 class="text-xl font-bold mb-4">Mobile Experience</h3>
    <.device_mockup type="iphone" image="/images/feature-mobile.png" />
  </div>
  <div>
    <h3 class="text-xl font-bold mb-4">Desktop Experience</h3>
    <.device_mockup type="laptop" image="/images/feature-desktop.png" />
  </div>
</div>
```

### Watch App Preview

```heex
<div class="flex items-center gap-4">
  <.device_mockup type="watch" image="/images/watch-home.png" />
  <.device_mockup type="watch" image="/images/watch-activity.png" />
  <.device_mockup type="watch" image="/images/watch-settings.png" />
</div>
```
