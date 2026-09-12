defmodule DevelopmentWeb.HeadlessShowcaseSmokeTest do
  @moduledoc """
  Mounts every headless component page the catalog knows about — the preview page and the
  Base UI-style gallery page. The list comes from `priv/headless/*.exs` at runtime, so a new
  component is covered the moment its catalog file lands; a clause that raises, a missing
  import or a broken preview fails here instead of in the browser.
  """
  use DevelopmentWeb.ConnCase
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Showcase.{HeadlessBaseUIExamples, HeadlessCatalog}

  test "the catalog is not empty" do
    assert length(HeadlessCatalog.all()) > 40
  end

  test "every headless preview page mounts and shows its component", %{conn: conn} do
    for %{name: name} <- HeadlessCatalog.all() do
      {:ok, _view, html} = live(conn, "/showcase/headless/#{name}")
      assert html =~ "chelekom-", "#{name}: preview renders no chelekom-* component markup"
    end
  end

  test "every headless gallery page mounts", %{conn: conn} do
    for %{name: name} <- HeadlessCatalog.all() do
      {:ok, _view, _html} = live(conn, "/showcase/headless-baseui/#{name}")
    end
  end

  test "every component has at least one Base UI example" do
    # Mounting is not enough: a page with no examples mounts perfectly happily and shows nothing,
    # which is how twenty of them stayed empty without anyone noticing.
    missing = Enum.reject(HeadlessCatalog.all(), &HeadlessBaseUIExamples.has?(&1.name))

    assert missing == [], "no Base UI examples for: #{Enum.map_join(missing, " ", & &1.name)}"
  end

  test "every Base UI gallery page actually renders its component", %{conn: conn} do
    for %{name: name} <- HeadlessCatalog.all() do
      {:ok, _view, html} = live(conn, "/showcase/headless-baseui/#{name}")

      # `chelekom-*` rather than `[data-part]`: a single-element component such as `action_icon`
      # has no parts to name, but every component carries its own root class.
      assert html =~ "chelekom-", "#{name}: the gallery page rendered no component markup"
    end
  end

  test "the Base UI examples paint with Tailwind classes, never a theme variable" do
    # The point of this gallery is that every colour is a Tailwind class you can read in the markup
    # and paste elsewhere. A `--c-*` theme variable would hide it, and would tie the demo to this
    # harness's palette rather than to Tailwind's.
    source = File.read!("lib/development_web/live/showcase/headless_baseui_examples.ex")

    refute source =~ "var(--c-"
    assert source =~ "dark:text-white", "the page should still be painting with Tailwind colours"
  end
end
