defmodule DevelopmentWeb.Showcase.Examples.Card do
  @moduledoc """
  Docs examples for the `card` component, taken from the Mishka source docs
  (`mishka/.../docs/card_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "variants", title: "Variants"},
      %{id: "colors", title: "Colors"},
      %{id: "rounded", title: "Rounded"},
      %{id: "border", title: "Border"},
      %{id: "space", title: "Space"},
      %{id: "padding", title: "Padding"},
      %{id: "title", title: "Card title"},
      %{id: "footer", title: "Card footer"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="grid sm:grid-cols-2 gap-3">
      <.card id="ex-card-default" color="natural" variant="default" padding="small">
        <.card_content>
          Mishka Chelekom is a comprehensive UI kit designed specifically for Phoenix and Phoenix LiveView applications.
        </.card_content>
      </.card>
      <.card id="ex-card-outline" variant="outline" color="silver" padding="small">
        <.card_content>
          Mishka Chelekom ensures that all components are lightweight, responsive, and accessible.
        </.card_content>
      </.card>
      <.card id="ex-card-shadow" variant="shadow" color="secondary" padding="small">
        <.card_content>
          Mishka Chelekom is a comprehensive UI kit designed specifically for Phoenix and Phoenix LiveView applications.
        </.card_content>
      </.card>
      <.card id="ex-card-bordered" variant="bordered" color="info" padding="small">
        <.card_content>
          Mishka Chelekom ensures that all components are lightweight, responsive, and accessible.
        </.card_content>
      </.card>
      <.card id="ex-card-transparent" variant="transparent" color="danger" padding="small">
        <.card_content>
          Mishka Chelekom is a comprehensive UI kit designed specifically for Phoenix and Phoenix LiveView applications.
        </.card_content>
      </.card>
      <.card id="ex-card-gradient" variant="gradient" color="success" padding="small">
        <.card_content>
          Mishka Chelekom ensures that all components are lightweight, responsive, and accessible.
        </.card_content>
      </.card>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="grid sm:grid-cols-2 gap-3">
      <.card
        :for={c <- ~w(natural primary secondary success warning danger info misc dawn silver)}
        id={"ex-card-color-#{c}"}
        color={c}
        variant="default"
        padding="small"
      >
        <.card_content>
          {String.capitalize(c)} color card from Mishka Chelekom.
        </.card_content>
      </.card>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-3 [&>*]:flex-1">
      <.card
        id="ex-card-rounded-xs"
        padding="small"
        variant="default"
        color="dawn"
        rounded="extra_small"
      >
        <.card_title title="Extra small radius" />
        <.card_content>
          Mishka Chelekom is a comprehensive UI kit designed specifically for Phoenix and Phoenix LiveView applications.
        </.card_content>
      </.card>
      <.card
        id="ex-card-rounded-xl"
        color="primary"
        variant="default"
        rounded="extra_large"
        padding="small"
      >
        <.card_title title="Extra large radius" />
        <.card_content>
          Mishka Chelekom ensures that all components are lightweight, responsive, and accessible.
        </.card_content>
      </.card>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-3 [&>*]:flex-1">
      <.card
        id="ex-card-border-xs"
        padding="small"
        color="dawn"
        variant="default"
        border="extra_small"
      >
        <.card_title title="Extra small border" />
        <.card_content>
          Mishka Chelekom is a comprehensive UI kit designed specifically for Phoenix and Phoenix LiveView applications.
        </.card_content>
      </.card>
      <.card
        id="ex-card-border-xl"
        color="danger"
        variant="default"
        border="extra_large"
        padding="small"
      >
        <.card_title title="Extra large border" />
        <.card_content>
          Mishka Chelekom ensures that all components are lightweight, responsive, and accessible.
        </.card_content>
      </.card>
    </div>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-3 [&>*]:flex-1">
      <.card
        id="ex-card-space-xs"
        padding="small"
        color="dawn"
        variant="default"
        space="extra_small"
      >
        <.card_title title="Extra small space within card" />
        <.card_content>
          Mishka Chelekom is a comprehensive UI kit designed specifically for Phoenix and Phoenix LiveView applications.
        </.card_content>
      </.card>
      <.card
        id="ex-card-space-xl"
        color="primary"
        variant="default"
        space="extra_large"
        padding="small"
      >
        <.card_title title="Extra large space within card" />
        <.card_content>
          Mishka Chelekom ensures that all components are lightweight, responsive, and accessible.
        </.card_content>
      </.card>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-3 [&>*]:flex-1">
      <.card id="ex-card-padding-xs" variant="default" color="dawn" padding="extra_small">
        <.card_title title="Extra small padding within card" />
        <.card_content>
          Mishka Chelekom is a comprehensive UI kit designed specifically for Phoenix and Phoenix LiveView applications.
        </.card_content>
      </.card>
      <.card id="ex-card-padding-xl" variant="default" color="primary" padding="extra_large">
        <.card_title title="Extra large padding within card" />
        <.card_content>
          Mishka Chelekom ensures that all components are lightweight, responsive, and accessible.
        </.card_content>
      </.card>
    </div>
    """
  end

  def example(%{section: "title"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.card id="ex-card-title-start" padding="small" variant="default" color="dawn" class="w-full">
        <.card_title title="Mishka Chelekom card title" icon="hero-home" position="start" />
      </.card>
      <.card id="ex-card-title-center" padding="small" variant="default" color="misc" class="w-full">
        <.card_title title="Mishka Chelekom card title" icon="hero-home" position="center" />
      </.card>
      <.card id="ex-card-title-end" padding="small" variant="default" color="silver" class="w-full">
        <.card_title title="Mishka Chelekom card title" icon="hero-home" position="end" />
      </.card>
    </div>
    """
  end

  def example(%{section: "footer"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.card id="ex-card-footer-1" space="small" rounded="large">
        <.card_title padding="small" position="between">
          <div>Base Color Variant</div>
          <.button
            size="extra_small"
            variant="transparent"
            color="silver"
            icon="hero-ellipsis-horizontal"
          />
        </.card_title>
        <.card_content space="large">
          <p class="p-2 text-sm">
            The Mishka card component is ideal for displaying content in a clean, organized layout.
          </p>
        </.card_content>
        <.card_footer padding="small">
          <.button full_width size="small">See more</.button>
        </.card_footer>
      </.card>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
