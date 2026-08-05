defmodule DevelopmentWeb.Showcase.Examples.Stepper do
  @moduledoc """
  Docs examples for the `stepper` component, taken from the Mishka source docs
  (`mishka/.../docs/stepper_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base variant"},
      %{id: "default", title: "Default variant"},
      %{id: "gradient", title: "Gradient variant"},
      %{id: "sizes", title: "Sizes"},
      %{id: "vertical", title: "Vertical and horizontal"},
      %{id: "icons", title: "Section icons"},
      %{id: "steps", title: "Step states"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="space-y-10">
      <.stepper id="ex-stepper-base" size="extra_small">
        <.stepper_section step="completed" title="Compelet" />
        <.stepper_section step="canceled" title="Cancled" />
        <.stepper_section step="loading" title="Loading" />
        <.stepper_section step="current" title="Current" />
        <.stepper_section title="Last step" />
      </.stepper>
    </div>
    """
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="space-y-10">
      <.stepper id="ex-stepper-default-1" variant="default" color="silver">
        <.stepper_section step="loading" title="Loading step" description="Register" />
        <.stepper_section step="canceled" title="Current step" description="Verify Email" />
        <.stepper_section step="current" title="Step three" description="Login" />
        <.stepper_section title="Step four" description="Login" />
      </.stepper>

      <.stepper id="ex-stepper-default-2" variant="default" color="danger">
        <.stepper_section step="completed" title="Completed step" description="Register" />
        <.stepper_section step="current" title="Current step" description="Verify Email" />
        <.stepper_section title="Step three" description="Login" />
      </.stepper>

      <.stepper id="ex-stepper-default-3" variant="default" color="success">
        <.stepper_section step="completed" title="Step one" description="Register" />
        <.stepper_section step="current" title="Step two" description="Verify Email" />
        <.stepper_section title="Step three" description="Login" />
      </.stepper>
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <div class="space-y-10">
      <.stepper id="ex-stepper-gradient-1" variant="gradient" color="dawn">
        <.stepper_section step="completed" title="Completed step" description="Register" />
        <.stepper_section step="canceled" title="Current step" description="Verify Email" />
        <.stepper_section step="current" title="Step three" description="Login" />
        <.stepper_section title="Step three" description="Login" />
      </.stepper>

      <.stepper id="ex-stepper-gradient-2" variant="gradient" color="misc">
        <.stepper_section step="completed" title="Completed step" description="Register" />
        <.stepper_section step="current" title="Current step" description="Verify Email" />
        <.stepper_section title="Step three" description="Login" />
      </.stepper>

      <.stepper id="ex-stepper-gradient-3" variant="gradient" color="warning">
        <.stepper_section step="completed" title="Step one" description="Register" />
        <.stepper_section step="current" title="Step two" description="Verify Email" />
        <.stepper_section title="Step three" description="Login" />
      </.stepper>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="space-y-10">
      <.stepper id="ex-stepper-size-1" variant="default" color="warning" size="extra_small">
        <.stepper_section step="completed" title="Completed step" description="Register" />
        <.stepper_section step="current" title="Current step" description="Verify Email" />
        <.stepper_section title="Step three" description="Login" />
      </.stepper>

      <.stepper id="ex-stepper-size-2" variant="default" color="misc" size="extra_large">
        <.stepper_section step="completed" title="Step one" description="Register" />
        <.stepper_section step="current" title="Step two" description="Verify Email" />
        <.stepper_section title="Step three" description="Login" />
      </.stepper>
    </div>
    """
  end

  def example(%{section: "vertical"} = assigns) do
    ~H"""
    <div class="space-y-10">
      <.stepper id="ex-stepper-vertical-1" vertical variant="default" color="natural">
        <.stepper_section title="Step one" vertical />
        <.stepper_section title="Step two" vertical />
        <.stepper_section title="Step three" vertical />
      </.stepper>

      <.stepper id="ex-stepper-horizontal-1" variant="default" color="natural">
        <.stepper_section title="Step one" />
        <.stepper_section title="Step two" />
        <.stepper_section title="Step three" />
      </.stepper>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="space-y-10">
      <.stepper id="ex-stepper-icons" variant="default" color="natural">
        <.stepper_section icon="hero-bell-alert" title="Section one" />
        <.stepper_section icon="hero-building-library" title="Section two" />
        <.stepper_section icon="hero-clock" title="Section three" />
      </.stepper>
    </div>
    """
  end

  def example(%{section: "steps"} = assigns) do
    ~H"""
    <div class="space-y-10">
      <.stepper id="ex-stepper-steps-1" size="extra_small" variant="default" color="misc">
        <.stepper_section title="one" step="completed" />
        <.stepper_section title="two" step="canceled" />
        <.stepper_section title="three" step="current" />
        <.stepper_section title="four" step="loading" />
      </.stepper>

      <.stepper id="ex-stepper-steps-2" size="extra_small" variant="default" color="success">
        <.stepper_section step="completed" title="one" />
        <.stepper_section title="two" step="canceled" />
        <.stepper_section title="three" step="current" />
        <.stepper_section title="four" step="none" />
      </.stepper>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
