defmodule DevelopmentWeb.HeadlessDaisyUISkinTest do
  @moduledoc """
  The daisyUI skin's contract: the *same* headless component, painted by a stylesheet instead of by
  utility classes. These tests read the component list from
  `DevelopmentWeb.Showcase.HeadlessDaisyUIExamples`, so every component that gains a skin is
  covered the moment its examples land.

  What must hold, per component:

    * both galleries mount and render that component's parts;
    * the ARIA/`data-*` surface the engines drive is identical in both — the skin cannot have
      changed behavior;
    * the daisyUI markup carries no per-part styling classes, which is the whole point.
  """
  use DevelopmentWeb.ConnCase
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Showcase.{HeadlessBaseUIExamples, HeadlessCatalog, HeadlessDaisyUIExamples}

  @skinned HeadlessDaisyUIExamples.components()

  # Attributes the JS engines and screen readers depend on. Whatever a component emits in the Base
  # UI gallery it must also emit in the daisyUI one.
  @behavioral ~w(role aria-expanded aria-controls aria-haspopup aria-selected aria-labelledby
                 aria-multiselectable data-part data-open data-closed data-selected data-index
                 data-value data-orientation tabindex)

  defp attrs_present(html) do
    Enum.filter(@behavioral, &String.contains?(html, "#{&1}="))
  end

  defp gallery(conn, skin, name) do
    {:ok, _view, html} = live(conn, "/showcase/headless-#{skin}/#{name}")
    html
  end

  test "the skin ships at least one component" do
    refute Enum.empty?(@skinned)
  end

  test "every skinned component has examples in BOTH galleries" do
    for name <- @skinned do
      assert HeadlessDaisyUIExamples.sections(name) != []

      assert HeadlessBaseUIExamples.has?(name),
             "#{name} has no Base UI examples to compare against"
    end
  end

  test "the daisyUI gallery index mounts and lists exactly the skinned components", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/showcase/headless-daisyui")

    for name <- @skinned do
      assert html =~ "sec-#{name}", "#{name} missing from the daisyUI gallery index"
    end
  end

  test "each skinned component's page mounts and renders its own parts", %{conn: conn} do
    for name <- @skinned do
      html = gallery(conn, "daisyui", name)
      assert html =~ "chelekom-#{name}", "#{name}: daisyUI page renders no component markup"
      assert html =~ ~s(data-part=)
    end
  end

  test "the skin does not change the behavioral attribute surface", %{conn: conn} do
    for name <- @skinned do
      baseui = attrs_present(gallery(conn, "baseui", name))
      daisyui = attrs_present(gallery(conn, "daisyui", name))

      assert baseui != [], "#{name}: no behavioral attributes found to compare"

      assert MapSet.subset?(MapSet.new(baseui), MapSet.new(daisyui)),
             "#{name}: daisyUI markup dropped #{inspect(MapSet.difference(MapSet.new(baseui), MapSet.new(daisyui)) |> MapSet.to_list())}"
    end
  end

  test "the daisyUI examples pass no per-part styling classes", %{conn: _conn} do
    for name <- @skinned, {id, _title, _desc} <- HeadlessDaisyUIExamples.sections(name) do
      source = HeadlessDaisyUIExamples.source(id)
      assert is_binary(source), "#{id}: source could not be extracted for the code block"

      refute source =~
               ~r/\b(trigger|popup|item|panel|positioner|value|icon|group|content|label)_class=/,
             "#{id}: the daisyUI example hand-paints a part — the skin should be doing that"
    end
  end

  test "the Base UI examples DO hand-paint their parts (the contrast the gallery shows)" do
    hand_painted =
      for name <- @skinned,
          {id, _t, _d} <- HeadlessBaseUIExamples.sections(name),
          source = HeadlessBaseUIExamples.source(id),
          is_binary(source),
          source =~ ~r/_class=/,
          do: id

    assert hand_painted != [],
           "expected the Base UI gallery to style parts inline — otherwise the comparison is meaningless"
  end

  test "the skin switch links both ways on a component page", %{conn: conn} do
    name = hd(@skinned)

    assert gallery(conn, "daisyui", name) =~ "/showcase/headless-baseui/#{name}"
    assert gallery(conn, "baseui", name) =~ "/showcase/headless-daisyui/#{name}"
  end

  test "the daisyUI select form submits the value its hidden input carries", %{conn: conn} do
    {:ok, view, html} = live(conn, "/showcase/headless-daisyui/select")

    assert html =~ ~s(phx-submit="daisyui_select_submit")
    assert html =~ "d-btn"

    assert view
           |> form(~s(form[phx-submit="daisyui_select_submit"]))
           |> render_submit() =~ "Submitted: gala"
  end

  test "an unskinned component's daisyUI page says so instead of 500ing", %{conn: conn} do
    unskinned =
      HeadlessCatalog.all()
      |> Enum.map(& &1.name)
      |> Enum.reject(&(&1 in @skinned))
      |> hd()

    html = gallery(conn, "daisyui", unskinned)
    assert html =~ "No daisyUI skin for this component yet"
  end
end
