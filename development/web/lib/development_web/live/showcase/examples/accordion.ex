defmodule DevelopmentWeb.Showcase.Examples.Accordion do
  @moduledoc """
  Docs examples for the `accordion` component, taken from the Mishka source docs
  (`mishka/.../docs/accordion_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base & Base separated"},
      %{id: "default", title: "Default variant"},
      %{id: "outline", title: "Outline variant"},
      %{id: "bordered-separated", title: "Bordered separated variant"},
      %{id: "padding", title: "Padding"},
      %{id: "size", title: "Size"},
      %{id: "chevron", title: "Chevron props"},
      %{id: "multiple-open", title: "Multiple items with initial open state"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.accordion id="ex-accordion-base" variant="base">
        <:item id="base1" title="Default variant item one">
          Item one content
        </:item>

        <:item id="base2" title="Default variant item two">
          Item two content
        </:item>
      </.accordion>

      <.accordion id="ex-accordion-base-sep" variant="base_separated" space="small">
        <:item id="basesep1" title="Default variant item one">
          Item one content
        </:item>

        <:item id="basesep2" title="Default variant item two">
          Item two content
        </:item>
      </.accordion>
    </div>
    """
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.accordion id="ex-accordion-default" variant="default" color="primary">
        <:item id="def1" title="Default variant item one">
          Item one content
        </:item>

        <:item id="def2" title="Default variant item two">
          Item two content
        </:item>
      </.accordion>
    </div>
    """
  end

  def example(%{section: "outline"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.accordion id="ex-accordion-outline-sec" variant="outline" color="secondary">
        <:item id="out1" title="Outline variant item one">
          Outline variant item one content
        </:item>

        <:item id="out2" title="Outline variant item two">
          Outline variant item two content
        </:item>
      </.accordion>

      <.accordion id="ex-accordion-outline-danger" variant="outline" color="danger">
        <:item id="outdanger1" title="Outline variant item one">
          Outline variant item one content
        </:item>

        <:item id="outdanger2" title="Outline variant item two">
          Outline variant item two content
        </:item>
      </.accordion>
    </div>
    """
  end

  def example(%{section: "bordered-separated"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.accordion id="ex-accordion-bordered-sep" variant="bordered_separated" color="danger">
        <:item title="Tinted split variant item one">
          Tinted split variant item one content
        </:item>

        <:item title="Tinted split variant item two">
          Tinted split variant item two content
        </:item>
      </.accordion>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.accordion id="ex-accordion-pad-xs" variant="bordered" padding="extra_small" color="success">
        <:item title="Extra Small padding item one">
          Extra Small padding item one content
        </:item>

        <:item title="Extra Small padding item two">
          Extra Small padding item two content
        </:item>
      </.accordion>

      <.accordion id="ex-accordion-pad-lg" variant="bordered" padding="large" color="dawn">
        <:item title="Large padding one">
          Large padding one content
        </:item>

        <:item title="Large padding two">
          Large padding two content
        </:item>
      </.accordion>
    </div>
    """
  end

  def example(%{section: "size"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.accordion id="ex-accordion-size-xs" variant="bordered" size="extra_small" color="silver">
        <:item title="Size prop item one">
          Size prop item one content
        </:item>

        <:item title="Size prop item two">
          Size prop item two content
        </:item>
      </.accordion>

      <.accordion id="ex-accordion-size-lg" variant="bordered" size="large" color="silver">
        <:item title="Size prop item one">
          Size prop item one content
        </:item>

        <:item title="Size prop item two">
          Size prop item two content
        </:item>
      </.accordion>
    </div>
    """
  end

  def example(%{section: "chevron"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.accordion
        id="ex-accordion-chevron-icon"
        variant="bordered"
        color="info"
        chevron_icon="hero-cog-8-tooth"
      >
        <:item title="Icon chevron item one">
          Icon chevron
        </:item>

        <:item title="Icon chevron item two">
          Icon chevron
        </:item>
      </.accordion>

      <.accordion id="ex-accordion-chevron-right" variant="bordered" color="natural" right_chevron>
        <:item title="Right chevron item one">
          chevron content
        </:item>

        <:item title="Right chevron item two">
          Right chevron item two content
        </:item>
      </.accordion>

      <.accordion id="ex-accordion-chevron-hide" variant="bordered" color="info" hide_chevron>
        <:item title="Hide chevron item one">
          Hide chevron content
        </:item>

        <:item title="Hide chevron item two">
          Hide chevron content
        </:item>
      </.accordion>
    </div>
    """
  end

  def example(%{section: "multiple-open"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.accordion
        id="ex-accordion-multiple-open"
        variant="bordered_separated"
        color="primary"
        multiple={true}
        initial_open={["ex-item1", "ex-item3"]}
      >
        <:item
          id="ex-item1"
          title="First Item (Initially Open)"
          icon="hero-document-text"
          icon_class="size-[17px] text-primary-600 dark:text-primary-300"
        >
          This is the first accordion item that is initially open. It demonstrates how you can have specific items expanded when the accordion loads.
        </:item>

        <:item
          id="ex-item2"
          title="Second Item (Initially Closed)"
          icon="hero-cog-6-tooth"
          icon_class="size-[17px] text-primary-600 dark:text-primary-300"
        >
          This item starts closed and can be opened by clicking the trigger. The accordion supports multiple items being open simultaneously.
        </:item>

        <:item
          id="ex-item3"
          title="Third Item (Initially Open)"
          icon="hero-star"
          icon_class="size-[17px] text-primary-600 dark:text-primary-300"
        >
          This is another initially open item. You can specify multiple items to be open by including their IDs in the initial_open array.
        </:item>

        <:item
          id="ex-item4"
          title="Fourth Item (Initially Closed)"
          icon="hero-heart"
          icon_class="size-[17px] text-primary-600 dark:text-primary-300"
        >
          This final item demonstrates the complete flexibility of the accordion component with multiple items and mixed initial states.
        </:item>
      </.accordion>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
