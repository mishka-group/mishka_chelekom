# Progress Component

Progress bars including linear, semi-circle, and ring styles.

**Documentation**: https://mishka.tools/chelekom/docs/progress

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component progress
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | `floating.js` |

## Component Types

| Component | Description |
|-----------|-------------|
| `progress/1` | Linear progress bar |
| `progress_section/1` | Multi-section progress |
| `semi_circle_progress/1` | Semi-circle gauge |
| `ring_progress/1` | Circular ring |

## `progress/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `:string` | `"base"` | Style variant — `base`, `default`, `gradient` |
| `color` | `:string` | `"base"` | Color theme — `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"medium"` | Bar thickness — `extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large` |
| `rounded` | `:string` | `"full"` | Border radius — `extra_small`, `small`, `medium`, `large`, `extra_large`, `full` |
| `value` | `:integer` | `0` | Progress value (0-100) |
| `vertical` | `:boolean` | `false` | Vertical orientation |
| `label` | `:string` | `nil` | Label text |

## Slots

- `inner_block` — content inside the progress bar.

## Usage Examples

```heex
<.progress value={75} />
<.progress value={75} label="75% Complete" />

<%!-- Colors --%>
<.progress value={25} color="primary" />
<.progress value={50} color="success" />
<.progress value={75} color="warning" />
<.progress value={90} color="danger" />

<%!-- Sizes --%>
<.progress value={60} size="small" />
<.progress value={60} size="medium" />
<.progress value={60} size="large" />

<%!-- Gradient variant --%>
<.progress value={80} variant="gradient" color="primary" />

<%!-- With content (inner_block) --%>
<.progress value={65} size="large" color="primary">
  <span class="text-white text-sm">65%</span>
</.progress>

<%!-- Vertical --%>
<.progress value={70} vertical={true} class="h-32" />

<%!-- Semi-circle and ring --%>
<.semi_circle_progress value={75} color="primary" />
<.ring_progress value={80} color="success" />
```

## Common Patterns

### File Upload Progress

```heex
<div class="space-y-2">
  <div class="flex justify-between text-sm">
    <span>{@file.name}</span>
    <span>{@upload_progress}%</span>
  </div>
  <.progress value={@upload_progress} color="primary" />
</div>
```

### Multi-Step Progress

```heex
<.progress value={(@current_step / @total_steps) * 100} color="primary" size="small">
  Step {@current_step} of {@total_steps}
</.progress>
```

### Skill Bar

```heex
<div :for={skill <- @skills} class="mb-4">
  <div class="flex justify-between mb-1">
    <span class="font-medium">{skill.name}</span>
    <span>{skill.level}%</span>
  </div>
  <.progress value={skill.level} color="primary" size="small" />
</div>
```

### Dashboard Stats

```heex
<div class="grid grid-cols-2 gap-4">
  <div class="text-center">
    <.ring_progress value={@completion_rate} color="success" />
    <p class="mt-2">Completion Rate</p>
  </div>
  <div class="text-center">
    <.semi_circle_progress value={@performance} color="primary" />
    <p class="mt-2">Performance</p>
  </div>
</div>
```
