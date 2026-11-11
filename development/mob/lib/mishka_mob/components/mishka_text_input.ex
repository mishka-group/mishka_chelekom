defmodule MishkaMob.Components.MishkaTextInput do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Text Input** — a single- or
  multi-line field with the form events and the styling props the bridge reads.

  Chelekom's Mob set has no plain text input. `MishkaField` labels and reports
  on a control; the masked, numeric, OTP, tags and select ports are their own
  widgets. This is the missing primitive: the caller owns the value, the
  placeholder and the events, and the component owns the `:text_field` node and
  the props the bridge reads.

  ## The value is controlled

  `value` is echoed back by the screen. The bridge re-keys its remembered text
  only when the string actually changes, so returning what was just typed is a
  no-op and the caret does not move — which is why a controlled field is safe
  here rather than a source of jumping cursors. `value_epoch` is the escape
  hatch: bump it and the native field forgets its remembered text.

  ## Multiline

  `multiline: true` wraps the field into a paragraph of at least three rows and
  keeps Return for a newline instead of submitting. `lines` is the same idea
  with a declared row count.

  ## Leading and trailing nodes

  `leading` and `trailing` put a node on either side of the field, separated by
  `slot_gap`. The field keeps all of its own props; the wrapper is a
  `fill_width` `Row` with `align: :center` and nothing else, so the caller can
  draw the border and padding on an outer container exactly as it would around
  a bare field. With neither slot set, the node is the field itself — no
  wrapper, no extra row.

  ## Not ported

  * The web component's `field` struct, `name` and validity wiring — there is
    no Phoenix form on the device, and Mob text nodes carry no ARIA state.
    Report errors with `MishkaField` around the control instead.
  * `start_section` / `end_section` — the bridge's field is one control, with
    no inline section nodes inside its border.
  * `*_class` and the DOM attributes.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | string | unset | The current text. |
  | `placeholder` | string | unset | Hint shown while empty. |
  | `multiline` | boolean | `false` | A paragraph field. |
  | `lines` | integer | unset | Declared rows for a multiline field. |
  | `max_length` | integer | unset | Rejects edits that would exceed it. |
  | `secure` | boolean | `false` | Masks the text. |
  | `keyboard_type` | `:default` `:email` `:number` `:phone` | unset | Keyboard variant. |
  | `return_key` | string | unset | The keyboard's return label. |
  | `caret` | `"end"` | unset | Pin the insertion point to the end. |
  | `underline` | boolean | bridge default | Material's indicator line (Android). |
  | `value_epoch` | integer | unset | Bump to replace the text the native field remembers. |
  | `text_size` | text token / number | `:base` | Typed text and placeholder. |
  | `text_color` / `placeholder_color` | color token / ARGB int | `:on_surface` / `:muted` | Inks. |
  | `font_family` / `font_weight` / `letter_spacing` / `text_align` | as a Text | unset | Type of the field. |
  | `background` | color token / ARGB int | `:surface_raised` | Field fill. |
  | `border_color` / `border_width` | color / number | `:border` / unset | Outline. |
  | `corner_radius` | radius token / number | `:radius_sm` | Corners. |
  | `padding` / `padding_top` / `padding_right` / `padding_bottom` / `padding_left` | spacing token / number | `:space_sm` | Inner padding. |
  | `width` / `height` / `fill_width` | number / boolean | unset | Size. |
  | `leading` / `trailing` | node or list of nodes | unset | Content beside the field. |
  | `slot_gap` | number | `8` | Space between a slot and the field. |
  | `accessibility_id` | string | unset | Native testTag. |
  | `on_change` / `on_submit` / `on_focus` / `on_blur` | event tag | — | `{:change, tag, value}`, `{:submit, tag}`, `{:focus, tag}`, `{:blur, tag}`. |

  **Documentation:** https://mishka.tools/chelekom/docs/mob/text-input
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @props ~w(
    value placeholder multiline lines max_length secure enabled disabled
    keyboard_type return_key caret underline text_size text_color
    placeholder_color font_family font_weight letter_spacing text_align
    background border_color border_width corner_radius padding padding_top
    padding_right padding_bottom padding_left width height fill_width
    accessibility_id value_epoch
  )a

  @events ~w(on_change on_submit on_focus on_blur)a

  @doc "Composite expander (`<MishkaTextInput />`). Children are ignored."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: text_input(props)

  @doc """
  The text-input node.

      text_input(value: "Dune", placeholder: "Title", on_change: :typed)

      text_input(%{placeholder: "Search", leading: glyph, trailing: glyph},
                 [])
  """
  @spec text_input(map() | keyword()) :: map()
  def text_input(props \\ %{}) do
    props = Map.new(props)
    field = field_node(props)
    leading = Map.get(props, :leading)
    trailing = Map.get(props, :trailing)

    if leading == nil and trailing == nil do
      field
    else
      gap = Map.get(props, :slot_gap) || 8

      children =
        [leading, spacer(leading, gap), field, spacer(trailing, gap), trailing]
        |> Enum.reject(&is_nil/1)

      ~MOB"""
      <Row fill_width={true} align={:center}>
        {children}
      </Row>
      """
    end
  end

  defp field_node(props) do
    forwarded =
      props
      |> Map.take(@props)
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Map.new()

    %{~MOB(<TextField />) | props: Map.merge(forwarded, events(props))}
  end

  defp spacer(nil, _gap), do: nil

  defp spacer(_slot, gap) do
    assigns = %{gap: gap}
    ~MOB"<Spacer size={@gap} />"
  end

  defp events(props) do
    Enum.reduce(@events, %{}, fn key, acc ->
      case Event.handler(Map.get(props, key)) do
        nil -> acc
        handler -> Map.put(acc, key, handler)
      end
    end)
  end
end
