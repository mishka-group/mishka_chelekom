defmodule DevelopmentWeb.Showcase.Examples.RadioCard do
  @moduledoc """
  Docs examples for the `radio_card` component, taken from the Mishka source docs
  (`mishka/.../docs/forms/radio_card_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base variant"},
      %{id: "variants", title: "Variants"},
      %{id: "label", title: "Label prop"},
      %{id: "description", title: "Description prop"},
      %{id: "cols", title: "Cols prop"},
      %{id: "show_radio", title: "Show radio prop"},
      %{id: "reverse", title: "Reverse prop"},
      %{id: "radio_slot", title: "Radio slot with icons"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <.radio_card
      name="ex-radio_card-base"
      id="ex-radio_card-base"
      cols="two"
      padding="medium"
      size="medium"
      class="text-center"
    >
      <:radio value="base1" title="8-core CPU" description="32 GB RAM"></:radio>
      <:radio value="base2" title="6-core CPU" description="24 GB RAM"></:radio>
      <:radio value="base3" title="4-core CPU" description="16 GB RAM"></:radio>
    </.radio_card>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.radio_card
        name="ex-radio_card-default"
        id="ex-radio_card-default"
        cols="two"
        padding="medium"
        variant="default"
        show_radio
        color="silver"
        size="medium"
        class="text-center"
      >
        <:radio value="default-variant1" title="8-core CPU" description="32 GB RAM"></:radio>
        <:radio value="default-variant2" title="6-core CPU" description="24 GB RAM"></:radio>
        <:radio value="default-variant3" title="4-core CPU" description="16 GB RAM"></:radio>
      </.radio_card>

      <.radio_card
        name="ex-radio_card-outline"
        id="ex-radio_card-outline"
        cols="two"
        padding="medium"
        variant="outline"
        show_radio
        color="dawn"
        size="medium"
        class="text-center"
      >
        <:radio value="outline-variant1" title="8-core CPU" description="32 GB RAM"></:radio>
        <:radio value="outline-variant2" title="6-core CPU" description="24 GB RAM"></:radio>
        <:radio value="outline-variant3" title="4-core CPU" description="16 GB RAM"></:radio>
      </.radio_card>

      <.radio_card
        name="ex-radio_card-shadow"
        id="ex-radio_card-shadow"
        cols="two"
        padding="medium"
        variant="shadow"
        show_radio
        color="dawn"
        size="medium"
      >
        <:radio value="shadow-variant1" title="8-core CPU" description="32 GB RAM"></:radio>
        <:radio value="shadow-variant2" title="6-core CPU" description="24 GB RAM"></:radio>
        <:radio value="shadow-variant3" title="4-core CPU" description="16 GB RAM"></:radio>
      </.radio_card>

      <.radio_card
        name="ex-radio_card-bordered"
        id="ex-radio_card-bordered"
        cols="three"
        padding="medium"
        variant="bordered"
        show_radio
        color="danger"
        size="medium"
      >
        <:radio value="bordered-variant1" title="8-core CPU" description="32 GB RAM"></:radio>
        <:radio value="bordered-variant2" title="6-core CPU" description="24 GB RAM"></:radio>
        <:radio value="bordered-variant3" title="4-core CPU" description="16 GB RAM"></:radio>
      </.radio_card>
    </div>
    """
  end

  def example(%{section: "label"} = assigns) do
    ~H"""
    <.radio_card
      name="ex-radio_card-label"
      cols="three"
      id="ex-radio_card-label"
      label="Select Your Hosting Plan"
    >
      <:radio value="clabel1" title="Starter Plan" description="Perfect for personal blogs"></:radio>
      <:radio value="clabel2" title="Pro Plan" description="Ideal for small businesses"></:radio>
      <:radio value="clabel3" title="Premium Plan" description="Best for large enterprises"></:radio>
    </.radio_card>
    """
  end

  def example(%{section: "description"} = assigns) do
    ~H"""
    <.radio_card
      name="ex-radio_card-description"
      cols="three"
      id="ex-radio_card-description"
      description="Choose your hosting plan based on your website's needs and expected traffic volume"
    >
      <:radio value="cdescription1" title="Starter Plan" description="Perfect for personal blogs">
      </:radio>
      <:radio value="cdescription2" title="Pro Plan" description="Ideal for small businesses">
      </:radio>
      <:radio value="cdescription3" title="Premium Plan" description="Best for large enterprises">
      </:radio>
    </.radio_card>
    """
  end

  def example(%{section: "cols"} = assigns) do
    ~H"""
    <.radio_card name="ex-radio_card-cols" cols="four" id="ex-radio_card-cols" size="extra_small">
      <:radio value="cols1" title="Starter Plan"></:radio>
      <:radio value="cols2" title="Pro Plan"></:radio>
      <:radio value="cols3" title="Premium Plan"></:radio>
    </.radio_card>
    """
  end

  def example(%{section: "show_radio"} = assigns) do
    ~H"""
    <.radio_card
      name="ex-radio_card-show-radio"
      cols="three"
      id="ex-radio_card-show-radio"
      cols_gap="extra_small"
      size="extra_small"
      show_radio
    >
      <:radio value="show-radio1" title="Starter Plan"></:radio>
      <:radio value="show-radio2" title="Pro Plan"></:radio>
      <:radio value="show-radio3" title="Premium Plan"></:radio>
    </.radio_card>
    """
  end

  def example(%{section: "reverse"} = assigns) do
    ~H"""
    <.radio_card
      name="ex-radio_card-reverse"
      cols="three"
      id="ex-radio_card-reverse"
      size="extra_small"
      show_radio
      reverse
    >
      <:radio value="reverse1" title="Starter Plan"></:radio>
      <:radio value="reverse2" title="Pro Plan"></:radio>
      <:radio value="reverse3" title="Premium Plan"></:radio>
    </.radio_card>
    """
  end

  def example(%{section: "radio_slot"} = assigns) do
    ~H"""
    <.radio_card
      name="ex-radio_card-radio-slot"
      cols="two"
      id="ex-radio_card-radio-slot"
      size="small"
      class="text-center"
    >
      <:radio value="radio-slot1" checked icon="hero-cube" title="Package Storage"></:radio>
      <:radio value="radio-slot2" icon_class="size-4" icon="hero-building-office" title="Office Space">
      </:radio>
      <:radio value="radio-slot3" icon="hero-globe-alt" title="Global Network"></:radio>
      <:radio value="radio-slot4" icon="hero-adjustments-horizontal" title="Custom Settings"></:radio>
      <:radio value="radio-slot6" icon="hero-code-bracket" title="Developer Tools"></:radio>
      <:radio
        value="radio-slot5"
        icon="hero-cpu-chip"
        description="Access development tools and APIs for building applications"
      >
      </:radio>
    </.radio_card>
    """
  end

  def example(assigns), do: ~H""
end
