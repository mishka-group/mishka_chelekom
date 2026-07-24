defmodule DevelopmentWeb.Showcase.Examples.NativeSelect do
  @moduledoc """
  Docs examples for the `native_select` component, taken from the Mishka source docs
  (`mishka/.../docs/forms/native_select_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Native select"},
      %{id: "variants", title: "Variants"},
      %{id: "description", title: "Description and label"},
      %{id: "multiple", title: "Multiple selection"},
      %{id: "options", title: "Option slot"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="grid md:grid-cols-2 gap-5">
      <.native_select
        name="sample-1"
        label="Native select"
        variant="base"
        size="small"
        color="base"
        id="ex-native_select-1"
        space="small"
      >
        <:option value="" selected>Choose one</:option>
        <:option value="v1">Backend developer</:option>
        <:option value="v2">Frontend developer</:option>
        <:option value="v3">Full stack developer</:option>
      </.native_select>

      <.native_select
        name="sample-2"
        variant="base"
        description="Please choose a programming language"
        size="small"
        color="base"
        id="ex-native_select-2"
        space="small"
      >
        <:option value="" selected>Select a language</:option>
        <:option value="v1">Python</:option>
        <:option value="v2">JavaScript</:option>
        <:option value="v3">Elixir</:option>
      </.native_select>
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.native_select
        name="countries1"
        id="ex-native_select-3"
        description="Native select"
        label="Label of native variant"
        space="small"
      >
        <:option value="nl" selected>NL</:option>
        <:option value="usa">USA</:option>
        <:option value="uae">UAE</:option>
      </.native_select>

      <.native_select
        name="countries1"
        id="ex-native_select-4"
        description="Native select shadow variant"
        label="Label of natural color"
        space="small"
        variant="shadow"
        color="natural"
      >
        <:option value="nl" selected>NL</:option>
        <:option value="usa">USA</:option>
        <:option value="uae">UAE</:option>
      </.native_select>

      <.native_select
        name="countries1"
        id="ex-native_select-5"
        description="Native select default variant"
        label="Label of natural"
        space="small"
        variant="default"
        color="dawn"
      >
        <:option value="nl" selected>NL</:option>
        <:option value="usa">USA</:option>
        <:option value="uae">UAE</:option>
      </.native_select>

      <.native_select
        name="countries1"
        id="ex-native_select-6"
        description="Native select bordered variant"
        label="Label of natural color"
        space="small"
        variant="bordered"
        color="misc"
      >
        <:option value="nl" selected>NL</:option>
        <:option value="usa">USA</:option>
        <:option value="uae">UAE</:option>
      </.native_select>
    </div>
    """
  end

  def example(%{section: "description"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.native_select
        name="countries2"
        space="small"
        id="ex-native_select-7"
        color="misc"
        variant="default"
        description="This is description"
        label="Label of"
      >
        <:option value="nl" selected>NL</:option>
        <:option value="usa">USA</:option>
        <:option value="uae">UAE</:option>
      </.native_select>
    </div>
    """
  end

  def example(%{section: "multiple"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.native_select
        name="countries3"
        space="small"
        id="ex-native_select-8"
        description="Choose multiple items"
        label="Label of multiple option select"
        multiple
      >
        <:option value="nl" selected>NL</:option>
        <:option value="usa">USA</:option>
        <:option value="uae">UAE</:option>
      </.native_select>
    </div>
    """
  end

  def example(%{section: "options"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.native_select
        name="countries4"
        space="small"
        id="ex-native_select-9"
        color="natural"
        variant="default"
        label="Option attributes"
        description="The third option is disabled"
      >
        <:option value="nl" selected>NL</:option>
        <:option value="usa">USA</:option>
        <:option value="uae" disabled="true">UAE</:option>
      </.native_select>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
