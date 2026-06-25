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

  attr :input_class, :any,
    default: nil,
    doc: "Extra classes for the `data-part=\"input\"` element"

  attr :popup_class, :any,
    default: nil,
    doc: "Extra classes for the `data-part=\"popup\"` listbox"

  attr :status_class, :any,
    default: nil,
    doc: "Extra classes for the `data-part=\"status\"` live region"

  attr :empty_class, :any,
    default: nil,
    doc: "Extra classes for the `data-part=\"empty\"` wrapper"

  attr :inline, :boolean,
    default: false,
    doc:
      "Render the list in normal flow (static, always open) instead of a floating popup — e.g. a command palette"

  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true

    attr :label, :string,
      doc:
        "Display string shown in the input/chip when selected (defaults to `value`); the option's inner content can be richer"

    attr :group, :string, doc: "Optional group label (consecutive same-group options are grouped)"
    attr :class, :any, doc: "Extra classes for this option's `data-part=\"item\"`"

    attr :group_class, :any,
      doc: "Extra classes for the `data-part=\"group\"` wrapper (first option of a group)"

    attr :group_label_class, :any,
      doc: "Extra classes for the `data-part=\"group-label\"` (first option of a group)"

    attr :group_list_class, :any,
      doc: "Extra classes for the `data-part=\"group-list\"` (first option of a group)"
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
      data-inline={@inline}
      class={["chelekom-autocomplete", @class]}
      {@rest}
    >
      <input
        type="text"
        data-part="input"
        aria-controls={"#{@id}-popup"}
        placeholder={@placeholder}
        disabled={@disabled}
        readonly={@readonly}
        required={@required}
        autocomplete="off"
        aria-expanded={to_string(@inline)}
        class={["chelekom-autocomplete__input", @input_class]}
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
      <div
        data-part="status"
        role="status"
        aria-live="polite"
        class={["chelekom-sr-only", @status_class]}
      >
      </div>
      <ul
        id={"#{@id}-popup"}
        data-part="popup"
        role="listbox"
        data-open={@inline}
        data-closed={!@inline}
        class={[!@inline && "chelekom-autocomplete__popup", @popup_class]}
      >
        <%= for {grp, gi} <- Enum.with_index(@groups) do %>
          <%= if grp.label do %>
            <li
              role="group"
              aria-labelledby={"#{@id}-grp-#{gi}"}
              data-part="group"
              class={["chelekom-autocomplete__group", grp.group_class]}
            >
              <span
                id={"#{@id}-grp-#{gi}"}
                data-part="group-label"
                class={["chelekom-autocomplete__group-label", grp.group_label_class]}
              >
                {grp.label}
              </span>
              <ul
                role="presentation"
                data-part="group-list"
                class={["chelekom-autocomplete__group-list", grp.group_list_class]}
              >
                <li
                  :for={opt <- grp.options}
                  id={"#{@id}-opt-#{opt.__i__}"}
                  role="option"
                  data-part="item"
                  data-value={opt.value}
                  data-label={opt[:label] || opt.value}
                  aria-selected={to_string(opt.value == @value)}
                  class={["chelekom-autocomplete__item", opt[:class]]}
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
              data-label={opt[:label] || opt.value}
              aria-selected={to_string(opt.value == @value)}
              class={["chelekom-autocomplete__item", opt[:class]]}
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
          class={["chelekom-autocomplete__empty", @empty_class]}
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
      %{
        label: first[:group],
        group_class: first[:group_class],
        group_label_class: first[:group_label_class],
        group_list_class: first[:group_list_class],
        options: Enum.map(chunk, fn {opt, i} -> Map.put(opt, :__i__, i) end)
      }
    end)
  end
end
