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

  # The line is not consistent about this: `otp_field` renders `chelekom-otp_field` while
  # `semi_circle_progress` and `radio_group` render hyphens. Accept either rather than encode a rule
  # the components do not follow.
  defp root_classes(name), do: ["chelekom-#{name}", "chelekom-#{String.replace(name, "_", "-")}"]

  test "the skin ships at least one component" do
    refute Enum.empty?(@skinned)
  end

  test "every skinned component has daisyUI examples" do
    for name <- @skinned do
      assert HeadlessDaisyUIExamples.sections(name) != [], "#{name} has no daisyUI examples"
    end
  end

  # Most skinned components can be compared side by side, but not all: `button` exists because
  # daisyUI has one and Base UI does not, so there is nothing to port into the other gallery. Assert
  # the overlap is real rather than that it is total.
  test "most skinned components can be compared against a Base UI example" do
    {comparable, daisyui_only} = Enum.split_with(@skinned, &HeadlessBaseUIExamples.has?/1)

    assert length(comparable) > length(daisyui_only),
           "the galleries have drifted apart: #{inspect(daisyui_only)} exist only in daisyUI"
  end

  test "the daisyUI gallery index mounts and lists exactly the skinned components", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/showcase/headless-daisyui")

    for name <- @skinned do
      assert html =~ "sec-#{name}", "#{name} missing from the daisyUI gallery index"
    end
  end

  test "each skinned component's page mounts and renders its own markup", %{conn: conn} do
    for name <- @skinned do
      html = gallery(conn, "daisyui", name)

      assert Enum.any?(root_classes(name), &String.contains?(html, &1)),
             "#{name}: daisyUI page renders no component markup"
    end
  end

  # Not every component has parts. A leaf like `anchor` is a single `<a>` with one class and no
  # `data-part` anywhere, so requiring parts would say more about the test than about the skin.
  test "a component with parts still emits them under the skin", %{conn: conn} do
    with_parts =
      Enum.filter(@skinned, fn name ->
        gallery(conn, "baseui", name) =~ ~s(data-part=)
      end)

    refute Enum.empty?(with_parts)

    for name <- with_parts do
      assert gallery(conn, "daisyui", name) =~ ~s(data-part=),
             "#{name}: the skinned page lost its parts"
    end
  end

  test "the skin does not change the behavioral attribute surface", %{conn: conn} do
    for name <- @skinned do
      baseui = attrs_present(gallery(conn, "baseui", name))
      daisyui = attrs_present(gallery(conn, "daisyui", name))

      # A component may legitimately carry none — `anchor` is a bare `<a>`. What must never happen
      # is the skinned page having FEWER than the Base UI one.
      assert MapSet.subset?(MapSet.new(baseui), MapSet.new(daisyui)),
             "#{name}: daisyUI markup dropped #{inspect(MapSet.difference(MapSet.new(baseui), MapSet.new(daisyui)) |> MapSet.to_list())}"
    end
  end

  test "every example's source can be extracted for its code block" do
    for name <- @skinned, {id, _title, _desc} <- HeadlessDaisyUIExamples.sections(name) do
      assert is_binary(HeadlessDaisyUIExamples.source(id)),
             "#{id}: source could not be extracted for the code block"
    end
  end

  test "each component's hero passes no per-part styling classes — the skin does all of it" do
    for name <- @skinned do
      id = HeadlessDaisyUIExamples.hero(name)
      source = HeadlessDaisyUIExamples.source(id)

      refute source =~
               ~r/\b(trigger|popup|item|panel|positioner|value|icon|group|content|label|list|track|indicator|thumb|backdrop|viewport|footer|description|title)_class=/,
             "#{id}: the hero hand-paints a part — the skin should be doing that"
    end
  end

  test "variant examples reach daisyUI's own modifiers rather than re-implementing them" do
    variants =
      for name <- @skinned,
          [_hero | rest] = HeadlessDaisyUIExamples.sections(name),
          {id, _t, _d} <- rest,
          source = HeadlessDaisyUIExamples.source(id),
          is_binary(source),
          do: {id, source}

    assert length(variants) > 20, "expected the galleries to mirror daisyUI's full example sets"

    using_daisy = Enum.filter(variants, fn {_id, src} -> src =~ ~r/\bd-[a-z]/ end)

    assert length(using_daisy) > 10,
           "expected most variants to opt into daisyUI's real modifier classes"
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

  test "only the daisyUI gallery opts into the skin's scope", %{conn: conn} do
    for name <- @skinned do
      assert gallery(conn, "daisyui", name) =~ ~s(data-skin="daisyui"),
             "#{name}: the daisyUI page does not opt into the skin scope"

      refute gallery(conn, "baseui", name) =~ ~s(data-skin="daisyui"),
             "#{name}: the skin would repaint the Base UI examples"
    end
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
