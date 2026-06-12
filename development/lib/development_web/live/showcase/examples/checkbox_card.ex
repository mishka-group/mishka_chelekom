defmodule DevelopmentWeb.Showcase.Examples.CheckboxCard do
  @moduledoc """
  Docs examples for the `checkbox_card` component, taken from the Mishka source docs
  (`mishka/.../docs/forms/checkbox_card_live.html.heex`). Section headers, no descriptions.

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
      %{id: "sizes", title: "Sizes"},
      %{id: "cols", title: "Cols"},
      %{id: "show-checkbox", title: "Show checkbox"},
      %{id: "reverse", title: "Reverse"},
      %{id: "icons", title: "Checkbox slot with icons"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.checkbox_card
        name="default-variant"
        cols="two"
        id="ex-checkbox_card-default"
        padding="medium"
        variant="default"
        show_checkbox
        color="silver"
        size="medium"
        class="text-center"
      >
        <:checkbox value="default-variant1" title="8-core CPU" description="32 GB RAM"></:checkbox>
        <:checkbox value="default-variant2" title="6-core CPU" description="24 GB RAM"></:checkbox>
        <:checkbox value="default-variant3" title="4-core CPU" description="16 GB RAM"></:checkbox>
      </.checkbox_card>

      <.checkbox_card
        name="outline-variant"
        cols="two"
        id="ex-checkbox_card-outline"
        padding="medium"
        variant="outline"
        show_checkbox
        color="misc"
        size="medium"
        class="text-center"
      >
        <:checkbox value="outline-variant1" title="8-core CPU" description="32 GB RAM"></:checkbox>
        <:checkbox value="outline-variant2" title="6-core CPU" description="24 GB RAM"></:checkbox>
        <:checkbox value="outline-variant3" title="4-core CPU" description="16 GB RAM"></:checkbox>
      </.checkbox_card>

      <.checkbox_card
        name="shadow-variant"
        cols="two"
        id="ex-checkbox_card-shadow"
        padding="medium"
        variant="shadow"
        show_checkbox
        color="dawn"
        size="medium"
      >
        <:checkbox value="shadow-variant1" title="8-core CPU" description="32 GB RAM"></:checkbox>
        <:checkbox value="shadow-variant2" title="6-core CPU" description="24 GB RAM"></:checkbox>
        <:checkbox value="shadow-variant3" title="4-core CPU" description="16 GB RAM"></:checkbox>
      </.checkbox_card>

      <.checkbox_card
        name="bordered-variant"
        cols="three"
        id="ex-checkbox_card-bordered"
        padding="medium"
        variant="bordered"
        show_checkbox
        color="danger"
        size="medium"
      >
        <:checkbox value="bordered-variant1" title="8-core CPU" description="32 GB RAM"></:checkbox>
        <:checkbox value="bordered-variant2" title="6-core CPU" description="24 GB RAM"></:checkbox>
        <:checkbox value="bordered-variant3" title="4-core CPU" description="16 GB RAM"></:checkbox>
      </.checkbox_card>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.checkbox_card
        :for={c <- ~w(silver misc dawn danger)}
        name={"color-#{c}"}
        id={"ex-checkbox_card-color-#{c}"}
        cols="three"
        padding="medium"
        variant="bordered"
        show_checkbox
        color={c}
        size="medium"
      >
        <:checkbox value={"#{c}-1"} title="Starter" description="Personal blogs"></:checkbox>
        <:checkbox value={"#{c}-2"} title="Pro" description="Small businesses"></:checkbox>
        <:checkbox value={"#{c}-3"} title="Premium" description="Large enterprises"></:checkbox>
      </.checkbox_card>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.checkbox_card
        :for={s <- ~w(extra_small small medium large extra_large)}
        name={"size-#{s}"}
        id={"ex-checkbox_card-size-#{s}"}
        cols="three"
        size={s}
      >
        <:checkbox value={"#{s}-1"} title="Starter Plan" description="Perfect for personal blogs"></:checkbox>
        <:checkbox value={"#{s}-2"} title="Pro Plan" description="Ideal for small businesses"></:checkbox>
        <:checkbox value={"#{s}-3"} title="Premium Plan" description="Best for large enterprises"></:checkbox>
      </.checkbox_card>
    </div>
    """
  end

  def example(%{section: "cols"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.checkbox_card
        :for={c <- ~w(two three four)}
        name={"cols-#{c}"}
        id={"ex-checkbox_card-cols-#{c}"}
        cols={c}
        size="extra_small"
      >
        <:checkbox value={"#{c}-1"} title="Starter Plan"></:checkbox>
        <:checkbox value={"#{c}-2"} title="Pro Plan"></:checkbox>
        <:checkbox value={"#{c}-3"} title="Premium Plan"></:checkbox>
        <:checkbox value={"#{c}-4"} title="Business Plan"></:checkbox>
      </.checkbox_card>
    </div>
    """
  end

  def example(%{section: "show-checkbox"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.checkbox_card
        name="show-checkbox-card"
        cols="three"
        id="ex-checkbox_card-show-checkbox"
        cols_gap="extra_small"
        size="extra_small"
        show_checkbox
      >
        <:checkbox value="show-checkbox1" title="Starter Plan"></:checkbox>
        <:checkbox value="show-checkbox2" title="Pro Plan"></:checkbox>
        <:checkbox value="show-checkbox3" title="Premium Plan"></:checkbox>
      </.checkbox_card>
    </div>
    """
  end

  def example(%{section: "reverse"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.checkbox_card
        name="checkbox-card-reverse"
        cols="three"
        id="ex-checkbox_card-reverse"
        size="extra_small"
        show_checkbox
        reverse
      >
        <:checkbox value="reverse1" title="Starter Plan"></:checkbox>
        <:checkbox value="reverse2" title="Pro Plan"></:checkbox>
        <:checkbox value="reverse3" title="Premium Plan"></:checkbox>
      </.checkbox_card>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.checkbox_card
        name="checkbox-card-checkbox-slot"
        cols="two"
        id="ex-checkbox_card-icons"
        size="small"
        class="text-center"
      >
        <:checkbox value="checkbox-slot1" checked icon="hero-cube" title="Package Storage"></:checkbox>
        <:checkbox
          value="checkbox-slot2"
          icon_class="size-4"
          icon="hero-building-office"
          title="Office Space"
        ></:checkbox>
        <:checkbox value="checkbox-slot3" icon="hero-globe-alt" title="Global Network"></:checkbox>
        <:checkbox
          value="checkbox-slot4"
          icon="hero-adjustments-horizontal"
          title="Custom Settings"
        ></:checkbox>
        <:checkbox value="checkbox-slot6" icon="hero-code-bracket" title="Developer Tools"></:checkbox>
        <:checkbox
          value="checkbox-slot5"
          icon="hero-cpu-chip"
          description="Access development tools and APIs for building applications"
        ></:checkbox>
      </.checkbox_card>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
