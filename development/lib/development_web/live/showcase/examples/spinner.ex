defmodule DevelopmentWeb.Showcase.Examples.Spinner do
  @moduledoc """
  Docs examples for the `spinner` component, taken from the Mishka source docs
  (`mishka/.../docs/spinner_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "overview", title: "Overview"},
      %{id: "types", title: "Types"},
      %{id: "colors", title: "Colors"},
      %{id: "sizes", title: "Sizes"}
    ]
  end

  def example(%{section: "overview"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-10">
      <.spinner color="danger" size="extra_small" />
      <.spinner color="misc" size="extra_small" type="bars" />
      <.spinner color="silver" size="extra_small" type="dots" />
      <.spinner color="warning" size="large" />
      <.spinner color="success" size="large" type="dots" />
      <.spinner color="danger" size="large" type="pinging" />
    </div>
    """
  end

  def example(%{section: "types"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-10">
      <.spinner id="ex-spinner-1" color="danger" size="extra_small" />
      <.spinner id="ex-spinner-2" color="misc" size="extra_small" type="bars" />
      <.spinner id="ex-spinner-3" size="extra_small" type="dots" />
      <.spinner id="ex-spinner-4" color="success" size="large" type="pinging" />
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-10">
      <.spinner color="danger" size="extra_small" />
      <.spinner color="misc" size="extra_small" type="bars" />
      <.spinner color="silver" size="extra_small" type="dots" />
      <.spinner color="warning" size="large" />
      <.spinner color="success" size="large" type="dots" />
      <.spinner color="danger" size="large" type="pinging" />
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-10">
      <div class="flex flex-wrap items-center gap-5">
        <.spinner :for={s <- ~w(extra_small small medium large extra_large double_large triple_large quadruple_large)} color="primary" size={s} />
      </div>

      <div class="flex flex-wrap items-center gap-5">
        <.spinner :for={s <- ~w(extra_small small medium large extra_large double_large triple_large quadruple_large)} color="success" size={s} type="dots" />
      </div>

      <div class="flex flex-wrap items-center gap-5">
        <.spinner :for={s <- ~w(extra_small small medium large extra_large double_large triple_large quadruple_large)} color="misc" size={s} type="bars" />
      </div>

      <div class="flex flex-wrap items-center gap-5">
        <.spinner :for={s <- ~w(extra_small small medium large extra_large double_large triple_large quadruple_large)} color="info" size={s} type="pinging" />
      </div>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
