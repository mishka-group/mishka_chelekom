defmodule DevelopmentWeb.Components.Headless.Progress do
  @moduledoc """
  Headless **progress** — a progress bar for task completion (WAI-ARIA progressbar).

  `role="progressbar"` with `aria-valuemin` / `aria-valuemax` / `aria-valuenow` (clamped into the
  range) and `aria-valuetext`. Pass `value={nil}` for an **indeterminate** (loading) bar —
  `aria-valuenow` is then omitted and no fill ratio is set. The root and every part expose the
  status as exactly one of `data-indeterminate` / `data-progressing` / `data-complete`, so you can
  style each state. The inner `data-part="indicator"` carries a `--chelekom-progress` (0..1) ratio
  for the fill; pass `show_value` for a `data-part="value"` readout. Ships **no** colors or spacing —
  style via the `chelekom-progress*` classes.

  WAI-ARIA: https://www.w3.org/TR/wai-aria-1.2/#progressbar

  **Documentation:** https://mishka.tools/chelekom/docs/headless/progress
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional id (anchors aria-labelledby)"
  attr :value, :integer, default: nil, doc: "Current value in [min, max]; nil = indeterminate"
  attr :min, :integer, default: 0, doc: "Lower bound of the range"
  attr :max, :integer, default: 100, doc: "Upper bound of the range"

  attr :label, :string,
    default: nil,
    doc: "Accessible label (rendered + wired to aria-labelledby)"

  attr :value_text, :string,
    default: nil,
    doc:
      ~s|Human value for aria-valuetext + readout (defaults to a percent; "Indeterminate" when nil)|

  attr :show_value, :boolean, default: false, doc: ~s|Render a `data-part="value"` readout|
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :label_class, :any, default: nil, doc: ~s|Extra classes for `data-part="label"`|
  attr :value_class, :any, default: nil, doc: ~s|Extra classes for `data-part="value"`|
  attr :track_class, :any, default: nil, doc: ~s|Extra classes for `data-part="track"`|
  attr :indicator_class, :any, default: nil, doc: ~s|Extra classes for `data-part="indicator"`|
  attr :rest, :global

  def progress(assigns) do
    lo = assigns.min
    hi = assigns.max

    {value, ratio, status} =
      case assigns.value do
        nil ->
          {nil, nil, "indeterminate"}

        v ->
          c = v |> Kernel.max(lo) |> Kernel.min(hi)
          r = if hi > lo, do: (c - lo) / (hi - lo), else: 0.0
          {c, r, if(c >= hi, do: "complete", else: "progressing")}
      end

    assigns =
      assigns
      |> assign(:value, value)
      |> assign(:ratio, ratio)
      |> assign(:status, status)
      |> assign(
        :value_text,
        assigns.value_text ||
          if(status == "indeterminate", do: "Indeterminate", else: "#{round(ratio * 100)}%")
      )

    ~H"""
    <div
      id={@id}
      role="progressbar"
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
      aria-valuetext={@value_text}
      aria-labelledby={@label && @id && "#{@id}-label"}
      class={["chelekom-progress", @class]}
      {status_data(@status)}
      {@rest}
    >
      <span
        :if={@label}
        id={@id && "#{@id}-label"}
        data-part="label"
        class={["chelekom-progress__label", @label_class]}
        {status_data(@status)}
      >
        {@label}
      </span>
      <span
        :if={@show_value}
        data-part="value"
        class={["chelekom-progress__value", @value_class]}
        {status_data(@status)}
      >
        {@value_text}
      </span>
      <div
        data-part="track"
        class={["chelekom-progress__track", @track_class]}
        {status_data(@status)}
      >
        <div
          data-part="indicator"
          style={
            @ratio &&
              "--chelekom-progress: #{@ratio}; width: calc(var(--chelekom-progress) * 100%); height: 100%;"
          }
          class={["chelekom-progress__indicator", @indicator_class]}
          {status_data(@status)}
        >
        </div>
      </div>
    </div>
    """
  end

  # Paired-presence status (Base UI parity): exactly one of the three is present at any time.
  defp status_data(status) do
    %{
      "data-indeterminate" => status == "indeterminate",
      "data-progressing" => status == "progressing",
      "data-complete" => status == "complete"
    }
  end
end
