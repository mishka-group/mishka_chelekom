defmodule MishkaChelekom.Kit.Transformers.Generate do
  @moduledoc """
  Generates each `customize`'s wrapper function from its rules, injected into the Kit module via
  `Spark.Dsl.Transformer.eval/3`. The rules decide the target: `part` rules ⇒ a headless component
  (`<Web>.Components.Headless.<From>`), otherwise styled (`<Web>.Components.<From>`). The wrapper
  transforms `assigns` through `MishkaChelekom.Kit.Runtime` and delegates to the real component.
  """
  use Spark.Dsl.Transformer

  alias MishkaChelekom.Kit.{Rule, Part, Customize}
  alias Spark.Dsl.Transformer

  @impl true
  def transform(dsl_state) do
    module = Transformer.get_persisted(dsl_state, :module)

    dsl_state =
      dsl_state
      |> Transformer.get_entities([:ui])
      |> Enum.reduce(dsl_state, fn %Customize{} = c, dsl -> gen(dsl, module, c) end)

    {:ok, dsl_state}
  end

  defp gen(dsl, module, %Customize{name: name, rules: rules, base: base, default: default} = c) do
    from = c.from || name
    {dims, parts} = Enum.split_with(rules, &match?(%Rule{}, &1))

    real =
      if parts != [],
        do: convention(module, ["Components", "Headless"], from),
        else: convention(module, ["Components"], from)

    spec = build_spec(dims, parts, base, default)

    Transformer.eval(
      dsl,
      [],
      quote do
        def unquote(name)(assigns) do
          unquote(real).unquote(from)(
            MishkaChelekom.Kit.Runtime.transform(assigns, unquote(Macro.escape(spec)))
          )
        end
      end
    )
  end

  defp build_spec(dims, parts, base, default) do
    attrs =
      case dims do
        [] ->
          nil

        _ ->
          dims
          |> Enum.group_by(& &1.attr)
          |> Map.new(fn {a, rs} -> {a, Map.new(rs, &{to_string(&1.value), &1.classes})} end)
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

  # MyAppWeb.Kit + ["Components"] + :button → MyAppWeb.Components.Button
  defp convention(kit_module, segments, name) do
    web = kit_module |> Module.split() |> Enum.drop(-1)
    Module.concat(web ++ segments ++ [Macro.camelize(to_string(name))])
  end
end
