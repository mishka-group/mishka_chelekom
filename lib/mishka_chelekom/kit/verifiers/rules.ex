defmodule MishkaChelekom.Kit.Verifiers.Rules do
  @moduledoc """
  Compile-time guards for each `customize`:
    * it must declare at least one `color`/`variant`/…/`part` rule (else it's a no-op);
    * it may not mix styled rules (`color`/`variant`/…) with a `part` rule — that would mean
      customizing a styled and a headless component at once.

  See `MishkaChelekom.Kit.Dsl`, `MishkaChelekom.Kit.Entities.Customize`, and the sibling
  `MishkaChelekom.Kit.Verifiers.Catalog`.
  """
  use Spark.Dsl.Verifier

  alias MishkaChelekom.Kit.Entities.{Rule, Customize}
  alias Spark.Dsl.Verifier

  @impl true
  def verify(dsl_state) do
    dsl_state
    |> Verifier.get_entities([:ui])
    |> Enum.reduce_while(:ok, fn %Customize{name: name, rules: rules}, :ok ->
      {dims, parts} = Enum.split_with(rules, &match?(%Rule{}, &1))

      cond do
        dims != [] and parts != [] ->
          {:halt,
           err(
             dsl_state,
             name,
             "mixes styled rules (color/variant/…) with `part` — a customize targets one component, styled OR headless"
           )}

        dims == [] and parts == [] ->
          {:halt,
           err(dsl_state, name, "declares no rules — add at least one color/variant/size/part")}

        true ->
          {:cont, :ok}
      end
    end)
  end

  defp err(dsl_state, name, message) do
    {:error,
     Spark.Error.DslError.exception(
       module: Verifier.get_persisted(dsl_state, :module),
       message: "customize #{inspect(name)} #{message}",
       path: [:ui, :customize, name]
     )}
  end
end
