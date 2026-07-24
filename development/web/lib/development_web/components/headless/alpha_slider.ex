defmodule DevelopmentWeb.Components.Headless.AlphaSlider do
  @moduledoc """
  Headless **alpha slider** — pick an opacity (0–100) with a draggable handle (Mantine
  AlphaSlider parity).

  Reuses the shared `Slider` engine preset to `0..100`, so there is **no new JS**. The base
  `color` is exposed as the `--chelekom-alpha-color` CSS variable so your track can paint a
  `transparent → color` gradient over a checkerboard. Values mirror into a hidden input.

  Ships **no** styling — style via `chelekom-alpha-slider*`.

  WAI-ARIA APG: Slider pattern.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/alpha_slider
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the Slider hook)"
  attr :name, :string, default: nil, doc: "Name for the hidden form input"
  attr :value, :any, default: 100, doc: "Current opacity (0–100)"
  attr :color, :string, default: "#000000", doc: "Base color (exposed as --chelekom-alpha-color)"
  attr :step, :integer, default: 1, doc: "Arrow-key step"
  attr :disabled, :boolean, default: false, doc: "Disable interaction (data-disabled)"
  attr :label, :string, default: "Opacity", doc: "Accessible label (aria-label)"
  attr :form, :string, default: nil, doc: "Form id owning the hidden input"
  attr :on_change, :string, default: nil, doc: "LiveView event pushed on change ({value})"
  attr :on_commit, :string, default: nil, doc: "LiveView event pushed on release ({value})"
  attr :class, :any, default: nil
  attr :control_class, :any, default: nil
  attr :track_class, :any, default: nil
  attr :thumb_class, :any, default: nil
  attr :rest, :global

  def alpha_slider(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Slider"
      data-min="0"
      data-max="100"
      data-step={@step}
      data-large-step="10"
      data-orientation="horizontal"
      data-disabled={@disabled}
      data-name={@name}
      data-on-change={@on_change}
      data-on-commit={@on_commit}
      style={"--chelekom-alpha-color: #{@color}"}
      class={["chelekom-alpha-slider", @class]}
      {@rest}
    >
      <div
        data-part="control"
        data-orientation="horizontal"
        data-disabled={@disabled}
        class={["chelekom-alpha-slider__control", @control_class]}
      >
        <div
          data-part="track"
          data-orientation="horizontal"
          class={["chelekom-alpha-slider__track", @track_class]}
        >
          <div
            data-part="indicator"
            data-orientation="horizontal"
            class="chelekom-alpha-slider__indicator"
          >
          </div>
          <span
            data-part="thumb"
            data-index="0"
            data-value={@value}
            data-orientation="horizontal"
            data-disabled={@disabled}
            role="slider"
            aria-orientation="horizontal"
            aria-valuemin="0"
            aria-valuemax="100"
            aria-valuenow={@value}
            aria-label={@label}
            tabindex={if @disabled, do: "-1", else: "0"}
            class={["chelekom-alpha-slider__thumb", @thumb_class]}
          >
            <input
              :if={@name}
              type="hidden"
              name={@name}
              value={@value}
              form={@form}
              data-part="input"
            />
          </span>
        </div>
      </div>
    </div>
    """
  end
end
