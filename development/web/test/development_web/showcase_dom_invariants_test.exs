defmodule DevelopmentWeb.ShowcaseDomInvariantsTest do
  @moduledoc """
  Two DOM rules the whole showcase has to keep, checked on every page the catalogs know about
  (styled and headless), so a new component is covered the moment its catalog file lands.

    * **No duplicated `id`.** A repeated id makes `label[for]`, `aria-*` references and LiveView's
      own DOM patching resolve to the wrong element — the failure mode behind issue #496, where a
      file field's label pointed at an id the browser had already discarded.
    * **Every bound form carries an `id`.** Without one LiveView cannot recover the form after a
      disconnect, and `Phoenix.LiveViewTest` warns on each render.

  Both rules are collected in a single sweep: mounting ~130 LiveViews twice would sit close to
  ExUnit's default per-test timeout on a loaded machine.
  """
  use DevelopmentWeb.ConnCase
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Showcase.{Catalog, HeadlessCatalog}

  @moduletag timeout: 300_000

  defp paths do
    Enum.map(Catalog.all(), &"/showcase/#{&1.name}") ++
      Enum.map(HeadlessCatalog.all(), &"/showcase/headless/#{&1.name}") ++
      ["/showcase", "/showcase/kit", "/showcase/headless", "/showcase/headless-baseui"]
  end

  defp violations(conn, path) do
    {:ok, _view, html} = live(conn, path)
    doc = LazyHTML.from_document(html)

    ids = doc |> LazyHTML.query("[id]") |> LazyHTML.attribute("id")
    forms = LazyHTML.query(doc, "form[phx-change], form[phx-submit]")

    dups = Enum.uniq(ids -- Enum.uniq(ids))
    # LazyHTML drops the attribute entirely when it is absent, so a short list *is* the failure.
    unbound = Enum.count(forms) - length(LazyHTML.attribute(forms, "id"))

    cond do
      dups != [] -> {path, "duplicated id(s): #{inspect(dups)}"}
      unbound > 0 -> {path, "#{unbound} form(s) with phx-change/phx-submit missing an id"}
      true -> nil
    end
  end

  test "the path list covers both catalogs" do
    assert length(paths()) > 100
  end

  test "every showcase page has unique ids and identifies its bound forms", %{conn: conn} do
    found = paths() |> Enum.map(&violations(conn, &1)) |> Enum.reject(&is_nil/1)

    assert found == [],
           "DOM invariants broken:\n" <>
             Enum.map_join(found, "\n", fn {path, why} -> "  #{path}: #{why}" end)
  end
end
