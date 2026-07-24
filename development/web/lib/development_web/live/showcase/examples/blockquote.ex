defmodule DevelopmentWeb.Showcase.Examples.Blockquote do
  @moduledoc """
  Docs examples for the `blockquote` component, taken from the Mishka source docs
  (`mishka/.../docs/blockquote_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "caption", title: "Caption slot"},
      %{id: "default", title: "Default variant"},
      %{id: "outline", title: "Outline variant"},
      %{id: "shadow", title: "Shadow variant"},
      %{id: "bordered", title: "Bordered variant"},
      %{id: "gradient", title: "Gradient variant"},
      %{id: "rounded", title: "Rounded"},
      %{id: "sizes", title: "Sizes"},
      %{id: "icons", title: "Icons"}
    ]
  end

  def example(%{section: "caption"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.blockquote variant="default" color="info">
        <p>
          <strong>Mishka Chelekom UI Kit</strong>
          is a versatile, zero-dependency library built for Phoenix LiveView and powered by Tailwind CSS.
        </p>
        <:caption position="center">
          Mishka Chelekom
        </:caption>
      </.blockquote>
      <.blockquote variant="default" color="success">
        <p>
          The Blockquote component supports multiple styles and colors, providing customizable options to suit different design preferences.
        </p>
        <:caption position="right">
          Mishka Chelekom
        </:caption>
      </.blockquote>
    </div>
    """
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.blockquote
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        variant="default"
        color={c}
      >
        Default {String.capitalize(c)}
      </.blockquote>
    </div>
    """
  end

  def example(%{section: "outline"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.blockquote
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        variant="outline"
        color={c}
      >
        Outline {String.capitalize(c)}
      </.blockquote>
    </div>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.blockquote
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        variant="shadow"
        color={c}
      >
        Shadow {String.capitalize(c)}
      </.blockquote>
    </div>
    """
  end

  def example(%{section: "bordered"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.blockquote
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        variant="bordered"
        color={c}
      >
        Bordered {String.capitalize(c)}
      </.blockquote>
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.blockquote
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        variant="gradient"
        color={c}
      >
        Gradient {String.capitalize(c)}
      </.blockquote>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.blockquote hide_icon rounded="extra_small" variant="default" color="misc">
        Rounded extra small
      </.blockquote>
      <.blockquote hide_icon rounded="small" variant="default" color="dawn">
        Rounded small
      </.blockquote>
      <.blockquote hide_icon rounded="medium" variant="default" color="warning">
        Rounded medium
      </.blockquote>
      <.blockquote hide_icon rounded="large">
        Rounded large
      </.blockquote>
      <.blockquote hide_icon rounded="extra_large" variant="default" color="info">
        Rounded extra large
      </.blockquote>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.blockquote size="extra_small">
        Size extra small of blockquote
      </.blockquote>
      <.blockquote size="small" variant="default" color="dawn">
        Size small of blockquote
      </.blockquote>
      <.blockquote size="medium" variant="default" color="misc">
        Size medium of blockquote
      </.blockquote>
      <.blockquote size="large" variant="default" color="primary">
        Size large of blockquote
      </.blockquote>
      <.blockquote size="extra_large" variant="default" color="secondary">
        Size extra large of blockquote
      </.blockquote>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.blockquote hide_icon variant="default" color="silver">
        Hidden icon of blockquote
      </.blockquote>
      <.blockquote icon_class="text-blue-400">
        Custom icon class of blockquote
      </.blockquote>
      <.blockquote icon="hero-star" variant="default" color="dawn">
        Custom icon of blockquote
      </.blockquote>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
