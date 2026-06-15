defmodule MishkaChelekom.Kit.Transformers.Generate do
  @moduledoc """
  Generates each `customize`'s wrapper function from its rules, injected into the Kit module via
  `Spark.Dsl.Transformer.eval/3`. The rules decide the target: `part` rules ⇒ a headless component
  (`<Web>.Components.Headless.<From>`), otherwise styled (`<Web>.Components.<From>`). The wrapper
  transforms `assigns` through `MishkaChelekom.Kit.Runtime` and delegates to the real component.
  """
  use Spark.Dsl.Transformer

  alias MishkaChelekom.Kit.Catalog
  alias MishkaChelekom.Kit.Entities.{Rule, Customize}
  alias Spark.Dsl.Transformer

  @impl true
  def transform(dsl_state) do
    module = Transformer.get_persisted(dsl_state, :module)

    ns = %{
      styled: Transformer.get_option(dsl_state, [:ui], :components),
      headless: Transformer.get_option(dsl_state, [:ui], :headless)
    }

    dsl_state =
      dsl_state
      |> Transformer.get_entities([:ui])
      |> Enum.reduce(dsl_state, fn %Customize{} = c, dsl -> gen(dsl, module, ns, c) end)

    {:ok, dsl_state}
  end

  defp gen(
         dsl,
         module,
         ns,
         %Customize{name: name, rules: rules, base: base, default: default} = c
       ) do
    from = c.from || name
    {dims, parts} = Enum.split_with(rules, &match?(%Rule{}, &1))

    case kind(dims, parts) do
      # no rules or mixed styled+part — skip generation; the verifier reports the clean error
      nil ->
        dsl

      kind ->
        namespace = ns[kind]

        # unknown `from` under the default convention — skip so the verifier's "did you mean?" is the
        # only error (no noisy undefined-function from a wrapper pointing at a non-existent module)
        if is_nil(namespace) and not Catalog.member?(kind, from) do
          dsl
        else
          real = resolve(namespace, module, segments(kind), from)
          spec = Macro.escape(build_spec(dims, parts, base, default))

          Transformer.eval(
            dsl,
            [],
            quote do
              def unquote(name)(assigns) do
                unquote(real).unquote(from)(
                  MishkaChelekom.Kit.Runtime.transform(assigns, unquote(spec))
                )
              end
            end
          )
        end
    end
  end

  defp kind([], []), do: nil
  defp kind(_dims, []), do: :styled
  defp kind([], _parts), do: :headless
  defp kind(_dims, _parts), do: nil

  defp segments(:headless), do: ["Components", "Headless"]
  defp segments(:styled), do: ["Components"]

  defp build_spec(dims, parts, base, default) do
    # A rule with a variant×color partner is a PAIR rule (matches only that combo); the rest are
    # single-value rules. Classes are VERBATIM in both — write them whole (incl. a trailing `!` for
    # precedence). No transform, so Tailwind scans them straight from your `kit.ex` — no safelist.
    {paired, singles} = Enum.split_with(dims, &paired?/1)

    attrs =
      case singles do
        [] ->
          nil

        _ ->
          singles
          |> Enum.group_by(& &1.attr)
          |> Map.new(fn {a, rs} ->
            {a, Map.new(rs, &{to_string(&1.value), &1.classes})}
          end)
      end

    # Pair rules: an ordered list of {match-map, classes}. The match-map is a string→string map of
    # the dimensions the rule pins (e.g. %{"variant" => "bordered", "color" => "danger"}); the
    # runtime applies the first whose every key matches the assigns.
    pairs =
      case paired do
        [] -> nil
        _ -> Enum.map(paired, &%{match: match_map(&1), classes: &1.classes})
      end

    # Part classes are also verbatim — write the full `[&_[data-part=name]]:` variant in your Kit.
    class =
      case parts do
        [] -> nil
        _ -> Enum.map_join(parts, " ", & &1.classes)
      end

    %{attrs: attrs, pairs: pairs, class: class, base: base, default: default}
  end

  # A rule is paired when it pins a partner on the OTHER axis (a `variant` rule with `color:`, or a
  # `color` rule with `variant:`). A partner equal to the rule's own attr is ignored (redundant).
  defp paired?(%Rule{attr: attr, color: color, variant: variant}) do
    (color != nil and attr != :color) or (variant != nil and attr != :variant)
  end

  defp match_map(%Rule{attr: attr, value: value} = r) do
    %{to_string(attr) => to_string(value)}
    |> add_partner(attr, :color, r.color)
    |> add_partner(attr, :variant, r.variant)
  end

  defp add_partner(map, attr, key, val) when val != nil and attr != key,
    do: Map.put(map, to_string(key), to_string(val))

  defp add_partner(map, _attr, _key, _val), do: map

  # Resolve the real component module: an explicit namespace (from `components`/`headless` options)
  # wins; otherwise convention from the Kit module's web namespace.
  defp resolve(nil, kit_module, segments, name) do
    web = kit_module |> Module.split() |> Enum.drop(-1)
    Module.concat(web ++ segments ++ [Macro.camelize(to_string(name))])
  end

  defp resolve(namespace, _kit_module, _segments, name) do
    Module.concat([namespace, Macro.camelize(to_string(name))])
  end
end
