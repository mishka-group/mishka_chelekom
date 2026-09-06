defmodule DevelopmentWeb.HeadlessClassPassthroughTest do
  @moduledoc """
  Every `*_class` attribute a headless component declares must actually reach markup.

  This is the contract the daisyUI skin's copy-paste story rests on: a consumer who takes an
  example out of the gallery and away from the generated stylesheet has to be able to put the
  styling back on with Tailwind utilities, and the only way in is a class attribute. An attribute
  that is declared but never interpolated is worse than a missing one — it looks like an escape
  hatch and silently does nothing.

  Nothing here is hardcoded. The component list comes from the catalog, the attribute list from
  each module's own `__components__/0` metadata, and the assigns needed to render are synthesized
  from the declared types — so a component that gains a part and a passthrough tomorrow is covered
  without touching this file.
  """
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Showcase.HeadlessCatalog

  @sentinel "zz-passthrough-probe"

  defp modules do
    for %{name: name} <- HeadlessCatalog.all(),
        mod = Module.concat(DevelopmentWeb.Components.Headless, Macro.camelize(name)),
        Code.ensure_loaded?(mod) and function_exported?(mod, :__components__, 0),
        do: {name, mod}
  end

  # A value that satisfies the declared type. Components validate far more than the type (a
  # `value` may have to name one of the options), so this only has to get us to a render —
  # anything that does not is dropped by the baseline check below.
  # An attribute that declares `values:` is an enum — anything else raises. Take what it offers
  # rather than inventing a string it will reject.
  defp probe_value(%{name: :id}), do: "probe-id"

  defp probe_value(attr) do
    case Keyword.get(attr.opts, :values) do
      [first | _] -> first
      _ -> if attr.type == :boolean, do: true, else: sample(attr.type)
    end
  end

  defp sample(:string), do: "probe"
  defp sample(:integer), do: 1
  defp sample(:float), do: 1.0
  defp sample(:boolean), do: false
  defp sample(:list), do: [%{}]
  defp sample(:map), do: %{}
  defp sample(:atom), do: nil
  defp sample(_), do: nil

  # A part only shows up in the markup when the thing it belongs to is asked for: `alert`'s icon
  # needs the `:icon` slot, `carousel`'s controls need `show_controls`. So the probe fills *every*
  # slot and turns every boolean on, rather than only satisfying what is required — otherwise a
  # perfectly wired attribute reads as dead.
  defp base_assigns(meta) do
    attrs =
      for a <- meta.attrs,
          a.name != :rest,
          not String.ends_with?(to_string(a.name), "_class"),
          a.name == :id or a.type in [:boolean, :string] or a.required,
          into: %{} do
        {a.name, probe_value(a)}
      end

    # Several parts only exist in the plural — a separator sits *between* crumbs, an ellipsis only
    # appears once a trail is long enough to collapse — so give every slot a few entries, each
    # carrying the attributes the slot itself declares.
    slots =
      for s <- meta.slots, into: %{} do
        entries =
          for i <- 1..5 do
            s.attrs
            |> Enum.reject(&String.ends_with?(to_string(&1.name), "_class"))
            |> Map.new(&{&1.name, probe_value(&1)})
            |> Map.merge(%{
              __slot__: s.name,
              inner_block: fn _, _ -> "x" end
            })
            |> Map.update(:value, "probe-#{i}", fn v -> v || "probe-#{i}" end)
          end

        {s.name, entries}
      end

    Map.merge(attrs, slots)
  end

  defp render(mod, fun, assigns) do
    {:ok, render_component(&apply(mod, fun, [&1]), assigns)}
  rescue
    e -> {:error, e}
  catch
    kind, e -> {:error, {kind, e}}
  end

  defp source_path(name),
    do: Path.join("lib/development_web/components/headless", "#{name}.ex")

  # `@foo_class` on the root, `item[:foo_class]` inside a slot loop, or passed on to a private
  # helper as `foo_class={...}` — all three are real uses.
  defp interpolated?(src, attr) do
    String.contains?(src, "@#{attr}") or String.contains?(src, "[:#{attr}]") or
      String.contains?(src, "#{attr}={")
  end

  defp class_attrs(meta) do
    for a <- meta.attrs,
        String.ends_with?(to_string(a.name), "_class"),
        do: a.name
  end

  # Components whose render depends on state this harness cannot synthesize (an engine-driven
  # value, a `Phoenix.HTML.Form`, an option that must match a sibling) never reach a baseline
  # render, so they are reported rather than asserted on — the coverage floor below is what stops
  # that list from quietly growing to cover everything.
  defp probe_all do
    for {name, mod} <- modules(),
        {fun, meta} <- mod.__components__(),
        attrs = class_attrs(meta),
        attrs != [],
        reduce: {[], [], []} do
      {covered, dead, unrenderable} ->
        base = base_assigns(meta)

        case render(mod, fun, base) do
          {:error, _} ->
            {covered, dead, [{name, fun} | unrenderable]}

          {:ok, _} ->
            {ok, bad} =
              Enum.split_with(attrs, fn attr ->
                case render(mod, fun, Map.put(base, attr, @sentinel)) do
                  {:ok, html} -> String.contains?(html, @sentinel)
                  {:error, _} -> false
                end
              end)

            {Enum.map(ok, &{name, fun, &1}) ++ covered, Enum.map(bad, &{name, fun, &1}) ++ dead,
             unrenderable}
        end
    end
  end

  setup_all do
    {covered, dead, unrenderable} = probe_all()
    %{covered: covered, dead: dead, unrenderable: unrenderable}
  end

  # The exhaustive half, and the one that can actually fail closed: an attribute that is declared
  # but never interpolated is dead wiring. That is a question about the source, not about state, so
  # it needs no fixture and covers every attribute on every component.
  test "every declared `*_class` attribute is interpolated in its component's source" do
    dead =
      for {name, mod} <- modules(),
          src = File.read!(source_path(name)),
          {fun, meta} <- mod.__components__(),
          attr <- class_attrs(meta),
          not interpolated?(src, attr),
          do: "  #{name}.#{fun}: #{attr}"

    assert dead == [],
           "these `*_class` attributes are declared but never used:\n" <> Enum.join(dead, "\n")
  end

  test "slot-level class attributes are interpolated too" do
    dead =
      for {name, mod} <- modules(),
          src = File.read!(source_path(name)),
          {fun, meta} <- mod.__components__(),
          slot <- meta.slots,
          attr <- slot.attrs,
          String.ends_with?(to_string(attr.name), "class"),
          not interpolated?(src, attr.name),
          do: "  #{name}.#{fun} <:#{slot.name}>: #{attr.name}"

    assert dead == [],
           "these slot class attributes are declared but never used:\n" <> Enum.join(dead, "\n")
  end

  # The end-to-end half: rendering proves the interpolation above really is a class on an element,
  # not a string built and dropped. It cannot reach everything — `table` renders either rows or its
  # empty slot, never both — so it asserts on what it demonstrably surfaced.
  test "the attributes the probe can exercise really do land in the markup", %{
    covered: covered,
    dead: dead
  } do
    refute covered == []

    assert length(covered) > length(dead),
           "the probe surfaced #{length(covered)} attributes and missed #{length(dead)}: " <>
             Enum.map_join(dead, ", ", fn {n, _, a} -> "#{n}.#{a}" end)
  end

  # The point of the exercise. The daisyUI skin now ships no CSS at all — every rule was replaced
  # by classes in the gallery's own markup — so the property that has to hold is the one that made
  # that possible: every class name a component renders must sit in a class list that takes a
  # value. A consumer who copies an example cannot restyle a part that hard-codes its class.
  # Reachability is a property of the element, not of the attribute list: a part rendered per slot
  # entry is reached through that slot's own `class`, which no metadata can map back to a part
  # name. So read the elements.
  test "the retired daisyUI skin leaves no stylesheet behind" do
    refute File.exists?("assets/vendor/mishka_chelekom_headless_daisyui.css"),
           "the skin was retired, but its stylesheet is still on disk"
  end

  test "every class name a component renders sits in a class list that takes a value" do
    sources = Map.new(modules(), fn {name, _} -> {name, File.read!(source_path(name))} end)

    # `chelekom-sr-only` is a visually-hidden helper, not a stylable part: letting a caller
    # restyle it would let them reveal or break the screen-reader text.
    named =
      for {comp, src} <- sources,
          [_, cls] <- Regex.scan(~r/"(chelekom-[a-z0-9_-]+(?:__[a-z0-9_-]+)?)"/, src),
          cls != "chelekom-sr-only",
          do: {comp, cls}

    refute named == []

    unreachable =
      for {comp, cls} <- Enum.uniq(named),
          not reachable_class?(Map.fetch!(sources, comp), cls),
          do: "  #{comp}: #{cls}"

    assert unreachable == [],
           "these class names are rendered but nothing can add a class to them:\n" <>
             Enum.join(unreachable, "\n")
  end

  # The class attribute is written one of two ways. A literal string takes nothing and is a dead
  # end; a list is open, and only counts if it actually interpolates something. Match the list
  # lazily — `item[:class]` puts a `]` inside it, so a character class cannot find the end. A slot
  # entry reaches its class three ways: `@root_class`, `item[:class]`, or `grp.class`.
  defp reachable_class?(src, cls) do
    ~r/class=\{\[(.*?)\]\}/s
    |> Regex.scan(src)
    |> Enum.any?(fn [_, body] ->
      body =~ ~r/"#{Regex.escape(cls)}(\s[^"]*)?"/ and
        body =~ ~r/@[a-z0-9_]+|\[:[a-z0-9_]+\]|[a-z0-9_]+\.[a-z0-9_]*class\b/
    end)
  end
end
