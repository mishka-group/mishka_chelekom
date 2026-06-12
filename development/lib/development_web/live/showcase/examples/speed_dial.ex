defmodule DevelopmentWeb.Showcase.Examples.SpeedDial do
  @moduledoc """
  Docs examples for the `speed_dial` component, taken from the Mishka source docs
  (`mishka/.../docs/speed_dial_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The source docs gate each speed dial behind socket state (`@dial_pos`) toggled by a trigger
  button; here the dials are rendered directly so each example is self-contained.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "variants", title: "Variants"},
      %{id: "action_position", title: "Action button position"},
      %{id: "wrapper_position", title: "Wrapper items position"},
      %{id: "sizes", title: "Sizes"},
      %{id: "rounded", title: "Rounded"},
      %{id: "items", title: "Item slot"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-end gap-16 min-h-48">
      <.speed_dial id="ex-speed_dial-default" size="large" variant="default" color="natural" icon="hero-plus">
        <:item icon="hero-home" color="danger" />
        <:item icon="hero-star" color="misc" />
        <:item icon="hero-chart-bar" color="warning" />
      </.speed_dial>
      <.speed_dial id="ex-speed_dial-shadow" variant="shadow" color="success" size="large" icon="hero-plus">
        <:item icon="hero-home" color="danger" />
        <:item icon="hero-star" color="misc" />
        <:item icon="hero-chart-bar" color="warning" />
      </.speed_dial>
      <.speed_dial id="ex-speed_dial-bordered" variant="bordered" color="danger" size="large" icon="hero-plus">
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial id="ex-speed_dial-gradient" variant="gradient" color="misc" size="large" icon="hero-plus">
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
    </div>
    """
  end

  def example(%{section: "action_position"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-16 min-h-48">
      <.speed_dial
        id="ex-speed_dial-pos-top-start"
        wrapper_position="bottom"
        action_position="top-start"
        color="dawn"
        size="large"
        icon="hero-plus"
      >
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial
        id="ex-speed_dial-pos-top-end"
        wrapper_position="bottom"
        action_position="top-end"
        color="silver"
        size="large"
        icon="hero-plus"
      >
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial id="ex-speed_dial-pos-bottom-start" action_position="bottom-start" color="danger" size="large" icon="hero-plus">
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial id="ex-speed_dial-pos-bottom-end" action_position="bottom-end" color="info" size="large" icon="hero-plus">
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
    </div>
    """
  end

  def example(%{section: "wrapper_position"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-16 min-h-48">
      <.speed_dial id="ex-speed_dial-wrap-left" wrapper_position="left" color="dawn" size="large" icon="hero-plus">
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial
        id="ex-speed_dial-wrap-right"
        wrapper_position="right"
        action_position="bottom-start"
        color="silver"
        size="large"
        icon="hero-plus"
      >
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial
        id="ex-speed_dial-wrap-bottom"
        action_position="top-end"
        wrapper_position="bottom"
        color="danger"
        size="large"
        icon="hero-plus"
      >
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-16 min-h-48">
      <.speed_dial id="ex-speed_dial-size-xs" size="extra_small" color="dawn" icon="hero-plus">
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial id="ex-speed_dial-size-tl" size="triple_large" action_position="bottom-start" color="silver" icon="hero-plus">
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-16 min-h-48">
      <.speed_dial id="ex-speed_dial-round-medium" rounded="medium" color="dawn" size="large" icon="hero-plus">
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial
        id="ex-speed_dial-round-xl"
        rounded="extra_large"
        action_position="bottom-start"
        color="silver"
        size="large"
        icon="hero-plus"
      >
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
      <.speed_dial
        id="ex-speed_dial-round-small"
        rounded="small"
        action_position="top-end"
        wrapper_position="bottom"
        color="danger"
        size="large"
        icon="hero-plus"
      >
        <:item icon="hero-home" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" color="primary" />
      </.speed_dial>
    </div>
    """
  end

  def example(%{section: "items"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-16 min-h-48">
      <.speed_dial id="ex-speed_dial-items" size="extra_large" color="info" icon="hero-plus">
        <:item icon="hero-home" variant="bordered" color="info" />
        <:item icon="hero-star" color="secondary" />
        <:item icon="hero-chart-bar" variant="shadow" color="primary" />
        <:item icon="hero-percent-badge" variant="bordered" color="dawn" />
        <:item icon="hero-ticket" color="danger" />
      </.speed_dial>
      <.speed_dial id="ex-speed_dial-items-animated" size="extra_large" icon_animated color="info" icon="hero-plus">
        <:item icon="hero-home" variant="bordered" color="info" />
        <:item icon="hero-wrench" variant="bordered" color="dawn" />
      </.speed_dial>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
