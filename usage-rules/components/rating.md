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
| `color` | `:string` | `"warning"` | Star color theme — one of: `base`, `natural`, `white`, `primary`, `secondary`, `dark`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn` |
| `size` | `:string` | `"small"` | Star size — one of: `extra_small`, `small`, `medium`, `large`, `extra_large`, `double_large`, `triple_large`, `quadruple_large` |
| `gap` | `:string` | `"small"` | Space between stars — one of: `extra_small`, `small`, `medium`, `large`, `extra_large`, `none` |
| `count` | `:integer` | `5` | Number of stars |
| `select` | `:any` | `0` | Selected rating value (integer or float) |
| `interactive` | `:boolean` | `false` | Allow user selection via click |
| `disabled` | `:boolean` | `false` | Disable all interaction (reduced opacity, no click); works in both static and interactive modes; when combined with `field`, interactivity is automatically turned off |
| `precision` | `:float` | `1.0` | Rating granularity — `1.0` for full stars, `0.5` for half-star selection (each star becomes two click targets: left/right half). Use a `:float` field type in your Ecto schema when using `0.5` with `field` |
| `field` | `Phoenix.HTML.FormField` | `nil` | Form field struct for native Phoenix form integration; auto-enables interactive mode, renders a hidden input for form submission, and displays changeset validation errors |
| `label` | `:string` | `nil` | Label text displayed above the rating |
| `name` | `:any` | `nil` | Input name (auto-extracted when using `field`) |
| `errors` | `:list` | `[]` | Error messages (auto-populated when using `field`) |
| `error_icon` | `:string` | `nil` | Icon displayed alongside error messages |
| `params` | `:map` | `%{}` | Additional parameters merged into the event payload alongside `action` and `number` |
| `on_action` | `JS` | `%JS{}` | Custom JS command chained before the click action |
| `rest` | `:global` | — | Global attributes merged with caller-provided attributes |

## Helper Functions

### `rating_select/2`
Extracts the current rating value from form params or data. Useful for keeping the selected state in sync.

```elixir
rating_select(:rating, @form)
```

## Usage Examples

### Basic Rating (Display, colors, sizes, gaps, count)

```heex
<.rating select={4} />
<.rating select={3.5} />
<.rating select={4} color="primary" />
<.rating select={3} size="large" />
<.rating select={4} gap="extra_large" />
<.rating count={10} select={7} size="small" />
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

Event payload shape:

```elixir
%{"action" => "select", "number" => 3}
# With params:
%{"action" => "select", "number" => 2.5, "product_id" => "abc123"}
```

### Form Integration (Field Mode), with Label and Half-Star Precision

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.rating field={@form[:rating]} label="Your Rating" size="large" color="warning" precision={0.5} />
</.form>
```

### Disabled Rating

```heex
<.rating select={3} size="large" disabled />
<.rating select={2} size="large" interactive disabled />
<.rating field={@form[:rating]} size="large" disabled />
```

### With Custom Params

```heex
<.rating
  id="rating-product"
  select={@rating}
  interactive
  params={%{product_id: @product.id}}
/>
```

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
