defmodule DevelopmentWeb.Showcase.Examples.TextField do
  @moduledoc """
  Docs examples for the `text_field` component, taken from the Mishka source docs
  (`mishka/.../docs/forms/text_field_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Form Text component"},
      %{id: "floating", title: "Floating labels"},
      %{id: "colors", title: "Colors"},
      %{id: "variants", title: "Variants"},
      %{id: "sizes", title: "Sizes"},
      %{id: "sections", title: "Start and end sections"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="grid md:grid-cols-2 gap-5">
      <.text_field
        id="ex-text_field-1"
        name="sample-1"
        space="small"
        size="small"
        value=""
        label="Email Address"
        placeholder="Enter your email address"
      />
      <.text_field
        id="ex-text_field-2"
        name="sample-2"
        space="small"
        size="small"
        floating="outer"
        value=""
        label="Username"
        placeholder="Choose a username"
        description="Must be between 3-20 characters"
      />
    </div>
    """
  end

  def example(%{section: "floating"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.text_field
        id="ex-text_field-3"
        name="floating-inner"
        value=""
        space="large"
        color="danger"
        variant="default"
        floating="inner"
        label="Text field"
        description="Floating label inner"
        placeholder="Text field"
      />
      <.text_field
        id="ex-text_field-4"
        name="floating-outer"
        value=""
        space="large"
        color="info"
        variant="default"
        floating="outer"
        label="Text field"
        description="Floating label outer"
        placeholder="Text field"
      />
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.text_field
        :for={c <- ~w(natural primary secondary success warning danger info dawn)}
        id={"ex-text_field-color-#{c}"}
        name={"color-#{c}"}
        value=""
        space="small"
        size="small"
        variant="default"
        color={c}
        label={String.capitalize(c)}
        placeholder="Text field"
      />
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.text_field
        :for={v <- ~w(base outline default bordered shadow)}
        id={"ex-text_field-variant-#{v}"}
        name={"variant-#{v}"}
        value=""
        space="small"
        size="small"
        variant={v}
        color="primary"
        label={String.capitalize(v)}
        placeholder="Text field"
      />
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.text_field
        :for={s <- ~w(extra_small small medium large extra_large)}
        id={"ex-text_field-size-#{s}"}
        name={"size-#{s}"}
        value=""
        space="small"
        size={s}
        color="natural"
        variant="default"
        label={s}
        placeholder="Text field"
      />
    </div>
    """
  end

  def example(%{section: "sections"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.text_field
        id="ex-text_field-start"
        name="with-start"
        value=""
        space="small"
        size="small"
        color="natural"
        variant="default"
        label="Search"
        placeholder="Search"
      >
        <:start_section>
          <.icon name="hero-magnifying-glass" class="text-field-icon" />
        </:start_section>
      </.text_field>

      <.text_field
        id="ex-text_field-end"
        name="with-end"
        value=""
        space="small"
        size="small"
        color="natural"
        variant="default"
        label="Website"
        placeholder="Website"
      >
        <:end_section>
          <.icon name="hero-globe-alt" class="text-field-icon" />
        </:end_section>
      </.text_field>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
