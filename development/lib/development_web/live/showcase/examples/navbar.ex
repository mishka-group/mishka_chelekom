defmodule DevelopmentWeb.Showcase.Examples.Navbar do
  @moduledoc """
  Docs examples for the `navbar` component, taken from the Mishka source docs
  (`mishka/.../docs/navbar_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base Color & Variant"},
      %{id: "default", title: "Default Variant"},
      %{id: "shadow", title: "Shadow Variant"},
      %{id: "bordered", title: "Bordered Variant"},
      %{id: "rounded", title: "Rounded"},
      %{id: "padding", title: "Padding"},
      %{id: "list_icons", title: "List Slot Icons"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.navbar id="ex-navbar-base" max_width="extra_large" name="Mishka" link="#">
        <:list><.link href="#">Mishka</.link></:list>
        <:list><.link href="#">Chelekom</.link></:list>
        <:list><.link href="#">Blog</.link></:list>
        <:list><.link href="#">Docs</.link></:list>
      </.navbar>
    </div>
    """
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.navbar
        :for={c <- ~w(natural primary secondary success warning danger info silver misc dawn)}
        id={"ex-navbar-default-#{c}"}
        max_width="extra_large"
        variant="default"
        color={c}
        name="Mishka"
        link="#"
      >
        <:list><.link href="#">Mishka</.link></:list>
        <:list><.link href="#">Chelekom</.link></:list>
        <:list><.link href="#">Blog</.link></:list>
        <:list><.link href="#">Docs</.link></:list>
      </.navbar>
    </div>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.navbar
        :for={c <- ~w(natural primary secondary success warning danger info)}
        id={"ex-navbar-shadow-#{c}"}
        max_width="extra_large"
        variant="shadow"
        color={c}
        name="Mishka"
        link="#"
      >
        <:list><.link href="#">Mishka</.link></:list>
        <:list><.link href="#">Chelekom</.link></:list>
        <:list><.link href="#">Blog</.link></:list>
        <:list><.link href="#">Docs</.link></:list>
      </.navbar>
    </div>
    """
  end

  def example(%{section: "bordered"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.navbar
        :for={c <- ~w(natural primary secondary success warning danger info)}
        id={"ex-navbar-bordered-#{c}"}
        max_width="extra_large"
        variant="bordered"
        color={c}
        name="Mishka"
        link="#"
      >
        <:list><.link href="#">Mishka</.link></:list>
        <:list><.link href="#">Chelekom</.link></:list>
        <:list><.link href="#">Blog</.link></:list>
        <:list><.link href="#">Docs</.link></:list>
      </.navbar>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.navbar
        :for={r <- ~w(extra_small small medium large extra_large)}
        id={"ex-navbar-rounded-#{r}"}
        max_width="extra_large"
        variant="default"
        color="primary"
        rounded={r}
        name="Mishka"
        link="#"
      >
        <:list><.link href="#">Mishka</.link></:list>
        <:list><.link href="#">Chelekom</.link></:list>
        <:list><.link href="#">Blog</.link></:list>
        <:list><.link href="#">Docs</.link></:list>
      </.navbar>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.navbar
        :for={p <- ~w(extra_small small medium large extra_large)}
        id={"ex-navbar-padding-#{p}"}
        max_width="extra_large"
        variant="default"
        color="success"
        padding={p}
      >
        <:list><.link href="#">Mishka</.link></:list>
        <:list><.link href="#">Chelekom</.link></:list>
        <:list><.link href="#">Blog</.link></:list>
        <:list><.link href="#">Docs</.link></:list>
      </.navbar>
    </div>
    """
  end

  def example(%{section: "list_icons"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.navbar id="ex-navbar-list-icons" max_width="extra_large" relative>
        <:list icon="hero-home" icon_class="size-4 block me-2">
          <.link href="#">Mishka</.link>
        </:list>
        <:list icon="hero-wrench-screwdriver" icon_class="size-4 block me-2">
          <.link href="#">Chelekom</.link>
        </:list>
        <:list icon="hero-book-open" icon_class="size-4 block me-2">
          <.link href="#">Blog</.link>
        </:list>
        <:list icon="hero-document" icon_class="size-4 block ms-2" icon_position="end">
          <.link href="#">Docs</.link>
        </:list>
      </.navbar>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
