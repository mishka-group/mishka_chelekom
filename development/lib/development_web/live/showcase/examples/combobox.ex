defmodule DevelopmentWeb.Showcase.Examples.Combobox do
  @moduledoc """
  Docs examples for the `combobox` component, taken from the Mishka source docs
  (`mishka/.../docs/forms/combobox_live.html.heex`). Section headers, no descriptions.

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
      %{id: "label", title: "Label & description"},
      %{id: "rounded", title: "Rounded"},
      %{id: "size", title: "Size"},
      %{id: "searchable", title: "Searchable"},
      %{id: "status", title: "Custom options"},
      %{id: "group", title: "Group combobox"},
      %{id: "multiple", title: "Multi select"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox id="ex-combobox-base" name="countries" placeholder="Select a country">
        <:option value="ca">Canada</:option>
        <:option value="us">United States</:option>
        <:option value="mx">Mexico</:option>
        <:option value="sp">Spain</:option>
        <:option value="de">Germany</:option>
        <:option value="jp">Japan</:option>
        <:option value="ch">China</:option>
        <:option value="sw">Sweden</:option>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox
        id="ex-combobox-default"
        name="country"
        placeholder="Select a country"
        variant="default"
        color="misc"
      >
        <:option value="ca">Canada</:option>
        <:option value="us">United States</:option>
        <:option value="mx">Mexico</:option>
        <:option value="sp">Spain</:option>
        <:option value="de">Germany</:option>
      </.combobox>

      <.combobox
        id="ex-combobox-bordered"
        name="country"
        placeholder="Select a country"
        variant="bordered"
        color="dawn"
        multiple
      >
        <:option value="ca">Canada</:option>
        <:option value="us">United States</:option>
        <:option value="mx">Mexico</:option>
        <:option value="sp">Spain</:option>
        <:option value="de">Germany</:option>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "label"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox
        id="ex-combobox-label"
        name="country"
        placeholder="Select a country"
        label="Origin Country"
        description="Description of field"
      >
        <:option value="ca">Canada</:option>
        <:option value="us">United States</:option>
        <:option value="mx">Mexico</:option>
        <:option value="sp">Spain</:option>
        <:option value="de">Germany</:option>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox
        id="ex-combobox-rounded"
        name="country"
        placeholder="Select a country"
        rounded="large"
        border="medium"
      >
        <:option value="ca">Canada</:option>
        <:option value="us">United States</:option>
        <:option value="mx">Mexico</:option>
        <:option value="sp">Spain</:option>
        <:option value="de">Germany</:option>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "size"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox
        id="ex-combobox-size"
        name="country"
        size="large"
        placeholder="Select a country"
        padding="medium"
      >
        <:option value="ca">Canada</:option>
        <:option value="us">United States</:option>
        <:option value="mx">Mexico</:option>
        <:option value="sp">Spain</:option>
        <:option value="de">Germany</:option>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "searchable"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox
        id="ex-combobox-searchable"
        name="country"
        size="large"
        placeholder="Select a country"
        padding="medium"
        searchable
        search_placeholder="Search a country"
      >
        <:option value="ca">Canada</:option>
        <:option value="us">United States</:option>
        <:option value="mx">Mexico</:option>
        <:option value="sp">Spain</:option>
        <:option value="de">Germany</:option>
        <:option value="jp">Japan</:option>
        <:option value="ch">China</:option>
        <:option value="sw">Sweden</:option>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "status"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox
        id="ex-combobox-status"
        name="status"
        placeholder="Select a status"
        size="medium"
        height="h-fit"
      >
        <:option value="in_progress">
          <div class="flex items-center gap-2">
            <.indicator color="warning" size="extra_small" />
            <span>In Progress</span>
          </div>
        </:option>
        <:option value="success">
          <div class="flex items-center gap-2">
            <.indicator color="success" size="extra_small" />
            <span>Success</span>
          </div>
        </:option>
        <:option value="denied">
          <div class="flex items-center gap-2">
            <.indicator color="danger" size="extra_small" />
            <span>Denied</span>
          </div>
        </:option>
        <:option value="archived">
          <div class="flex items-center gap-2">
            <.indicator color="silver" size="extra_small" />
            <span>Archived</span>
          </div>
        </:option>
        <:option value="in_review">
          <div class="flex items-center gap-2">
            <.indicator color="info" size="extra_small" />
            <span>In review</span>
          </div>
        </:option>
      </.combobox>

      <.combobox
        id="ex-combobox-date"
        name="date"
        placeholder="Choose a date"
      >
        <:start_section>
          <.icon name="hero-calendar" class="size-5" />
        </:start_section>
        <:option value="2025-01">January 2025</:option>
        <:option value="2025-02">February 2025</:option>
        <:option value="2025-03">March 2025</:option>
        <:option value="2025-04">April 2025</:option>
        <:option value="2025-05">May 2025</:option>
        <:option value="2025-06">June 2025</:option>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "group"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox id="ex-combobox-group" name="vehicles" placeholder="Select a vehicle">
        <:option group="Cars" value="sedan">Sedan</:option>
        <:option group="Cars" value="suv">SUV</:option>
        <:option group="Cars" value="coupe">Sports Coupe</:option>
        <:option group="Cars" value="hatchback">Hatchback</:option>

        <:option group="Motorcycles" value="cruiser">Cruiser</:option>
        <:option group="Motorcycles" value="sport">Sport Bike</:option>
        <:option group="Motorcycles" value="touring">Touring</:option>
        <:option group="Motorcycles" value="dirt">Dirt Bike</:option>

        <:option group="Commercial" value="truck">Delivery Truck</:option>
        <:option group="Commercial" value="van">Cargo Van</:option>
        <:option group="Commercial" value="bus">Bus</:option>
      </.combobox>
    </div>
    """
  end

  def example(%{section: "multiple"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 lg:px-20">
      <.combobox id="ex-combobox-multiple" name="fruits" placeholder="Select a fruits" multiple>
        <:option group="Fruits" value="apple">Apple</:option>
        <:option group="Fruits" value="banana">Banana</:option>
        <:option group="Fruits" value="orange">Orange</:option>
        <:option group="Fruits" value="mango">Mango</:option>

        <:option group="Vegetables" value="carrot">Carrot</:option>
        <:option group="Vegetables" value="potato">Potato</:option>
        <:option group="Vegetables" value="tomato">Tomato</:option>
        <:option group="Vegetables" value="cucumber">Cucumber</:option>
      </.combobox>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
