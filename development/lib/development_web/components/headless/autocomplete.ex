defmodule DevelopmentWeb.Components.Headless.Autocomplete do
  @moduledoc """
  Headless **autocomplete** — a free-text input with inline suggestions.

  Behaviour via the shared `HeadlessCombobox` engine: typing in the `input` filters the options
  (non-matching items get `data-hidden`), ArrowDown opens and moves a roving highlight
  (`data-highlighted` + `aria-activedescendant`), Enter/click selects (filling the input and a hidden
  `value` input), and Escape closes. The engine wires `role="combobox"`, `aria-controls`,
  `aria-expanded` and `aria-autocomplete` on the input; the listbox is `role="listbox"`, options are
  `role="option"`.

  Options: `auto_highlight` (highlight the first match → Enter selects it) · `filter`
  (`contains` | `starts_with`) · `disabled` / `readonly` / `required` · a `<:empty>` slot shown when
  nothing matches · a `clear` button · grouped options (give `<:option>` a `group` — consecutive
  same-group options render under a `role="group"` with a `data-part="group-label"`). A
  `data-part="status"` live region announces the result count.

  Style via `chelekom-autocomplete*` classes and the `data-open`/`data-closed`/`data-highlighted`/
  `data-hidden` state attributes.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/combobox/
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (anchors the popup and option ids)"
  attr :name, :string, default: nil, doc: "Name for the hidden form input"
  attr :value, :string, default: nil, doc: "Currently selected value"
  attr :placeholder, :string, default: nil, doc: "Input placeholder text"
  attr :disabled, :boolean, default: false, doc: "Disable the input (never opens)"
  attr :readonly, :boolean, default: false, doc: "Make the input read-only"
  attr :required, :boolean, default: false, doc: "Mark the input as required"

  attr :auto_highlight, :boolean,
    default: false,
    doc: "Highlight the first match as you type so Enter selects it without ArrowDown"

  attr :filter, :string,
    default: "contains",
    values: ~w(contains starts_with),
    doc: "Match mode for the typed query"

  attr :clear, :boolean, default: false, doc: "Render a `data-part=\"clear\"` button"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :group, :string, doc: "Optional group label (consecutive same-group options are grouped)"
  end

  slot :empty, doc: "Shown when the query matches no options"

  def autocomplete(assigns) do
    assigns = assign(assigns, :groups, group_options(assigns.option))

    ~H"""
    <div
      id={@id}
      phx-hook="HeadlessCombobox"
      data-autohighlight={@auto_highlight}
      data-filter={@filter}
      class={["chelekom-autocomplete", @class]}
      {@rest}
    >
      <input
        type="text"
        data-part="input"
        aria-controls={"#{@id}-popup"}
        aria-expanded="false"
        placeholder={@placeholder}
        disabled={@disabled}
        readonly={@readonly}
        required={@required}
        autocomplete="off"
        class="chelekom-autocomplete__input"
      />
      <button
        :if={@clear}
        type="button"
        data-part="clear"
        data-hidden
        aria-label="Clear"
        class="chelekom-autocomplete__clear"
      >
        ×
      </button>
      <input :if={@name} type="hidden" data-part="value" name={@name} value={@value} />
      <div data-part="status" role="status" aria-live="polite" class="chelekom-sr-only"></div>
      <ul
        id={"#{@id}-popup"}
        data-part="popup"
        role="listbox"
        data-closed
        class="chelekom-autocomplete__popup"
      >
        <%= for {grp, gi} <- Enum.with_index(@groups) do %>
          <%= if grp.label do %>
            <li
              role="group"
              aria-labelledby={"#{@id}-grp-#{gi}"}
              data-part="group"
              class="chelekom-autocomplete__group"
            >
              <span
                id={"#{@id}-grp-#{gi}"}
                data-part="group-label"
                class="chelekom-autocomplete__group-label"
              >
                {grp.label}
              </span>
              <ul role="presentation" class="chelekom-autocomplete__group-list">
                <li
                  :for={opt <- grp.options}
                  id={"#{@id}-opt-#{opt.__i__}"}
                  role="option"
                  data-part="item"
                  data-value={opt.value}
                  aria-selected={to_string(opt.value == @value)}
                  class="chelekom-autocomplete__item"
                >
                  {render_slot(opt)}
                </li>
              </ul>
            </li>
          <% else %>
            <li
              :for={opt <- grp.options}
              id={"#{@id}-opt-#{opt.__i__}"}
              role="option"
              data-part="item"
              data-value={opt.value}
              aria-selected={to_string(opt.value == @value)}
              class="chelekom-autocomplete__item"
            >
              {render_slot(opt)}
            </li>
          <% end %>
        <% end %>
        <li
          :if={@empty != []}
          data-part="empty"
          data-hidden
          role="presentation"
          class="chelekom-autocomplete__empty"
        >
          {render_slot(@empty)}
        </li>
      </ul>
    </div>
    """
  end

  # Group consecutive same-`group` options; assign each option a stable 0-based index for its id.
  defp group_options(options) do
    options
    |> Enum.with_index()
    |> Enum.chunk_by(fn {opt, _i} -> opt[:group] end)
    |> Enum.map(fn [{first, _} | _] = chunk ->
      %{label: first[:group], options: Enum.map(chunk, fn {opt, i} -> Map.put(opt, :__i__, i) end)}
    end)
  end
end
