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

  # A component is painted in exactly one place, and which one is readable from the generated
  # stylesheet: while its `/* >>> name */` region is there the skin owns the styling and the
  # examples must stay clean; once the region is gone the markup is the only thing left, so the
  # examples have to carry it or the component renders bare. Deriving the rule from the artifact
  # means a component converts by deleting its skin fragment, with no list to keep in step.
  @skin_css File.read!("assets/vendor/mishka_chelekom_headless_daisyui.css")
  defp skinned_in_css?(name), do: String.contains?(@skin_css, "/* >>> #{name} */")

  # Handing a part daisyUI's own class (`input_class="d-radio"`) is not hand-painting — it is the
  # same opt-in the skin would make with `@apply`, just spelled in markup. Painting is a Tailwind
  # utility: a class on a part that daisyUI did not give us.
  # Once the skin is gone the hero has to carry the look itself, and where it carries it depends on
  # the component: `action_icon` is a single element styled entirely through the root `class`,
  # while `progress` needs one per part. Either counts; carrying nothing does not.
  defp styled_in_markup?(source) do
    source =~ ~r/\bclass=/ or source =~ ~r/\b[a-z_]+_class=/
  end

  # An example often renders other components inside itself — `pills_input`'s hero is full of
  # `<.pill>`. Those carry their own classes once they convert, which says nothing about whether
  # *this* component is being hand-painted. Read only the attributes of its own invocations.
  defp own_attrs(source, name) do
    ~r/<\.#{Regex.escape(name)}(?=[\s\/>])/
    |> Regex.scan(source, return: :index)
    |> Enum.map(fn [{start, len}] -> attrs_after(source, start + len) end)
    |> Enum.join(" ")
  end

  # `Regex.scan/3` with `return: :index` hands back byte offsets, and this file has multibyte
  # characters in it, so the slice has to be taken in bytes too.
  defp attrs_after(source, from) do
    source
    |> binary_part(from, byte_size(source) - from)
    |> String.graphemes()
    |> Enum.reduce_while({[], 0, nil}, fn c, {acc, depth, quote_char} ->
      cond do
        quote_char && c == quote_char -> {:cont, {[c | acc], depth, nil}}
        quote_char -> {:cont, {[c | acc], depth, quote_char}}
        c in ["\"", "'"] -> {:cont, {[c | acc], depth, c}}
        c == "{" -> {:cont, {[c | acc], depth + 1, nil}}
        c == "}" -> {:cont, {[c | acc], depth - 1, nil}}
        c == ">" and depth == 0 -> {:halt, {acc, depth, nil}}
        true -> {:cont, {[c | acc], depth, nil}}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
    |> Enum.join()
  end

  # A component can be partly converted: `countdown` moved its layout into markup and kept only the
  # rolling digit, `loading_overlay` only its spinner. So the question is not "does this hero paint
  # anything" but "does it paint a part the stylesheet is still painting" — which the stylesheet
  # itself answers.
  defp still_styled(name) do
    prefixes = ["chelekom-#{name}__", "chelekom-#{String.replace(name, "_", "-")}__"]

    for prefix <- prefixes,
        [_, part] <- Regex.scan(~r/#{Regex.escape(prefix)}([a-z0-9_-]+)/, @skin_css),
        into: MapSet.new(),
        do: String.replace(part, "-", "_")
  end

  defp utility_painted?(source, parts) do
    ~r/\b([a-z_]+)_class=/
    |> Regex.scan(source)
    |> Enum.any?(fn [whole, attr] ->
      MapSet.member?(parts, attr) and utility?(attr_value(source, whole))
    end)
  end

  # A class value is painting if any token in it is a Tailwind utility rather than one of
  # daisyUI's own classes.
  defp utility?(value) do
    value
    |> String.split(~r/[\s",]+/)
    |> Enum.reject(&(&1 == "" or String.starts_with?(&1, "d-") or String.contains?(&1, "@")))
    |> Enum.any?()
  end

  defp attr_value(source, attr) do
    case Regex.run(~r/#{Regex.escape(attr)}(?:"([^"]*)"|\{\[?([^}]*)\]?\})/, source) do
      [_ | rest] -> Enum.join(rest, " ")
      _ -> ""
    end
  end

  test "a component is painted by its skin or by its markup, never by neither" do
    for name <- @skinned do
      id = HeadlessDaisyUIExamples.hero(name)
      source = HeadlessDaisyUIExamples.source(id)

      if skinned_in_css?(name) do
        refute utility_painted?(own_attrs(source, name), still_styled(name)),
               "#{id}: the hero hand-paints a part the skin still styles"
      else
        assert styled_in_markup?(own_attrs(source, name)),
               "#{id}: the skin region is gone, so the hero must carry the styling itself"
      end
    end
  end

  test "the conversion is progressing and the stylesheet is shrinking" do
    converted = Enum.reject(@skinned, &skinned_in_css?/1)

    assert converted != [],
           "no component has moved its styling into markup yet"

    for name <- converted do
      refute @skin_css =~ "chelekom-#{String.replace(name, "_", "-")}__",
             "#{name}: converted, but the stylesheet still carries rules for its parts"
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

  test "the demo frames offer all three palettes, and the theme preview uses the only one that works",
       %{conn: conn} do
    # The frames are showcase furniture, not component markup, so they may carry classes. What
    # matters is that Tailwind is the default — it is the one a reader can copy anywhere — while the
    # chrome variables and daisyUI's theme tokens stay available for the two jobs Tailwind cannot do.
    {:ok, _view, dock} = live(conn, "/showcase/headless-daisyui/dock")

    paints =
      dock
      |> LazyHTML.from_document()
      |> LazyHTML.query("[data-paint]")
      |> LazyHTML.attribute("data-paint")

    assert paints != []
    assert Enum.uniq(paints) == ["tailwind"], "the dock frames should default to Tailwind"
    assert dock =~ "dark:bg-neutral-950", "the Tailwind paint should be written out in the markup"

    # The theme preview is the exception, and deliberately: only daisyUI's tokens follow
    # `data-theme`, so a Tailwind-painted box would not repaint when the controller changed it.
    {:ok, _view, themes} = live(conn, "/showcase/headless-daisyui/theme_controller")

    theme_paints =
      themes
      |> LazyHTML.from_document()
      |> LazyHTML.query("[data-paint]")
      |> LazyHTML.attribute("data-paint")

    assert Enum.uniq(theme_paints) == ["theme"]
    assert themes =~ "bg-base-100"
  end

  test "every component in the catalog now has a daisyUI skin", %{conn: conn} do
    # This used to assert the opposite — that an *unskinned* component fell back to a note rather
    # than a 500 — and it found one by taking the head of the unskinned list. There is no longer
    # one to take, which is the point: the fallback still exists in the gallery for a component
    # added tomorrow, but today nothing needs it.
    unskinned = HeadlessCatalog.all() |> Enum.map(& &1.name) |> Enum.reject(&(&1 in @skinned))

    assert unskinned == [], "no daisyUI skin for: #{Enum.join(unskinned, " ")}"

    # And every one of them renders its own markup on the daisyUI page.
    for %{name: name} <- HeadlessCatalog.all() do
      assert gallery(conn, "daisyui", name) =~ "chelekom-", "#{name}: nothing rendered"
    end
  end
end
