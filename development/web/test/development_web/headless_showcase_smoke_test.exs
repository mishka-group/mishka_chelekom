defmodule DevelopmentWeb.HeadlessShowcaseSmokeTest do
  @moduledoc """
  Mounts every headless component page the catalog knows about — the preview page and the
  Base UI-style gallery page. The list comes from `priv/headless/*.exs` at runtime, so a new
  component is covered the moment its catalog file lands; a clause that raises, a missing
  import or a broken preview fails here instead of in the browser.
  """
  use DevelopmentWeb.ConnCase
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Showcase.HeadlessCatalog

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
end
