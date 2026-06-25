defmodule DevelopmentWeb.Showcase.Examples.Table do
  @moduledoc """
  Docs examples for the `table` component, taken from the Mishka source docs
  (`mishka/.../docs/table_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "variants", title: "Variants and colors"},
      %{id: "rounded", title: "Rounded"},
      %{id: "space", title: "Space"},
      %{id: "border", title: "Border"},
      %{id: "text_position", title: "Text position"},
      %{id: "slots", title: "Header and footer slots"},
      %{id: "components", title: "Integrating components"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <.table rows_border="extra_small" id="ex-table-variant-1">
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="primary">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="primary">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="primary">Edit</.button></.td>
        </.tr>
      </.table>

      <.table
        header_border="extra_small"
        rows_border="extra_small"
        variant="stripped"
        color="danger"
        id="ex-table-variant-2"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="danger">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="danger">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="danger">Edit</.button></.td>
        </.tr>
      </.table>

      <.table
        header_border="extra_small"
        rows_border="extra_small"
        variant="hoverable"
        color="primary"
        id="ex-table-variant-3"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="primary">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="primary">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="primary">Edit</.button></.td>
        </.tr>
      </.table>

      <.table
        id="ex-table-variant-4"
        header_border="extra_small"
        rows_border="extra_small"
        variant="separated"
        space="large"
        color="dawn"
        rounded="small"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="dawn">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="dawn">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="dawn">Edit</.button></.td>
        </.tr>
      </.table>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <.table
        header_border="extra_small"
        rows_border="extra_small"
        color="info"
        rounded="extra_large"
        variant="default"
        id="ex-table-rounded-1"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>
      </.table>
    </div>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <.table color="info" space="small" variant="separated" id="ex-table-space-1">
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>
      </.table>

      <.table color="misc" space="large" variant="separated" rounded="small" id="ex-table-space-2">
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="misc">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="misc">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="misc">Edit</.button></.td>
        </.tr>
      </.table>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <.table
        header_border="extra_small"
        rows_border="extra_small"
        color="info"
        border="extra_large"
        id="ex-table-border-1"
        variant="bordered"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>
      </.table>

      <.table cols_border="extra_small" variant="bordered" id="ex-table-border-2">
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>
      </.table>
    </div>
    """
  end

  def example(%{section: "text_position"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <.table
        header_border="extra_small"
        rows_border="extra_small"
        color="info"
        text_position="center"
        variant="default"
        id="ex-table-text-position-1"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>New York, No. 5 Broadway</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="info">Edit</.button></.td>
        </.tr>
      </.table>
    </div>
    """
  end

  def example(%{section: "slots"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <.table
        header_border="extra_small"
        rows_border="extra_small"
        cols_border="extra_small"
        id="ex-table-slots-1"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header icon="hero-pencil-square" icon_class="block mx-auto size-5"></:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>No. 5 Broadway, New York, NY 10004, United States</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>

        <:footer class="font-bold">Footer slot</:footer>
      </.table>

      <.table
        header_border="extra_small"
        rows_border="extra_small"
        cols_border="extra_small"
        id="ex-table-slots-2"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>No. 5 Broadway, New York, NY 10004, United States</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.button size="small" variant="outline" color="natural">Edit</.button></.td>
        </.tr>

        <:footer icon="hero-user-group"></:footer>
      </.table>
    </div>
    """
  end

  def example(%{section: "components"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <.table
        header_border="extra_small"
        rows_border="extra_small"
        cols_border="extra_small"
        id="ex-table-components-1"
      >
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header></:header>

        <.tr>
          <.td>Alice Johnson</.td>
          <.td>34</.td>
          <.td>No. 5 Broadway, New York, NY 10004, United States</.td>
          <.td><.rating select={2} count={5} /></.td>
        </.tr>

        <.tr>
          <.td>Michael Scott</.td>
          <.td>45</.td>
          <.td>Scranton, No. 2 Paper Road</.td>
          <.td><.rating select={1} count={5} /></.td>
        </.tr>

        <.tr>
          <.td>Emily Carter</.td>
          <.td>29</.td>
          <.td>San Francisco, No. 10 Bay Street</.td>
          <.td><.rating select={4} count={5} /></.td>
        </.tr>
      </.table>

      <.table
        header_border="extra_small"
        rows_border="extra_small"
        cols_border="extra_small"
        id="ex-table-components-2"
      >
        <:header>Trend</:header>
        <:header>Data Points</:header>
        <:header>Location</:header>
        <:header>Status</:header>

        <.tr>
          <.td>Global Market Trends</.td>
          <.td>1,245</.td>
          <.td>Worldwide</.td>
          <.td>
            <.badge color="info" variant="outline" size="extra_small" indicator pinging>
              Live trends
            </.badge>
          </.td>
        </.tr>

        <.tr>
          <.td>Tech Industry Growth</.td>
          <.td>987</.td>
          <.td>Silicon Valley</.td>
          <.td>
            <.badge
              icon="hero-arrow-trending-up"
              color="success"
              variant="outline"
              size="extra_small"
            >
              Trending
            </.badge>
          </.td>
        </.tr>

        <.tr>
          <.td>Real Estate Market</.td>
          <.td>753</.td>
          <.td>San Francisco</.td>
          <.td>
            <.badge
              icon="hero-arrow-trending-down"
              color="danger"
              variant="outline"
              size="extra_small"
            >
              Trending
            </.badge>
          </.td>
        </.tr>
      </.table>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
