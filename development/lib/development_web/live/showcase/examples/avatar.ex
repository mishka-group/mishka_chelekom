defmodule DevelopmentWeb.Showcase.Examples.Avatar do
  @moduledoc """
  Docs examples for the `avatar` component, taken from the Mishka source docs
  (`mishka/.../docs/avatar_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "colors", title: "Avatar colors"},
      %{id: "icons", title: "How to display icons"},
      %{id: "text", title: "How to display text"},
      %{id: "sizes", title: "Size prop"},
      %{id: "border", title: "Border prop"},
      %{id: "rounded", title: "Rounded prop"},
      %{id: "shadow", title: "Shadow prop"},
      %{id: "indicator", title: "Display indicator"},
      %{id: "group", title: "Avatar group"}
    ]
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.avatar id="ex-avatar-c1" color="base"><:icon name="hero-star" /></.avatar>
      <.avatar id="ex-avatar-c2" color="natural"><:icon name="hero-star" /></.avatar>
      <.avatar id="ex-avatar-c3" color="dawn" border="extra_small">MD</.avatar>
      <.avatar id="ex-avatar-c4" color="misc">Fh</.avatar>
      <.avatar id="ex-avatar-c5" color="primary">GT</.avatar>
      <.avatar id="ex-avatar-c6" color="white" border="extra_small">Wh</.avatar>
      <.avatar id="ex-avatar-c7" color="dark">DA</.avatar>
      <.avatar id="ex-avatar-c8" color="info">GT</.avatar>
      <.avatar id="ex-avatar-c9" color="secondary" border="extra_small">SE</.avatar>
      <.avatar id="ex-avatar-c10" color="warning" border="extra_small">MD</.avatar>
      <.avatar id="ex-avatar-c11" color="danger">LG</.avatar>
      <.avatar id="ex-avatar-c12" color="success">JL</.avatar>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.avatar id="ex-avatar-i1"><:icon name="hero-users" /></.avatar>
      <.avatar id="ex-avatar-i2" color="primary"><:icon name="hero-user" /></.avatar>
      <.avatar id="ex-avatar-i3" color="success"><:icon name="hero-photo" /></.avatar>
      <.avatar id="ex-avatar-i4" color="danger"><:icon name="hero-heart" /></.avatar>
    </div>
    """
  end

  def example(%{section: "text"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.avatar id="ex-avatar-t1">TG</.avatar>
      <.avatar id="ex-avatar-t2">MD</.avatar>
      <.avatar id="ex-avatar-t3">SB</.avatar>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.avatar id="ex-avatar-s1" size="extra_small" color="silver">TG</.avatar>
      <.avatar id="ex-avatar-s2" size="small" color="primary">SM</.avatar>
      <.avatar id="ex-avatar-s3" size="medium" color="info" rounded="full">MD</.avatar>
      <.avatar id="ex-avatar-s4" size="large"><:icon name="hero-users" color="dawn" /></.avatar>
      <.avatar id="ex-avatar-s5" size="extra_large"><:icon name="hero-star" color="misc" /></.avatar>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.avatar id="ex-avatar-b1" size="extra_large" border="extra_small" color="primary">TG</.avatar>
      <.avatar id="ex-avatar-b2" size="extra_large" border="small" color="warning">SM</.avatar>
      <.avatar id="ex-avatar-b3" size="extra_large" border="medium" color="secondary">JJ</.avatar>
      <.avatar id="ex-avatar-b4" size="extra_large" border="large" color="success">
        <:icon name="hero-photo" />
      </.avatar>
      <.avatar id="ex-avatar-b5" size="extra_large" border="extra_large" color="danger">
        <:icon name="hero-heart" />
      </.avatar>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      <.avatar id="ex-avatar-r1" size="extra_large" rounded="extra_small">TG</.avatar>
      <.avatar id="ex-avatar-r2" size="extra_large" rounded="small" color="warning">SM</.avatar>
      <.avatar id="ex-avatar-r3" size="extra_large" rounded="medium" color="secondary">JJ</.avatar>
      <.avatar id="ex-avatar-r4" size="extra_large" rounded="large" color="success">
        <:icon name="hero-photo" />
      </.avatar>
      <.avatar id="ex-avatar-r5" size="extra_large" rounded="none" color="danger">
        <:icon name="hero-heart" />
      </.avatar>
      <.avatar id="ex-avatar-r6" size="extra_large" rounded="full" color="misc">
        <:icon name="hero-bell-alert" />
      </.avatar>
    </div>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.avatar id="ex-avatar-sh1" size="extra_large" shadow="extra_small">TG</.avatar>
      <.avatar id="ex-avatar-sh2" size="extra_large" shadow="small" color="warning">SM</.avatar>
      <.avatar id="ex-avatar-sh3" size="extra_large" shadow="medium" color="secondary">JJ</.avatar>
      <.avatar id="ex-avatar-sh4" size="extra_large" shadow="large" color="success">
        <:icon name="hero-photo" />
      </.avatar>
      <.avatar id="ex-avatar-sh5" size="extra_large" shadow="extra_large" color="warning">
        <:icon name="hero-heart" />
      </.avatar>
    </div>
    """
  end

  def example(%{section: "indicator"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4 px-2">
      <.avatar id="ex-avatar-d1" size="large" color="primary" border="small">
        <:icon name="hero-users" />
        <.indicator size="small" color="danger" top_left />
      </.avatar>
      <.avatar id="ex-avatar-d2" size="large" color="silver" border="small">
        TG <.indicator size="small" color="misc" bottom_left />
      </.avatar>
      <.avatar id="ex-avatar-d3" size="large" color="success" border="small">
        <:icon name="hero-heart" />
        <.indicator size="small" color="success" top_right pinging />
      </.avatar>
    </div>
    """
  end

  def example(%{section: "group"} = assigns) do
    ~H"""
    <.avatar_group id="ex-avatar-group" space="extra_small">
      <.avatar id="ex-avatar-g1" size="large" border="extra_small" color="dawn" rounded="full">A</.avatar>
      <.avatar id="ex-avatar-g2" size="large" border="extra_small" color="info" rounded="full">B</.avatar>
      <.avatar id="ex-avatar-g3" size="large" border="extra_small" color="base" rounded="full">C</.avatar>
      <.avatar id="ex-avatar-g4" size="large" border="extra_small" color="misc" rounded="full">D</.avatar>
      <.avatar id="ex-avatar-g5" size="large" color="secondary" rounded="full" border="small">+20</.avatar>
    </.avatar_group>
    """
  end

  def example(assigns), do: ~H""
end
