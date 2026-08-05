defmodule DevelopmentWeb.Components.Headless.ColorInput do
  @moduledoc """
  Headless **color input** — a hex text field with a swatch that opens a color picker in a popover
  (Mantine ColorInput parity).

  Reuses the `ColorPicker` engine: the `area` + `hue` live in a `panel` toggled by JS commands (no
  extra hook) — the trigger keeps `aria-expanded` in sync, clicking outside or pressing Escape
  closes the panel — the `preview` swatch and editable `text` field stay in the always-visible
  `control` row, and a hidden `input` carries the hex for form submission (it fires `input`, so a
  wrapping `<.form phx-change>` sees every change). Typing a valid hex updates the picker and
  vice-versa; `on_change` pushes `{value}` to the server.

  Ships **no** styling — style via `chelekom-color-input*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/color_input
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the ColorPicker hook)"
  attr :name, :string, default: nil, doc: "Name for the hidden hex input"
  attr :value, :string, default: "#3b82f6", doc: "Initial color (hex)"
  attr :form, :string, default: nil, doc: "Form id owning the hidden input"
  attr :on_change, :string, default: nil, doc: "LiveView event pushed on change ({value})"
  attr :label, :string, default: nil, doc: "Accessible label for the hex field"
  attr :class, :any, default: nil
  attr :control_class, :any, default: nil
  attr :preview_class, :any, default: nil
  attr :text_class, :any, default: nil
  attr :trigger_class, :any, default: nil
  attr :panel_class, :any, default: nil
  attr :area_class, :any, default: nil
  attr :thumb_class, :any, default: nil
  attr :hue_class, :any, default: nil
  attr :rest, :global

  def color_input(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="ColorPicker"
      data-part="root"
      data-value={@value}
      data-on-change={@on_change}
      phx-click-away={close_panel(@id)}
      phx-window-keydown={close_panel(@id)}
      phx-key="escape"
      class={["chelekom-color-input", @class]}
      {@rest}
    >
      <div data-part="control" class={["chelekom-color-input__control", @control_class]}>
        <span
          data-part="preview"
          role="img"
          aria-label={"Selected color #{@value}"}
          class={["chelekom-color-input__preview", @preview_class]}
        ></span>
        <input
          data-part="text"
          type="text"
          value={@value}
          spellcheck="false"
          autocomplete="off"
          placeholder="#rrggbb"
          aria-label={@label || "Hex color"}
          class={["chelekom-color-input__text", @text_class]}
        />
        <button
          type="button"
          data-part="trigger"
          phx-click={
            JS.toggle(to: "##{@id}-panel") |> JS.toggle_attribute({"aria-expanded", "true", "false"})
          }
          aria-haspopup="dialog"
          aria-expanded="false"
          aria-controls={"#{@id}-panel"}
          aria-label="Open color picker"
          class={["chelekom-color-input__trigger", @trigger_class]}
        >
          <span aria-hidden="true">▾</span>
        </button>
      </div>
      <div
        id={"#{@id}-panel"}
        data-part="panel"
        role="dialog"
        style="display:none"
        class={["chelekom-color-input__panel", @panel_class]}
      >
        <div data-part="area" class={["chelekom-color-input__area", @area_class]}>
          <span data-part="area-thumb" class={["chelekom-color-input__thumb", @thumb_class]}></span>
        </div>
        <div data-part="controls" class="chelekom-color-input__controls">
          <input
            data-part="hue"
            type="range"
            min="0"
            max="360"
            aria-label="Hue"
            class={["chelekom-color-input__hue", @hue_class]}
          />
        </div>
      </div>
      <input :if={@name} data-part="input" type="hidden" name={@name} value={@value} form={@form} />
    </div>
    """
  end

  defp close_panel(id) do
    JS.hide(to: "##{id}-panel")
    |> JS.set_attribute({"aria-expanded", "false"}, to: "##{id} [data-part=trigger]")
  end
end
