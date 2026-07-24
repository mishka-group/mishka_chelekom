defmodule DevelopmentWeb.Components.Headless.Toolbar do
  @moduledoc """
  Headless **toolbar** — a roving-focus bar of heterogeneous controls (Base UI parity).

  The `Toolbar` engine rovs focus over the items (`button` · `link` · `input`, including those inside a
  `group`) with arrow keys along `orientation` + Home/End, looping when `loop`. With
  `focusable_when_disabled` (default), disabled items stay in the roving order (focusable but inert) so
  they're discoverable; a focused `input` keeps its own cursor movement and only hands navigation back
  at the text boundaries.

  Each `<:item>` picks a `type` (`button` · `link` · `input` · `separator`); consecutive items sharing a
  `group` are wrapped in a labelled `group`. Options mirror Base UI: `orientation` (horizontal | vertical),
  `loop`, `disabled`, `focusable_when_disabled`, per-item `disabled`. State: root/item/group/separator
  `data-orientation`; root/button/group/input `data-disabled`; button/input `data-focusable`. Style via
  `chelekom-toolbar*`.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/toolbar/

  **Documentation:** https://mishka.tools/chelekom/docs/headless/toolbar
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :loop, :boolean, default: true, doc: "Loop arrow-key focus past the ends"
  attr :disabled, :boolean, default: false, doc: "Disable the whole toolbar (data-disabled)"

  attr :focusable_when_disabled, :boolean,
    default: true,
    doc: "Keep disabled items in the roving order"

  attr :class, :any, default: nil
  attr :rest, :global

  slot :item, required: true, doc: "A toolbar control" do
    attr :type, :string, doc: "button (default) | link | input | separator"
    attr :disabled, :boolean
    attr :href, :string, doc: "For type=link"
    attr :label, :string, doc: "Accessible label (aria-label)"
    attr :placeholder, :string, doc: "For type=input"
    attr :value, :string, doc: "For type=input"
    attr :group, :string, doc: "Group label — consecutive same-group items are wrapped"
    attr :group_class, :any, doc: "Extra classes for the group wrapper (data-part=group)"
    attr :class, :any
  end

  def toolbar(assigns) do
    first =
      Enum.find(assigns.item, fn it ->
        (it[:type] || "button") in ~w(button link input) and
          not (it[:disabled] || assigns.disabled)
      end)

    assigns = assign(assigns, groups: group_items(assigns.item), first: first)

    ~H"""
    <div
      id={@id}
      role="toolbar"
      phx-hook="Toolbar"
      data-orientation={@orientation}
      data-disabled={@disabled}
      data-loop={@loop}
      data-focusable-when-disabled={@focusable_when_disabled}
      aria-orientation={@orientation}
      aria-disabled={@disabled && "true"}
      class={["chelekom-toolbar", @class]}
      {@rest}
    >
      <%= for {grp, gi} <- Enum.with_index(@groups) do %>
        <%= if grp.label do %>
          <div
            data-part="group"
            role="group"
            aria-label={grp.label}
            data-orientation={@orientation}
            data-disabled={@disabled}
            class={["chelekom-toolbar__group", grp.class]}
          >
            <.toolbar_item
              :for={item <- grp.items}
              item={item}
              orientation={@orientation}
              disabled={@disabled}
              first={@first}
            />
          </div>
        <% else %>
          <.toolbar_item
            :for={item <- grp.items}
            item={item}
            orientation={@orientation}
            disabled={@disabled}
            first={@first}
          />
        <% end %>
      <% end %>
    </div>
    """
  end

  attr :item, :map, required: true
  attr :orientation, :string, required: true
  attr :disabled, :boolean, required: true
  attr :first, :map, required: true

  defp toolbar_item(%{item: %{type: "separator"}} = assigns) do
    ~H"""
    <div
      data-part="separator"
      role="separator"
      aria-orientation={if @orientation == "horizontal", do: "vertical", else: "horizontal"}
      data-orientation={@orientation}
      class={["chelekom-toolbar__separator", @item[:class]]}
    >
    </div>
    """
  end

  defp toolbar_item(%{item: %{type: "link"}} = assigns) do
    ~H"""
    <a
      data-part="link"
      href={@item[:href] || "#"}
      aria-label={@item[:label]}
      data-orientation={@orientation}
      tabindex={if @item == @first, do: "0", else: "-1"}
      class={["chelekom-toolbar__link", @item[:class]]}
    >
      {render_slot(@item)}
    </a>
    """
  end

  defp toolbar_item(%{item: %{type: "input"}} = assigns) do
    dis = assigns.disabled || assigns.item[:disabled]
    assigns = assign(assigns, :dis, dis)

    ~H"""
    <input
      type="text"
      data-part="input"
      placeholder={@item[:placeholder]}
      value={@item[:value]}
      aria-label={@item[:label]}
      aria-disabled={@dis && "true"}
      data-disabled={@dis}
      data-focusable
      data-orientation={@orientation}
      tabindex={if @item == @first, do: "0", else: "-1"}
      class={["chelekom-toolbar__input", @item[:class]]}
    />
    """
  end

  defp toolbar_item(assigns) do
    dis = assigns.disabled || assigns.item[:disabled]
    assigns = assign(assigns, :dis, dis)

    ~H"""
    <button
      type="button"
      data-part="button"
      aria-label={@item[:label]}
      aria-disabled={@dis && "true"}
      data-disabled={@dis}
      data-focusable
      data-orientation={@orientation}
      tabindex={if @item == @first, do: "0", else: "-1"}
      class={["chelekom-toolbar__button", @item[:class]]}
    >
      {render_slot(@item)}
    </button>
    """
  end

  # Chunk consecutive items sharing a `group` into labelled groups (ungrouped → label nil).
  defp group_items(items) do
    items
    |> Enum.chunk_by(& &1[:group])
    |> Enum.map(fn [first | _] = chunk ->
      %{label: first[:group], class: first[:group_class], items: chunk}
    end)
  end
end
