defmodule DevelopmentWeb.Components.Headless.ThemeController do
  @moduledoc """
  Headless **theme controller** — pick a theme, and have it stick.

  daisyUI's theme controller is a pure-CSS trick: a checked input with the right class repaints the
  page. It is elegant and it forgets everything the moment you navigate — the choice lives in a
  checkbox, not anywhere durable. This one writes `data-theme` onto the target element, remembers
  it in `localStorage`, and restores it on the next visit.

  The controls are **native inputs**. A radio group of themes is `<input type="radio">`, and a
  two-theme switch is `<input type="checkbox">`, so arrow-key navigation, form participation and
  screen-reader semantics are the browser's rather than a hook's re-implementation of them. That
  also means daisyUI's own CSS mechanism keeps working alongside ours.

  `target` says what gets the attribute — `:root` by default, or any selector, which is what lets a
  page preview a theme inside a box instead of repainting itself. `system` adds an option that
  follows `prefers-color-scheme` and keeps following it as the OS setting changes.

  Parts: `option`, `input`, `label`. Give a `:option` slot body and it becomes the label's content,
  so an icon or a swatch goes where the text would.

  Ships **no** colors, sizing or spacing — style via `chelekom-theme-controller*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/theme_controller
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the ThemeController hook)"
  attr :name, :string, default: nil, doc: "Name for the inputs; defaults to the id"

  attr :value, :string,
    default: nil,
    doc: "The theme selected on the server; the stored choice wins once the hook runs"

  attr :target, :string,
    default: ":root",
    doc: ~s|Selector of the element that gets `data-theme`; `:root` is the page|

  attr :storage_key, :string,
    default: nil,
    doc: "localStorage key; defaults to the id. Set to \"\" to not persist at all"

  attr :label, :string, default: "Theme", doc: "Accessible name for the group"

  attr :switch, :boolean,
    default: false,
    doc: "Render a single checkbox between the first two themes instead of a radio per theme"

  attr :system_label, :string, default: "System", doc: "Label for the `system` option"

  attr :system, :boolean,
    default: false,
    doc: "Add an option that follows the OS setting, and keeps following it"

  attr :on_change, :string,
    default: nil,
    doc: "LiveView event pushed as `%{theme}` on every change"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :option_class, :any, default: nil, doc: ~s|Extra classes for `data-part="option"`|
  attr :input_class, :any, default: nil, doc: ~s|Extra classes for `data-part="input"`|
  attr :label_class, :any, default: nil, doc: ~s|Extra classes for `data-part="label"`|
  attr :rest, :global

  slot :option, doc: "One theme" do
    attr :value, :string, required: true, doc: "The theme name written to `data-theme`"
    attr :label, :string, doc: "Visible text; falls back to the value"
    attr :class, :any
  end

  def theme_controller(assigns) do
    assigns =
      assigns
      |> assign(:name, assigns.name || assigns.id)
      |> assign(:storage_key, assigns.storage_key || assigns.id)
      |> assign(:options, options(assigns))

    ~H"""
    <div
      id={@id}
      role={!@switch && "radiogroup"}
      aria-label={@label}
      phx-hook="ThemeController"
      data-part="root"
      data-target={@target}
      data-storage-key={@storage_key}
      data-theme-value={@value}
      data-on-change={@on_change}
      class={["chelekom-theme-controller", @class]}
      {@rest}
    >
      <label
        :for={option <- @options}
        data-part="option"
        data-value={option.value}
        data-checked={option.value == @value}
        class={["chelekom-theme-controller__option", @option_class, option[:class]]}
      >
        <input
          type={if @switch, do: "checkbox", else: "radio"}
          name={@name}
          value={option.value}
          checked={option.value == @value}
          data-part="input"
          data-value={option.value}
          data-unchecked-value={@switch && option[:off]}
          class={["chelekom-theme-controller__input", @input_class]}
        />
        <span data-part="label" class={["chelekom-theme-controller__label", @label_class]}>{if option.slot &&
                                                                                                 option.slot[
                                                                                                   :inner_block
                                                                                                 ],
                                                                                               do:
                                                                                                 render_slot(
                                                                                                   option.slot
                                                                                                 ),
                                                                                               else:
                                                                                                 option.label}</span>
      </label>
    </div>
    """
  end

  # A switch is one input standing for two themes: checked means the second, unchecked the first.
  # The off value has to travel *on the surviving option*, because the first one is dropped here
  # and there would otherwise be nothing left to switch back to.
  defp options(%{switch: true} = assigns) do
    case build(assigns) do
      [first, second | _] -> [Map.put(second, :off, first.value)]
      other -> other
    end
  end

  defp options(assigns), do: build(assigns)

  # The slot travels with the entry rather than being rendered here: `render_slot/1` only works
  # inside a template, so the choice between an icon and a name is made in the markup.
  defp build(assigns) do
    from_slots =
      Enum.map(assigns.option, fn option ->
        %{
          value: option.value,
          class: option[:class],
          label: option[:label] || option.value,
          slot: option,
          off: nil
        }
      end)

    if assigns.system do
      from_slots ++
        [%{value: "system", class: nil, label: assigns.system_label, slot: nil, off: nil}]
    else
      from_slots
    end
  end
end
