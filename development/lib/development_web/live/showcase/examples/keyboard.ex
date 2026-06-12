defmodule DevelopmentWeb.Showcase.Examples.Keyboard do
  @moduledoc """
  Docs examples for the `keyboard` component, taken from the Mishka source docs
  (`mishka/.../docs/keyboard_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base Variant"},
      %{id: "colors", title: "Colors"},
      %{id: "outline", title: "Outline Variant"},
      %{id: "shadow", title: "Shadow Variant"},
      %{id: "bordered", title: "Bordered Variant"},
      %{id: "transparent", title: "Transparent Variant"},
      %{id: "gradient", title: "Gradient Variant"},
      %{id: "rounded", title: "Rounded"},
      %{id: "sizes", title: "Sizes"},
      %{id: "font_weight", title: "Font Weight"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="flex items-center gap-4">
      <.keyboard id="ex-keyboard-base">Ctrl + C</.keyboard>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard
        :for={c <- ~w(natural white dark info success warning danger silver misc dawn primary secondary)}
        id={"ex-keyboard-color-#{c}"}
        variant="default"
        color={c}
      >
        Ctrl + C
      </.keyboard>
    </div>
    """
  end

  def example(%{section: "outline"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        id={"ex-keyboard-outline-#{c}"}
        variant="outline"
        color={c}
      >
        Ctrl + K
      </.keyboard>
    </div>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        id={"ex-keyboard-shadow-#{c}"}
        variant="shadow"
        color={c}
      >
        Ctrl + V
      </.keyboard>
    </div>
    """
  end

  def example(%{section: "bordered"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard
        :for={c <- ~w(natural white dark info success warning danger silver misc dawn primary secondary)}
        id={"ex-keyboard-bordered-#{c}"}
        variant="bordered"
        color={c}
      >
        Ctrl + A
      </.keyboard>
    </div>
    """
  end

  def example(%{section: "transparent"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        id={"ex-keyboard-transparent-#{c}"}
        variant="transparent"
        color={c}
      >
        Ctrl + D
      </.keyboard>
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard
        :for={c <- ~w(natural info success warning danger silver misc dawn primary secondary)}
        id={"ex-keyboard-gradient-#{c}"}
        variant="gradient"
        color={c}
      >
        Ctrl + D
      </.keyboard>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard
        :for={r <- ~w(extra_small small medium large extra_large full none)}
        id={"ex-keyboard-rounded-#{r}"}
        rounded={r}
        variant="default"
        color="info"
      >
        Ctrl + K
      </.keyboard>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard
        :for={s <- ~w(extra_small small medium large extra_large)}
        id={"ex-keyboard-size-#{s}"}
        size={s}
        variant="default"
        color="danger"
      >
        Ctrl + C
      </.keyboard>
    </div>
    """
  end

  def example(%{section: "font_weight"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.keyboard id="ex-keyboard-weight-bold" variant="default" color="success" font_weight="font-bold">
        Bold
      </.keyboard>

      <.keyboard
        id="ex-keyboard-weight-semibold"
        variant="default"
        color="misc"
        font_weight="font-semibold"
      >
        Semibold
      </.keyboard>

      <.keyboard
        id="ex-keyboard-weight-medium"
        variant="default"
        color="warning"
        font_weight="font-medium"
      >
        Medium
      </.keyboard>

      <.keyboard
        id="ex-keyboard-weight-light"
        variant="default"
        color="danger"
        font_weight="font-light"
      >
        Light
      </.keyboard>

      <.keyboard
        id="ex-keyboard-weight-black"
        variant="default"
        color="primary"
        font_weight="font-black"
      >
        Black
      </.keyboard>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
