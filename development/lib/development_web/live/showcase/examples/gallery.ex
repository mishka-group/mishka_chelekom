defmodule DevelopmentWeb.Showcase.Examples.Gallery do
  @moduledoc """
  Docs examples for the `gallery` component, taken from the Mishka source docs
  (`mishka/.../docs/gallery_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The original docs reference local `~p"/images/card-N.jpg"` assets that do not exist in the
  development app, so literal remote placeholder URLs are used instead to keep this module
  self-contained.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "display", title: "Display images"},
      %{id: "shadow", title: "Gallery media shadow"},
      %{id: "rounded", title: "Gallery media rounded"},
      %{id: "masonry", title: "Masonry type"},
      %{id: "featured", title: "Featured type"},
      %{id: "cols", title: "Cols"},
      %{id: "gap", title: "Gap"},
      %{id: "filterable", title: "Filterable gallery"}
    ]
  end

  def example(%{section: "display"} = assigns) do
    ~H"""
    <.gallery cols="three" id="ex-gallery-display" gap="small">
      <.gallery_media src="https://picsum.photos/id/1015/600/400" alt="Gallery media one" />
      <.gallery_media src="https://picsum.photos/id/1016/600/400" alt="Gallery media two" />
      <.gallery_media src="https://picsum.photos/id/1018/600/400" alt="Gallery media three" />
    </.gallery>
    """
  end

  def example(%{section: "shadow"} = assigns) do
    ~H"""
    <.gallery cols="three" gap="small" id="ex-gallery-shadow">
      <.gallery_media src="https://picsum.photos/id/1015/600/400" shadow="extra_small" alt="Shadow extra small" />
      <.gallery_media src="https://picsum.photos/id/1016/600/400" shadow="small" alt="Shadow small" />
      <.gallery_media src="https://picsum.photos/id/1018/600/400" shadow="medium" alt="Shadow medium" />
      <.gallery_media src="https://picsum.photos/id/1019/600/400" shadow="large" alt="Shadow large" />
      <.gallery_media src="https://picsum.photos/id/1020/600/400" shadow="extra_large" alt="Shadow extra large" />
    </.gallery>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <.gallery cols="three" gap="small" id="ex-gallery-rounded">
      <.gallery_media src="https://picsum.photos/id/1015/600/400" rounded="extra_small" alt="Rounded extra small" />
      <.gallery_media src="https://picsum.photos/id/1016/600/400" rounded="small" alt="Rounded small" />
      <.gallery_media src="https://picsum.photos/id/1018/600/400" rounded="medium" alt="Rounded medium" />
      <.gallery_media src="https://picsum.photos/id/1019/600/400" rounded="large" alt="Rounded large" />
      <.gallery_media src="https://picsum.photos/id/1020/600/400" rounded="extra_large" alt="Rounded extra large" />
      <.gallery_media src="https://picsum.photos/id/1021/600/400" rounded="full" alt="Rounded full" />
    </.gallery>
    """
  end

  def example(%{section: "masonry"} = assigns) do
    ~H"""
    <.gallery cols="three" type="masonry" gap="small" id="ex-gallery-masonry">
      <.gallery_media src="https://picsum.photos/id/1015/600/400" alt="Masonry media one" />
      <.gallery_media src="https://picsum.photos/id/1016/600/700" alt="Masonry media two" />
      <.gallery_media src="https://picsum.photos/id/1018/600/500" alt="Masonry media three" />
      <.gallery_media src="https://picsum.photos/id/1019/600/800" alt="Masonry media four" />
      <.gallery_media src="https://picsum.photos/id/1020/600/450" alt="Masonry media five" />
    </.gallery>
    """
  end

  def example(%{section: "featured"} = assigns) do
    ~H"""
    <.gallery gap="large" id="ex-gallery-featured">
      <.gallery_media src="https://picsum.photos/id/1015/1200/600" alt="Featured media one" />
      <.gallery cols="five" gap="large" id="ex-gallery-featured-inner">
        <.gallery_media src="https://picsum.photos/id/1016/600/400" alt="Featured media two" />
        <.gallery_media src="https://picsum.photos/id/1018/600/400" alt="Featured media three" />
        <.gallery_media src="https://picsum.photos/id/1019/600/400" alt="Featured media four" />
        <.gallery_media src="https://picsum.photos/id/1020/600/400" alt="Featured media five" />
      </.gallery>
    </.gallery>
    """
  end

  def example(%{section: "cols"} = assigns) do
    ~H"""
    <.gallery cols="six" id="ex-gallery-cols">
      <.gallery_media src="https://picsum.photos/id/1015/600/400" alt="Cols media one" />
      <.gallery_media src="https://picsum.photos/id/1016/600/400" alt="Cols media two" />
      <.gallery_media src="https://picsum.photos/id/1018/600/400" alt="Cols media three" />
      <.gallery_media src="https://picsum.photos/id/1019/600/400" alt="Cols media four" />
      <.gallery_media src="https://picsum.photos/id/1020/600/400" alt="Cols media five" />
      <.gallery_media src="https://picsum.photos/id/1021/600/400" alt="Cols media six" />
    </.gallery>
    """
  end

  def example(%{section: "gap"} = assigns) do
    ~H"""
    <.gallery cols="three" gap="extra_large" id="ex-gallery-gap">
      <.gallery_media src="https://picsum.photos/id/1015/600/400" alt="Gap media one" />
      <.gallery_media src="https://picsum.photos/id/1016/600/400" alt="Gap media two" />
      <.gallery_media src="https://picsum.photos/id/1018/600/400" alt="Gap media three" />
      <.gallery_media src="https://picsum.photos/id/1019/600/400" alt="Gap media four" />
      <.gallery_media src="https://picsum.photos/id/1020/600/400" alt="Gap media five" />
      <.gallery_media src="https://picsum.photos/id/1021/600/400" alt="Gap media six" />
    </.gallery>
    """
  end

  def example(%{section: "filterable"} = assigns) do
    ~H"""
    <.filterable_gallery
      id="ex-gallery-filterable"
      cols="three"
      filters={["Sky", "Sea"]}
      media={[
        %{src: "https://picsum.photos/id/1015/600/400", alt: "Sea 1", category: "Sea"},
        %{src: "https://picsum.photos/id/1016/600/400", alt: "Sky 1", category: "Sky"},
        %{src: "https://picsum.photos/id/1018/600/400", alt: "Sky 2", category: "Sky"}
      ]}
    >
    </.filterable_gallery>
    """
  end

  def example(assigns), do: ~H""
end
