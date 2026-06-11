defmodule MishkaChelekom.Kit.Transformers.Generate do
  @moduledoc """
  Generates each `customize`'s wrapper function from its rules, injected into the Kit module via
  `Spark.Dsl.Transformer.eval/3`. The rules decide the target: `part` rules ⇒ a headless component
  (`<Web>.Components.Headless.<From>`), otherwise styled (`<Web>.Components.<From>`). The wrapper
  transforms `assigns` through `MishkaChelekom.Kit.Runtime` and delegates to the real component.
  """
  use Spark.Dsl.Transformer

  alias MishkaChelekom.Kit.{Runtime, Catalog}
  alias MishkaChelekom.Kit.Entities.{Rule, Part, Customize}
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
    attrs =
      case dims do
        [] ->
          nil

        _ ->
          dims
          |> Enum.group_by(& &1.attr)
          # precompute the `!important` form here (compile time) instead of per-render
          |> Map.new(fn {a, rs} ->
            {a, Map.new(rs, &{to_string(&1.value), Runtime.important(&1.classes)})}
          end)
      end

    class =
      case parts do
        [] -> nil
        _ -> Enum.map_join(parts, " ", &part_variant/1)
      end

    %{attrs: attrs, class: class, base: base, default: default}
  end

  # "rounded p-3" for part :trigger → "[&_[data-part=trigger]]:rounded [&_[data-part=trigger]]:p-3"
  defp part_variant(%Part{name: name, classes: classes}) do
    prefix = "[&_[data-part=#{name}]]:"
    classes |> String.split() |> Enum.map_join(" ", &(prefix <> &1))
  end

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
