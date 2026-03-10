# Rating Component

Star-based rating display with interactive selection, half-star precision, form integration, and disabled state.

**Documentation**: https://mishka.tools/chelekom/docs/rating

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component rating
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | None |
| **JavaScript** | None (uses Phoenix LiveView JS module only) |

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier for managing state and interaction |
| `class` | `:string` | `nil` | Custom CSS class for additional styling |
| `color` | `:string` | `"warning"` | Star color theme |
| `size` | `:string` | `"small"` | Star size |
| `gap` | `:string` | `"small"` | Space between stars |
| `count` | `:integer` | `5` | Number of stars |
| `select` | `:any` | `0` | Selected rating value (integer or float) |
| `interactive` | `:boolean` | `false` | Allow user selection via click |
| `disabled` | `:boolean` | `false` | Disable all interaction (reduced opacity, no click) |
| `precision` | `:float` | `1.0` | Rating granularity — `1.0` for full stars, `0.5` for half-star selection |
| `field` | `Phoenix.HTML.FormField` | `nil` | Form field struct for native Phoenix form integration |
| `label` | `:string` | `nil` | Label text displayed above the rating |
| `name` | `:any` | `nil` | Input name (auto-extracted when using `field`) |
| `errors` | `:list` | `[]` | Error messages (auto-populated when using `field`) |
| `error_icon` | `:string` | `nil` | Icon displayed alongside error messages |
| `params` | `:map` | `%{}` | Additional parameters merged into the event payload |
| `on_action` | `JS` | `%JS{}` | Custom JS command chained before the click action |
| `rest` | `:global` | — | Global attributes merged with caller-provided attributes |

## Available Options

### Colors
`base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large`

### Gaps
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Precision
`1.0` (full star), `0.5` (half star)

## Helper Functions

### `rating_select/2`
Extracts the current rating value from form params or data. Useful for keeping the selected state in sync.

```elixir
rating_select(:rating, @form)
```

## Usage Examples

### Basic Rating (Display)

```heex
<.rating select={4} />
<.rating select={3.5} />
```

### Interactive Rating (Event Mode)

```heex
<.rating id="my-rating" select={@star} interactive />
```

Handle the event in your LiveView:

```elixir
def handle_event("rating", %{"action" => "select", "number" => number}, socket)
    when is_number(number) do
  {:noreply, assign(socket, star: number)}
end
```

### Form Integration (Field Mode)

When you pass the `field` prop, the component auto-enables interactive mode, renders a hidden input for form submission, and displays changeset validation errors.

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.rating field={@form[:rating]} size="large" color="warning" />
</.form>
```

### Half-Star Precision

Set `precision={0.5}` to allow half-star selection. Each star becomes two click targets (left half, right half).

```heex
<.rating
  id="rating-precision"
  select={2.5}
  size="large"
  color="warning"
  precision={0.5}
  interactive
/>
```

### Half-Star Precision with Form

```heex
<.rating field={@form[:rating]} size="large" color="warning" precision={0.5} />
```

Note: use a `:float` field type in your Ecto schema when using precision 0.5.

### Disabled Rating

Renders with reduced opacity and blocks all interaction. Works in both static and interactive modes.

```heex
<.rating select={3} size="large" disabled />
<.rating select={2} size="large" interactive disabled />
```

When using `field` with `disabled`, interactivity is automatically turned off:

```heex
<.rating field={@form[:rating]} disabled />
```

### Different Colors

```heex
<.rating select={4} color="warning" />
<.rating select={4} color="primary" />
<.rating select={4} color="danger" />
```

### Different Sizes

```heex
<.rating select={3} size="small" />
<.rating select={3} size="medium" />
<.rating select={3} size="large" />
```

### Custom Star Count

```heex
<.rating count={10} select={7} size="small" />
```

### With Gap Sizes

```heex
<.rating select={4} gap="small" />
<.rating select={4} gap="large" />
<.rating select={4} gap="extra_large" />
```

### With Label

```heex
<.rating field={@form[:rating]} label="Your Rating" size="large" />
```

### With Custom Params

Pass extra data in the event payload using `params`:

```heex
<.rating
  id="rating-product"
  select={@rating}
  interactive
  params={%{product_id: @product.id}}
/>
```

The params map is merged into the event payload alongside `action` and `number`.

## Common Patterns

### Product Rating Display

```heex
<div class="flex items-center gap-2">
  <.rating select={@product.rating} size="small" />
  <span class="text-sm text-gray-600">({@product.review_count} reviews)</span>
</div>
```

### Review Form with Half-Star Precision

```heex
<.form_wrapper for={@form} id="review-form" phx-change="validate" phx-submit="save" space="medium">
  <.text_field size="medium" field={@form[:fullname]} label="Full Name" />
  <.rating field={@form[:rating]} label="Your Rating" size="large" color="warning" precision={0.5} />
  <.textarea_field size="medium" field={@form[:comment]} label="Comment (optional)" />
  <:actions>
    <.button variant="outline" color="info" size="small" phx-disable-with="Submitting...">
      Submit Review
    </.button>
  </:actions>
</.form_wrapper>
```

### Rating with Value Display

```heex
<div class="flex items-center gap-3">
  <.rating select={@rating} />
  <span class="font-bold">{@rating}/5</span>
</div>
```

### Read-Only Rating in a Form

```heex
<.rating field={@form[:rating]} size="large" disabled />
```

## Event Payloads

### Click Select Event

```elixir
%{"action" => "select", "number" => 3}
# With params:
%{"action" => "select", "number" => 2.5, "product_id" => "abc123"}
```

