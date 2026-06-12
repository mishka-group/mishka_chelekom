defmodule DevelopmentWeb.Showcase.Examples.TableContent do
  @moduledoc """
  Docs examples for the `table_content` component, taken from the Mishka source docs
  (`mishka/.../docs/table_content_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  Note: the source docs use verified-route `~p` patch links; those routes don't exist in this
  showcase app, so they're rendered here as plain `href="#..."` anchors.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "rounded", title: "Rounded"},
      %{id: "border", title: "Border"},
      %{id: "size", title: "Size"},
      %{id: "space", title: "Space"},
      %{id: "padding", title: "Padding"},
      %{id: "title", title: "Title"},
      %{id: "icons", title: "Content item icons"},
      %{id: "nested", title: "Nested content"}
    ]
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.table_content id="ex-table_content-rounded" color="info" variant="bordered" rounded="extra_large">
        <.content_item icon="hero-hashtag">
          <.link href="#overview">Overview</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#colors">Color and Variants</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#space">Space</.link>
        </.content_item>
        <.content_item icon="hero-hashtag" active>
          <.link href="#rounded">Rounded</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#size">Size</.link>
        </.content_item>
      </.table_content>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.table_content id="ex-table_content-border" variant="default" color="info" rounded="extra_large">
        <.content_item icon="hero-hashtag">
          <.link href="#overview">Overview</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#colors">Color and Variants</.link>
        </.content_item>
        <.content_item icon="hero-hashtag" active>
          <.link href="#rounded">Rounded</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#size">Size</.link>
        </.content_item>
      </.table_content>
    </div>
    """
  end

  def example(%{section: "size"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.table_content id="ex-table_content-size" color="info" variant="bordered" size="extra_large">
        <.content_item icon="hero-hashtag">
          <.link href="#overview">Overview</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#colors">Color and Variants</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#padding">Padding</.link>
        </.content_item>
        <.content_item icon="hero-hashtag" active>
          <.link href="#size">Size</.link>
        </.content_item>
      </.table_content>
    </div>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.table_content id="ex-table_content-space" color="info" variant="bordered" space="extra_large">
        <.content_item icon="hero-hashtag">
          <.link href="#overview">Overview</.link>
        </.content_item>
        <.content_item icon="hero-hashtag" active>
          <.link href="#space">Space</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#padding">Padding</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#size">Size</.link>
        </.content_item>
      </.table_content>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.table_content id="ex-table_content-padding" color="info" variant="bordered" padding="quadruple_large">
        <.content_item icon="hero-hashtag">
          <.link href="#overview">Overview</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#space">Space</.link>
        </.content_item>
        <.content_item icon="hero-hashtag" active>
          <.link href="#padding">Padding</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#size">Size</.link>
        </.content_item>
      </.table_content>
    </div>
    """
  end

  def example(%{section: "title"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.table_content
        id="ex-table_content-title"
        color="danger"
        variant="bordered"
        padding="extra_small"
        title="Sample table of contents"
      >
        <.content_item icon="hero-hashtag">
          <.link href="#overview">Overview</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#space">Space</.link>
        </.content_item>
        <.content_item icon="hero-hashtag" active>
          <.link href="#padding">Padding</.link>
        </.content_item>
        <.content_item icon="hero-hashtag">
          <.link href="#size">Size</.link>
        </.content_item>
      </.table_content>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.table_content id="ex-table_content-icons" variant="bordered" padding="extra_small">
        <.content_item icon="hero-tag" icon_class="!size-8 text-rose-300">
          <.link href="#overview">Overview</.link>
        </.content_item>
        <.content_item icon="hero-tag" icon_class="!size-8 text-rose-300">
          <.link href="#colors">Color and Variants</.link>
        </.content_item>
        <.content_item icon="hero-tag" icon_class="!size-8 text-rose-300">
          <.link href="#padding">Padding</.link>
        </.content_item>
        <.content_item icon="hero-tag" icon_class="!size-8 text-rose-300">
          <.link href="#size">Size</.link>
        </.content_item>
      </.table_content>
    </div>
    """
  end

  def example(%{section: "nested"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.table_content id="ex-table_content-nested" color="info" variant="bordered" padding="extra_small">
        <.content_item title="Table content props">
          <.content_wrapper>
            <.content_item icon="hero-chevron-right">
              <.link href="#overview">Overview</.link>
            </.content_item>
            <.content_item icon="hero-chevron-right">
              <.link href="#colors">Color and Variants</.link>
            </.content_item>
            <.content_item icon="hero-chevron-right">
              <.link href="#space">Space</.link>
            </.content_item>
            <.content_item icon="hero-chevron-right">
              <.link href="#size">Size</.link>
            </.content_item>
          </.content_wrapper>
        </.content_item>

        <.content_item title="Table content item props">
          <.content_wrapper>
            <.content_item icon="hero-chevron-right">
              <.link href="#content-item">Content item component</.link>
            </.content_item>
            <.content_item icon="hero-chevron-right">
              <.link href="#content-item-title">Content item title prop</.link>
            </.content_item>
            <.content_item icon="hero-chevron-right">
              <.link href="#content-item-active">Content item active prop</.link>
            </.content_item>
          </.content_wrapper>
        </.content_item>
      </.table_content>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
