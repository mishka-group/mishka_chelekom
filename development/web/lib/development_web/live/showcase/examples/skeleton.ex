defmodule DevelopmentWeb.Showcase.Examples.Skeleton do
  @moduledoc """
  Docs examples for the `skeleton` component, taken from the Mishka source docs
  (`mishka/.../docs/skeleton_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "overview", title: "Overview"},
      %{id: "colors", title: "Colors"},
      %{id: "animated", title: "Animated"},
      %{id: "heights", title: "Heights"},
      %{id: "widths", title: "Widths"},
      %{id: "rounded", title: "Rounded"},
      %{id: "card", title: "Loading card"}
    ]
  end

  def example(%{section: "overview"} = assigns) do
    ~H"""
    <div class="grid sm:grid-cols-2 gap-5 w-full">
      <.card rounded="large" padding="medium" space="small" class="!shadow-xs">
        <.skeleton width="full" rounded="large" height="h-20" animated />
        <.skeleton width="w-3/4" height="h-2" animated />
        <.skeleton width="w-2/3" height="h-2" animated />
        <.skeleton width="w-1/2" height="h-2" animated />
        <.skeleton width="w-1/2" height="h-2" animated />
      </.card>
      <.card rounded="large" padding="medium" space="small" class="!shadow-xs">
        <.skeleton width="w-16" height="h-16" class="mx-auto" rounded="full" />
        <.skeleton width="w-1/3" height="h-3" class="mx-auto" />
        <.skeleton width="w-full" height="h-3" />
        <.skeleton width="w-full" height="h-3" />
      </.card>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 w-full">
      <.skeleton
        :for={
          c <- ~w(natural white primary silver secondary dark success warning danger misc info dawn)
        }
        color={c}
      />
    </div>
    """
  end

  def example(%{section: "animated"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 w-full">
      <.skeleton color="danger" animated />
      <.skeleton color="silver" animated />
    </div>
    """
  end

  def example(%{section: "heights"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 w-full">
      <.skeleton color="info" height="extra_small" />
      <.skeleton color="dawn" height="small" />
      <.skeleton color="misc" height="medium" />
      <.skeleton color="danger" height="large" />
      <.skeleton color="silver" height="extra_large" />
    </div>
    """
  end

  def example(%{section: "widths"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 w-full">
      <.skeleton color="info" width="extra_small" />
      <.skeleton color="dawn" width="small" />
      <.skeleton color="misc" width="medium" />
      <.skeleton color="danger" width="large" />
      <.skeleton color="silver" width="extra_large" />
      <.skeleton color="silver" width="full" />
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 w-full">
      <.skeleton height="large" color="info" rounded="extra_small" />
      <.skeleton height="large" color="dawn" rounded="small" />
      <.skeleton height="large" color="misc" rounded="medium" />
      <.skeleton height="large" color="warning" rounded="large" />
      <.skeleton height="large" color="dawn" rounded="extra_large" />
      <.skeleton height="large" color="misc" rounded="full" />
      <.skeleton height="large" color="danger" rounded="none" />
    </div>
    """
  end

  def example(%{section: "card"} = assigns) do
    ~H"""
    <div class="flex items-center gap-3 p-3 rounded-lg bg-indigo-800 w-full">
      <.skeleton
        width="w-14"
        height="h-14"
        class="shrink-0"
        rounded="full"
        color="silver"
        animated
      />
      <div class="space-y-2 flex-1">
        <.skeleton height="small" color="silver" animated />
        <.skeleton height="small" width="w-32 md:w-96" color="silver" animated />
        <.skeleton height="small" width="w-28 md:w-80" color="silver" animated />
        <.skeleton height="small" width="w-24 md:w-72" color="silver" animated />
      </div>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
