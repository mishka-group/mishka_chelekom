defmodule DevelopmentWeb.Components.Headless.Combobox do
  @moduledoc """
  Headless **combobox** — a text input that filters and selects from a listbox (Base UI parity).

  Behaviour via the shared `HeadlessCombobox` engine: typing filters the options (non-matching get
  `data-hidden`), ArrowDown opens and moves a roving highlight over the **navigable** options (it skips
  `data-hidden` *and* `data-disabled`), Enter/click selects, Escape closes. A selected option carries
  `data-selected` + `aria-selected` (style a checkmark via the `indicator` part).

  Options: `multiple` (multi-select with removable **chips**) · disabled `<:option>` · grouped options
  (give `<:option>` a `group`) · `auto_highlight` · `filter` (`contains`/`starts_with`) · a `clear`
  button · a `trigger` button (open without typing) · a `<:empty>` state · `creatable` (offer to create
  the typed query, pushing `on_create`) · `on_change`. For very long lists pass `virtualized` to add
  `content-visibility:auto` to items (the browser skips off-screen layout/paint — keyboard nav and ARIA
  stay correct because every option is a real node).

  ARIA: input `role="combobox"` + `aria-controls`/`aria-expanded`/`aria-autocomplete`/
  `aria-activedescendant`; listbox `role="listbox"`; options `role="option"` + `aria-selected`/
  `aria-disabled`. Style via `chelekom-combobox*` and the `data-open`/`data-closed`/`data-highlighted`/
  `data-hidden`/`data-selected`/`data-disabled` state attributes.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/combobox/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors the popup and option ids)"
  attr :name, :string, default: nil, doc: "Form name (multiple submits as `name[]`)"
  attr :value, :any, default: nil, doc: "Selected value (a string, or a list when `multiple`)"
  attr :placeholder, :string, default: nil, doc: "Input placeholder text"
  attr :multiple, :boolean, default: false, doc: "Allow selecting several options (renders chips)"
  attr :auto_highlight, :boolean, default: false, doc: "Highlight the first match as you type"

  attr :filter, :string,
    default: "contains",
    values: ~w(contains starts_with),
    doc: "Match mode for the typed query"

  attr :clear, :boolean, default: false, doc: "Render a clear button"
  attr :trigger, :boolean, default: false, doc: "Render a button that opens/closes the popup"
  attr :creatable, :boolean, default: false, doc: "Offer to create the typed query as a new option"
  attr :on_create, :string, default: nil, doc: "LiveView event pushed to create ({value})"
  attr :on_change, :string, default: nil, doc: "LiveView event pushed on selection ({value})"
  attr :virtualized, :boolean, default: false, doc: "content-visibility:auto on items for long lists"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :disabled, :boolean
    attr :group, :string, doc: "Optional group label (consecutive same-group options are grouped)"
  end

  slot :empty, doc: "Shown when the query matches no options"

  def combobox(assigns) do
    values = if assigns.multiple, do: List.wrap(assigns.value), else: []
    assigns = assign(assigns, groups: group_options(assigns.option), values: values)

    ~H"""
    <div
      id={@id}
      phx-hook="HeadlessCombobox"
      data-multiple={@multiple}
      data-creatable={@creatable}
      data-autohighlight={@auto_highlight}
      data-filter={@filter}
      data-name={@name}
      data-on-change={@on_change}
      data-on-create={@on_create}
      class={["chelekom-combobox", @class]}
      {@rest}
    >
      <div data-part="control" class="chelekom-combobox__control">
        <div :if={@multiple} data-part="chips" class="chelekom-combobox__chips">
          <span
            :for={opt <- selected_options(@option, @values)}
            data-part="chip"
            data-chip-value={opt.value}
            class="chelekom-combobox__chip"
          >
            <span data-chip-label>{render_slot(opt)}</span>
            <button type="button" data-part="chip-remove" aria-label="Remove" class="chelekom-combobox__chip-remove">
              ×
            </button>
            <input :if={@name} type="hidden" name={"#{@name}[]"} value={opt.value} data-chip-input />
          </span>
        </div>

        <input
          type="text"
          data-part="input"
          aria-controls={"#{@id}-popup"}
          aria-expanded="false"
          placeholder={@placeholder}
          autocomplete="off"
          class="chelekom-combobox__input"
        />
        <button
          :if={@clear}
          type="button"
          data-part="clear"
          data-hidden
          aria-label="Clear"
          class="chelekom-combobox__clear"
        >
          ×
        </button>
        <button
          :if={@trigger}
          type="button"
          data-part="trigger"
          aria-label="Toggle options"
          tabindex="-1"
          class="chelekom-combobox__trigger"
        >
          ▾
        </button>
      </div>

      <input
        :if={@name && !@multiple}
        type="hidden"
        data-part="value"
        name={@name}
        value={@value}
      />

      <template :if={@multiple} data-part="chip-template">
        <span data-part="chip" class="chelekom-combobox__chip">
          <span data-chip-label></span>
          <button type="button" data-part="chip-remove" aria-label="Remove" class="chelekom-combobox__chip-remove">
            ×
          </button>
          <input type="hidden" data-chip-input />
        </span>
      </template>

      <ul
        id={"#{@id}-popup"}
        data-part="popup"
        role="listbox"
        aria-multiselectable={@multiple && "true"}
        data-closed
        class="chelekom-combobox__popup"
      >
        <%= for {grp, gi} <- Enum.with_index(@groups) do %>
          <%= if grp.label do %>
            <li role="group" aria-labelledby={"#{@id}-grp-#{gi}"} data-part="group" class="chelekom-combobox__group">
              <span id={"#{@id}-grp-#{gi}"} data-part="group-label" class="chelekom-combobox__group-label">
                {grp.label}
              </span>
              <ul role="presentation" class="chelekom-combobox__group-list">
                <.option :for={opt <- grp.options} opt={opt} id={@id} value={@value} multiple={@multiple} virtualized={@virtualized} />
              </ul>
            </li>
          <% else %>
            <.option :for={opt <- grp.options} opt={opt} id={@id} value={@value} multiple={@multiple} virtualized={@virtualized} />
          <% end %>
        <% end %>

        <li :if={@empty != []} data-part="empty" data-hidden role="presentation" class="chelekom-combobox__empty">
          {render_slot(@empty)}
        </li>
        <li :if={@creatable} data-part="create" data-hidden class="chelekom-combobox__create">
          Create “<span data-create-label></span>”
        </li>
      </ul>
    </div>
    """
  end

  attr :opt, :map, required: true
  attr :id, :string, required: true
  attr :value, :any, required: true
  attr :multiple, :boolean, required: true
  attr :virtualized, :boolean, required: true

  defp option(assigns) do
    selected =
      if assigns.multiple,
        do: assigns.opt.value in List.wrap(assigns.value),
        else: assigns.opt.value == assigns.value

    assigns = assign(assigns, :selected, selected)

    ~H"""
    <li
      id={"#{@id}-opt-#{@opt.__i__}"}
      role="option"
      data-part="item"
      data-value={@opt.value}
      data-disabled={@opt[:disabled] || false}
      data-selected={@selected}
      aria-selected={to_string(@selected)}
      aria-disabled={(@opt[:disabled] && "true") || nil}
      style={@virtualized && "content-visibility:auto;contain-intrinsic-size:0 2rem"}
      class="chelekom-combobox__item"
    >
      <span data-part="indicator" aria-hidden="true" class="chelekom-combobox__indicator"></span>
      {render_slot(@opt)}
    </li>
    """
  end

  defp group_options(options) do
    options
    |> Enum.with_index()
    |> Enum.chunk_by(fn {opt, _i} -> opt[:group] end)
    |> Enum.map(fn [{first, _} | _] = chunk ->
      %{label: first[:group], options: Enum.map(chunk, fn {opt, i} -> Map.put(opt, :__i__, i) end)}
    end)
  end

  defp selected_options(options, values) do
    Enum.filter(options, &(&1.value in values))
  end
end
