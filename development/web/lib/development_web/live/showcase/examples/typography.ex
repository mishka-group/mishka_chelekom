defmodule DevelopmentWeb.Showcase.Examples.Typography do
  @moduledoc """
  Docs examples for the `typography` component, taken from the Mishka source docs
  (`mishka/.../docs/typography_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "components", title: "Typography components"},
      %{id: "colors", title: "Color prop"},
      %{id: "sizes", title: "Size prop"},
      %{id: "font-weight", title: "Font weight prop"}
    ]
  end

  def example(%{section: "components"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5 [&>*]:w-fit">
      <.h1>Heading Level 1</.h1>
      <.h2>Heading Level 2</.h2>
      <.h3>Heading Level 3</.h3>
      <.h4>Heading Level 4</.h4>
      <.h5>Heading Level 5</.h5>
      <.h6>Heading Level 6</.h6>
      <.p>Paragraph</.p>
      <.strong>Strong text</.strong>
      <.em>Emphasized text</.em>
      <.dl>Description list</.dl>
      <.dt>Definition term</.dt>
      <.dd>Definition description</.dd>
      <.abbr>Abbreviation</.abbr>
      <.figure>Figure</.figure>
      <.figcaption>Figure caption</.figcaption>
      <.mark>Highlighted text</.mark>
      <.small>Small text</.small>
      <.s>Strikethrough text</.s>
      <.u>Underlined text</.u>
      <.cite>Citation</.cite>
      <.del>Deleted text</.del>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5 [&>*]:w-fit">
      <.p color="primary">Paragraph 1</.p>
      <.p color="secondary">Paragraph 2</.p>
      <.p color="dark">Paragraph 3</.p>
      <.p color="success">Paragraph 4</.p>
      <.p color="natural">Paragraph 5</.p>
      <.p color="warning">Paragraph 6</.p>
      <.p color="danger">Paragraph 7</.p>
      <.p color="info">Paragraph 8</.p>
      <.strong color="silver">Strong text</.strong>
      <.em color="misc">Emphasized text</.em>
      <.dl color="dawn">Description list</.dl>
      <.dt color="inherit">Definition term</.dt>
      <.dd color="primary">Definition description</.dd>
      <.abbr color="secondary">Abbreviation</.abbr>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5 [&>*]:w-fit">
      <.p size="extra_small" color="silver">Extra Small Paragraph</.p>
      <.p size="small" color="silver">Small Paragraph</.p>
      <.p size="medium" color="silver">Medium Paragraph</.p>
      <.p size="large" color="silver">Large Paragraph</.p>
      <.p size="extra_large" color="silver">Extra Large Paragraph</.p>
      <.p size="double_large" color="silver">Double Large Paragraph</.p>
      <.p size="triple_large" color="silver">Triple Large Paragraph</.p>
      <.p size="quadruple_large" color="silver">Quadruple Large Paragraph</.p>
    </div>
    """
  end

  def example(%{section: "font-weight"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5 [&>*]:w-fit">
      <.p font_weight="font-black" size="extra_small" color="warning">Extra Small Paragraph</.p>
      <.p font_weight="font-thin" size="small" color="warning">Small Paragraph</.p>
      <.p font_weight="font-bold" size="medium" color="warning">Medium Paragraph</.p>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
