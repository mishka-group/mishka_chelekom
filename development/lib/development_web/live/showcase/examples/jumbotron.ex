defmodule DevelopmentWeb.Showcase.Examples.Jumbotron do
  @moduledoc """
  Docs examples for the `jumbotron` component, taken from the Mishka source docs
  (`mishka/.../docs/jumbotron_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base color & Variant"},
      %{id: "variants", title: "Variants"},
      %{id: "gradient", title: "Gradient Variant"},
      %{id: "space", title: "Space prop"},
      %{id: "padding", title: "Padding prop"},
      %{id: "font-weight", title: "Font weight prop"},
      %{id: "border", title: "Border size & position"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <.jumbotron class="text-center" padding="small" id="ex-jumbotron-base">
      <h1 class="text-lg font-bold">Welcome to Mishka Chelekom</h1>
      <p class="text-sm mt-2">
        Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
      </p>
      <div class="flex justify-center items-center my-8">
        <.button variant="default" color="silver" size="small">Get Started</.button>
      </div>
    </.jumbotron>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.jumbotron class="text-center" padding="small" id="ex-jumbotron-default" variant="default" color="dawn">
        <h1 class="text-lg font-bold">Default Variant</h1>
        <p class="text-sm mt-2">
          Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
        </p>
        <div class="flex justify-center items-center my-8">
          <.button variant="default" color="danger" size="small">Get Started</.button>
        </div>
      </.jumbotron>

      <.jumbotron class="text-center" padding="small" id="ex-jumbotron-outline" variant="default" color="silver">
        <h1 class="text-lg font-bold">Outline Variant</h1>
        <p class="text-sm mt-2">
          Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
        </p>
        <div class="flex justify-center items-center my-8">
          <.button variant="default" color="primary" size="small">Get Started</.button>
        </div>
      </.jumbotron>

      <.jumbotron class="text-center" padding="small" id="ex-jumbotron-shadow" variant="shadow" color="misc">
        <h1 class="text-lg font-bold">Shadow Variant</h1>
        <p class="text-sm mt-2">
          Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
        </p>
        <div class="flex justify-center items-center my-8">
          <.button variant="default" color="primary" size="small">Get Started</.button>
        </div>
      </.jumbotron>

      <.jumbotron
        class="text-center"
        padding="small"
        id="ex-jumbotron-bordered"
        variant="bordered"
        border_position="vertical"
        border_size="medium"
        color="danger"
      >
        <h1 class="text-lg font-bold">Bordered Variant</h1>
        <p class="text-sm mt-2">
          Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
        </p>
        <div class="flex justify-center items-center my-8">
          <.button variant="default" color="primary" size="small">Get Started</.button>
        </div>
      </.jumbotron>

      <.jumbotron class="text-center" padding="small" id="ex-jumbotron-transparent" variant="transparent" color="info">
        <h1 class="text-lg font-bold">Transparent Variant</h1>
        <p class="text-sm mt-2">
          Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
        </p>
        <div class="flex justify-center items-center my-8">
          <.button variant="default" color="danger" size="small">Get Started</.button>
        </div>
      </.jumbotron>
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <.jumbotron class="text-center" padding="small" id="ex-jumbotron-gradient" variant="gradient" color="dawn">
      <h1 class="text-lg font-bold">Welcome to Mishka Chelekom</h1>
      <p class="text-sm mt-2">
        Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
      </p>
      <div class="flex justify-center items-center my-8">
        <.button variant="default" color="primary" size="small">Get Started</.button>
      </div>
    </.jumbotron>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <.jumbotron
      class="text-center"
      padding="large"
      space="extra_large"
      id="ex-jumbotron-space"
      color="warning"
      variant="default"
    >
      <h1 class="text-lg font-bold">Welcome to Mishka Chelekom</h1>
      <p class="text-sm mt-2">
        Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
      </p>
      <div class="flex justify-center items-center my-8">
        <.button variant="default" color="danger" size="small">Get Started</.button>
      </div>
    </.jumbotron>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <.jumbotron
      class="text-center"
      padding="extra_large"
      id="ex-jumbotron-padding"
      color="success"
      variant="default"
    >
      <h1 class="text-lg font-bold">Welcome to Mishka Chelekom</h1>
      <p class="text-sm mt-2">
        Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
      </p>
      <div class="flex justify-center items-center my-8">
        <.button variant="default" color="silver" size="small">Get Started</.button>
      </div>
    </.jumbotron>
    """
  end

  def example(%{section: "font-weight"} = assigns) do
    ~H"""
    <.jumbotron
      class="text-center"
      padding="extra_large"
      id="ex-jumbotron-font-weight"
      font_weight="font-bold"
      color="secondary"
      variant="default"
    >
      <h1 class="text-lg font-bold">Welcome to Mishka Chelekom</h1>
      <p class="text-sm mt-2">
        Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
      </p>
      <div class="flex justify-center items-center my-8">
        <.button variant="default" color="misc" size="small">Get Started</.button>
      </div>
    </.jumbotron>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.jumbotron
        class="text-center"
        padding="extra_large"
        id="ex-jumbotron-border-size"
        border_size="small"
        color="dawn"
        variant="default"
      >
        <h1 class="text-lg font-bold">Border size</h1>
        <p class="text-sm mt-2">
          Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
        </p>
        <div class="flex justify-center items-center my-8">
          <.button variant="default" color="success" size="small">Get Started</.button>
        </div>
      </.jumbotron>

      <.jumbotron
        class="text-center"
        padding="extra_large"
        id="ex-jumbotron-border-position"
        border_size="large"
        border_position="vertical"
        color="danger"
        variant="default"
      >
        <h1 class="text-lg font-bold">Border position</h1>
        <p class="text-sm mt-2">
          Your all-in-one solution for Phoenix LiveView components, tailored to your needs.
        </p>
        <div class="flex justify-center items-center my-8">
          <.button variant="default" color="misc" size="small">Get Started</.button>
        </div>
      </.jumbotron>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
