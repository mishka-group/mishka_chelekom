defmodule DevelopmentWeb.Showcase.Examples.Alert do
  @moduledoc """
  Docs examples for the `alert` component, taken from the Mishka source docs
  (`mishka/.../docs/alert_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "default", title: "Default Variant"},
      %{id: "outline", title: "Outline Variant"},
      %{id: "shadow", title: "Shadow Variant"},
      %{id: "bordered", title: "Bordered Variant"},
      %{id: "gradient", title: "Gradient Variant"},
      %{id: "width", title: "Width"},
      %{id: "rounded", title: "Rounded"},
      %{id: "icon", title: "Icon and title"}
    ]
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.alert id="ex-alert-default-natural" variant="default" kind={:natural}>Natural</.alert>
      <.alert id="ex-alert-default-info" variant="default" kind={:info}>Info</.alert>
      <.alert id="ex-alert-default-success" variant="default" kind={:success}>Success</.alert>
      <.alert id="ex-alert-default-warning" variant="default" kind={:warning}>Warning</.alert>
      <.alert id="ex-alert-default-danger" variant="default" kind={:danger}>Danger</.alert>
      <.alert id="ex-alert-default-primary" variant="default" kind={:primary}>Primary</.alert>
      <.alert id="ex-alert-default-secondary" variant="default" kind={:secondary}>Secondary</.alert>
      <.alert id="ex-alert-default-misc" variant="default" kind={:misc}>Misc</.alert>
      <.alert id="ex-alert-default-dawn" variant="default" kind={:dawn}>Dawn</.alert>
    </div>
    """
  end

  def example(%{section: "outline"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.alert id="ex-alert-outline-natural" variant="outline" kind={:natural}>Natural</.alert>
      <.alert id="ex-alert-outline-info" variant="outline" kind={:info}>Info</.alert>
      <.alert id="ex-alert-outline-success" variant="outline" kind={:success}>Success</.alert>
      <.alert id="ex-alert-outline-warning" variant="outline" kind={:warning}>Warning</.alert>
      <.alert id="ex-alert-outline-danger" variant="outline" kind={:danger}>Danger</.alert>
      <.alert id="ex-alert-outline-primary" variant="outline" kind={:primary}>Primary</.alert>
      <.alert id="ex-alert-outline-secondary" variant="outline" kind={:secondary}>Secondary</.alert>
      <.alert id="ex-alert-outline-misc" variant="outline" kind={:misc}>Misc</.alert>
      <.alert id="ex-alert-outline-dawn" variant="outline" kind={:dawn}>Dawn</.alert>
    </div>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.alert id="ex-alert-shadow-natural" variant="shadow" kind={:natural}>Natural</.alert>
      <.alert id="ex-alert-shadow-info" variant="shadow" kind={:info}>Info</.alert>
      <.alert id="ex-alert-shadow-success" variant="shadow" kind={:success}>Success</.alert>
      <.alert id="ex-alert-shadow-warning" variant="shadow" kind={:warning}>Warning</.alert>
      <.alert id="ex-alert-shadow-danger" variant="shadow" kind={:danger}>Danger</.alert>
      <.alert id="ex-alert-shadow-primary" variant="shadow" kind={:primary}>Primary</.alert>
      <.alert id="ex-alert-shadow-secondary" variant="shadow" kind={:secondary}>Secondary</.alert>
      <.alert id="ex-alert-shadow-misc" variant="shadow" kind={:misc}>Misc</.alert>
      <.alert id="ex-alert-shadow-dawn" variant="shadow" kind={:dawn}>Dawn</.alert>
    </div>
    """
  end

  def example(%{section: "bordered"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.alert id="ex-alert-bordered-natural" variant="bordered" kind={:natural}>Natural</.alert>
      <.alert id="ex-alert-bordered-info" variant="bordered" kind={:info}>Info</.alert>
      <.alert id="ex-alert-bordered-success" variant="bordered" kind={:success}>Success</.alert>
      <.alert id="ex-alert-bordered-warning" variant="bordered" kind={:warning}>Warning</.alert>
      <.alert id="ex-alert-bordered-danger" variant="bordered" kind={:danger}>Danger</.alert>
      <.alert id="ex-alert-bordered-primary" variant="bordered" kind={:primary}>Primary</.alert>
      <.alert id="ex-alert-bordered-secondary" variant="bordered" kind={:secondary}>Secondary</.alert>
      <.alert id="ex-alert-bordered-misc" variant="bordered" kind={:misc}>Misc</.alert>
      <.alert id="ex-alert-bordered-dawn" variant="bordered" kind={:dawn}>Dawn</.alert>
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.alert id="ex-alert-gradient-natural" variant="gradient" kind={:natural}>Natural</.alert>
      <.alert id="ex-alert-gradient-info" variant="gradient" kind={:info}>Info</.alert>
      <.alert id="ex-alert-gradient-success" variant="gradient" kind={:success}>Success</.alert>
      <.alert id="ex-alert-gradient-warning" variant="gradient" kind={:warning}>Warning</.alert>
      <.alert id="ex-alert-gradient-danger" variant="gradient" kind={:danger}>Danger</.alert>
      <.alert id="ex-alert-gradient-primary" variant="gradient" kind={:primary}>Primary</.alert>
      <.alert id="ex-alert-gradient-secondary" variant="gradient" kind={:secondary}>Secondary</.alert>
      <.alert id="ex-alert-gradient-misc" variant="gradient" kind={:misc}>Misc</.alert>
      <.alert id="ex-alert-gradient-dawn" variant="gradient" kind={:dawn}>Dawn</.alert>
    </div>
    """
  end

  def example(%{section: "width"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.alert id="ex-alert-width-xs" kind={:primary} width="extra_small" variant="default">
        Extra small
      </.alert>
      <.alert id="ex-alert-width-sm" kind={:warning} width="small" variant="default">small</.alert>
      <.alert id="ex-alert-width-md" kind={:success} width="medium" variant="default">Medium</.alert>
      <.alert id="ex-alert-width-lg" kind={:natural} width="large" variant="default">Large</.alert>
      <.alert id="ex-alert-width-xl" kind={:misc} width="extra_large" variant="default">
        Extra large
      </.alert>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.alert id="ex-alert-rounded-xs" kind={:natural} rounded="extra_small">Extra small</.alert>
      <.alert id="ex-alert-rounded-sm" kind={:danger} variant="default" rounded="small">small</.alert>
      <.alert id="ex-alert-rounded-md" kind={:silver} variant="default" rounded="medium">
        Medium
      </.alert>
      <.alert id="ex-alert-rounded-lg" kind={:dawn} variant="default" rounded="large">Large</.alert>
      <.alert id="ex-alert-rounded-xl" kind={:misc} variant="default" rounded="extra_large">
        Extra large
      </.alert>
    </div>
    """
  end

  def example(%{section: "icon"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.alert
        id="ex-alert-icon-misc"
        kind={:misc}
        title="This is title of the alert component"
        icon="hero-home"
        variant="default"
      />
      <.alert
        id="ex-alert-icon-warning"
        kind={:warning}
        variant="bordered"
        icon="hero-shield-exclamation"
      >
        Warning alert! Change a few things up and try submitting again.
      </.alert>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
