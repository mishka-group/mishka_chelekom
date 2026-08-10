defmodule DevelopmentWeb.Components.Headless.Fab do
  @moduledoc """
  Headless **fab** — a floating action button that can fan out into a speed dial.

  daisyUI opens its speed dial with `:focus-within` on a `<div tabindex="0" role="button">`. That
  is clever CSS and a poor button: it is not a button to assistive tech, it cannot be activated
  with Space, and it has no open state anything can read. This one is a real `<button>` driven by
  the shared `Popup` engine, so it carries `aria-expanded`, closes on Escape and on an outside
  click, and reports `data-open` for the skin.

  With no actions it is simply a floating button — daisyUI's "a single FAB" case — and it renders
  no popup at all rather than an empty one.

  Two things the trigger can become while open. `close_icon` swaps its content for a dismiss glyph,
  and `:main_action` replaces the trigger outright with a different button, which is daisyUI's
  `fab-main-action`: the fan-out is open, so the button underneath is free to mean something else.

  Parts: `trigger`, `popup`, `action`, `label`, `main-action`.

  Ships **no** colors, sizing or spacing — style via `chelekom-fab*` and the `data-open` hook.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/fab
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id (carries the Popup hook)"
  attr :label, :string, required: true, doc: "Accessible name for the trigger"

  attr :placement, :string,
    default: "bottom-end",
    values: ~w(bottom-end bottom-start top-end top-start),
    doc: "Which corner the button floats in"

  attr :contained, :boolean,
    default: false,
    doc: "Drop the fixed positioning so the button floats inside its container"

  attr :direction, :string,
    default: "up",
    values: ~w(up down left right flower),
    doc: "Where the actions fan out; `flower` is daisyUI's quarter-circle"

  attr :close_label, :string,
    default: "Close",
    doc: "Accessible name for the trigger once it is open, when `close_icon` is given"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :trigger_class, :any, default: nil, doc: ~s|Extra classes for `data-part="trigger"`|
  attr :popup_class, :any, default: nil, doc: ~s|Extra classes for `data-part="popup"`|
  attr :action_class, :any, default: nil, doc: ~s|Extra classes for every `data-part="action"`|
  attr :rest, :global

  slot :icon, required: true, doc: "The trigger's glyph"
  slot :close_icon, doc: "Replaces the trigger's glyph while open"

  slot :main_action,
    doc: "Replaces the trigger entirely while open — daisyUI's `fab-main-action`" do
    attr :label, :string, required: true
    attr :on_click, :any
    attr :navigate, :string
    attr :href, :string
    attr :class, :any
  end

  slot :action, doc: "One action in the speed dial" do
    attr :label, :string, required: true, doc: "The action's name"
    attr :show_label, :boolean, doc: "Render the label beside the glyph as well as announcing it"
    attr :on_click, :any
    attr :navigate, :string
    attr :href, :string
    attr :disabled, :boolean
    attr :class, :any
  end

  def fab(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Popup"
      data-part="root"
      data-side={side_for(@direction)}
      data-align="center"
      data-placement={@placement}
      data-direction={@direction}
      data-contained={@contained}
      class={["chelekom-fab", @class]}
      {@rest}
    >
      <button
        type="button"
        data-part="trigger"
        aria-label={if @close_icon != [], do: @close_label, else: @label}
        aria-haspopup={@action != [] && "true"}
        aria-expanded={@action != [] && "false"}
        aria-controls={@action != [] && "#{@id}-actions"}
        class={["chelekom-fab__trigger", @trigger_class]}
      >
        <span data-part="icon" data-state="closed" class="chelekom-fab__icon">{render_slot(@icon)}</span>
        <span
          :if={@close_icon != []}
          data-part="icon"
          data-state="open"
          class="chelekom-fab__icon"
        >{render_slot(@close_icon)}</span>
      </button>

      <div
        :if={@action != []}
        id={"#{@id}-actions"}
        data-part="popup"
        data-closed
        role="menu"
        aria-label={@label}
        class={["chelekom-fab__popup", @popup_class]}
      >
        <.fab_button
          :for={{action, index} <- Enum.with_index(@action)}
          action={action}
          part="action"
          index={index}
          class={@action_class}
        />

        <.fab_button
          :for={main <- @main_action}
          action={main}
          part="main-action"
          index={-1}
          class={nil}
        />
      </div>
    </div>
    """
  end

  attr :action, :map, required: true
  attr :part, :string, required: true
  attr :index, :integer, required: true
  attr :class, :any, default: nil

  defp fab_button(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={if link?(@action), do: "a", else: "button"}
      role="menuitem"
      data-part={@part}
      data-index={@index >= 0 && @index}
      data-disabled={@action[:disabled]}
      aria-label={@action.label}
      phx-click={!@action[:disabled] && !link?(@action) && @action[:on_click]}
      class={["chelekom-fab__action", @class, @action[:class]]}
      {button_attrs(@action)}
    >
      <span data-part="icon" aria-hidden="true" class="chelekom-fab__action-icon">{render_slot(
        @action
      )}</span>
      <span
        :if={@action[:show_label]}
        data-part="label"
        aria-hidden="true"
        class="chelekom-fab__label"
      >{@action.label}</span>
    </.dynamic_tag>
    """
  end

  # The popup fans out from the button, so the direction is a side the shared engine already knows
  # how to place — except `flower`, which is a layout the skin draws rather than a placement.
  defp side_for("down"), do: "bottom"
  defp side_for("left"), do: "left"
  defp side_for("right"), do: "right"
  defp side_for(_), do: "top"

  defp link?(action), do: action[:navigate] || action[:href]

  defp button_attrs(action) do
    cond do
      navigate = action[:navigate] ->
        %{"href" => navigate, "data-phx-link" => "redirect", "data-phx-link-state" => "push"}

      href = action[:href] ->
        %{"href" => href}

      true ->
        %{"type" => "button", "disabled" => !!action[:disabled]}
    end
  end

  @doc "Closes the fab from a caller's own JS chain — an action that should dismiss it on click."
  @spec close(JS.t(), String.t()) :: JS.t()
  def close(js \\ %JS{}, id) do
    js
    |> JS.remove_attribute("data-open", to: "##{id} [data-part='popup']")
    |> JS.set_attribute({"data-closed", ""}, to: "##{id} [data-part='popup']")
    |> JS.set_attribute({"aria-expanded", "false"}, to: "##{id} [data-part='trigger']")
  end
end
