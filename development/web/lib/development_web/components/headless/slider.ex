defmodule DevelopmentWeb.Components.Headless.Slider do
  @moduledoc """
  Headless **slider** — single- or multi-thumb range input (Base UI parity).

  Anatomy (Base-UI parts): an optional `label` and `value` readout, then a `control` holding a
  `track` with an `indicator` (the filled interval) and one `thumb` (role=slider) per value. Pass a
  single `value` or a list of `values` (a range). Behaviour via the `Slider` engine: pointer drag +
  keyboard (Arrow ±`step` — Up/Right increase; Shift+Arrow / PageUp/Down ±`large_step`; Home/End →
  min/max). Range thumbs keep `min_steps_between_values` apart and obey `thumb_collision`
  (`push` · `swap` · `none`). `orientation="vertical"` flips the axis.

  Options mirror Base UI: `min`/`max`/`step`/`large_step`, `min_steps_between_values`, `orientation`,
  `disabled`, `format` (an `Intl.NumberFormat` map) + `locale`, `name`/`form`, `thumb_collision`,
  `on_change`/`on_commit`. State attributes (all parts): `data-orientation`, `data-dragging` (while
  dragging), `data-disabled`; each thumb has `data-index` + `aria-valuemin/max/now`/`aria-valuetext`/
  `aria-orientation`. Values mirror into hidden inputs (single → `name`, range → `name[]`) and
  dispatch `input` on commit so `<.form phx-change>` fires. Style via `chelekom-slider*`.

  WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/patterns/slider/ (and slider-multithumb)

  **Documentation:** https://mishka.tools/chelekom/docs/headless/slider
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, required: true
  attr :name, :string, default: nil, doc: "Name for the hidden form input(s)"
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :step, :integer, default: 1
  attr :large_step, :integer, default: 10, doc: "Step for PageUp/Down and Shift+Arrow"

  attr :min_steps_between_values, :integer,
    default: 0,
    doc: "Minimum gap (in steps) between range thumbs"

  attr :value, :any,
    default: nil,
    doc: "Single-thumb value — accepts a Phoenix form value (integer, float or string)"

  attr :values, :list, default: nil, doc: "Multi-thumb values (a range; overrides value)"
  attr :orientation, :string, default: "horizontal", doc: "horizontal | vertical"
  attr :disabled, :boolean, default: false, doc: "Disable interaction (data-disabled)"

  attr :format, :map,
    default: nil,
    doc: "Intl.NumberFormat options for aria-valuetext + value readout"

  attr :locale, :string, default: nil, doc: "BCP-47 locale for formatting"

  attr :thumb_collision, :string,
    default: "push",
    doc: "push | swap | none — range collision behaviour"

  attr :thumb_labels, :list, default: nil, doc: "Per-thumb aria-labels (range)"
  attr :show_value, :boolean, default: false, doc: "Render the value readout"
  attr :label, :string, default: nil, doc: "Accessible label"
  attr :form, :string, default: nil, doc: "Form id owning the hidden input(s)"
  attr :on_change, :string, default: nil, doc: "LiveView event pushed on change ({value})"
  attr :on_commit, :string, default: nil, doc: "LiveView event pushed on release/keyup ({value})"
  attr :class, :any, default: nil
  attr :control_class, :any, default: nil, doc: "Extra classes for the control part"
  attr :track_class, :any, default: nil, doc: "Extra classes for the track part"

  attr :indicator_class, :any,
    default: nil,
    doc: "Extra classes for the indicator (filled interval)"

  attr :thumb_class, :any, default: nil, doc: "Extra classes for each thumb"
  attr :rest, :global

  def slider(assigns) do
    values =
      cond do
        is_list(assigns.values) and assigns.values != [] -> assigns.values
        assigns.value in [nil, ""] -> [assigns.min]
        true -> [assigns.value]
      end

    assigns =
      assign(assigns,
        values: values,
        multiple: length(values) > 1,
        format_json: assigns.format && Phoenix.json_library().encode!(assigns.format)
      )

    ~H"""
    <div
      id={@id}
      phx-hook="Slider"
      data-min={@min}
      data-max={@max}
      data-step={@step}
      data-large-step={@large_step}
      data-min-steps={@min_steps_between_values}
      data-orientation={@orientation}
      data-disabled={@disabled}
      data-collision={@thumb_collision}
      data-format={@format_json}
      data-locale={@locale}
      data-name={@name}
      data-on-change={@on_change}
      data-on-commit={@on_commit}
      class={["chelekom-slider", @class]}
      {@rest}
    >
      <label :if={@label} id={"#{@id}-label"} data-part="label" class="chelekom-slider__label">
        {@label}
      </label>

      <output
        :if={@show_value}
        data-part="value"
        data-orientation={@orientation}
        class="chelekom-slider__value"
      >
        {Enum.join(@values, " – ")}
      </output>

      <div
        data-part="control"
        data-orientation={@orientation}
        data-disabled={@disabled}
        class={["chelekom-slider__control", @control_class]}
      >
        <div
          data-part="track"
          data-orientation={@orientation}
          class={["chelekom-slider__track", @track_class]}
        >
          <div
            data-part="indicator"
            data-orientation={@orientation}
            class={["chelekom-slider__indicator", @indicator_class]}
          >
          </div>
          <span
            :for={{v, i} <- Enum.with_index(@values)}
            data-part="thumb"
            data-index={i}
            data-value={v}
            data-orientation={@orientation}
            data-disabled={@disabled}
            role="slider"
            aria-orientation={@orientation}
            aria-valuemin={@min}
            aria-valuemax={@max}
            aria-valuenow={v}
            aria-label={thumb_label(@thumb_labels, @label, i, @multiple)}
            aria-labelledby={@label && !@thumb_labels && "#{@id}-label"}
            tabindex={if @disabled, do: "-1", else: "0"}
            class={["chelekom-slider__thumb", @thumb_class]}
          >
            <input
              :if={@name}
              type="hidden"
              name={if @multiple, do: "#{@name}[]", else: @name}
              value={v}
              form={@form}
              data-part="input"
            />
          </span>
        </div>
      </div>
    </div>
    """
  end

  defp thumb_label(labels, _label, i, _multiple) when is_list(labels), do: Enum.at(labels, i)
  defp thumb_label(_labels, label, _i, false), do: label
  defp thumb_label(_labels, _label, 0, true), do: "Minimum"
  defp thumb_label(_labels, _label, _i, true), do: "Maximum"
end
