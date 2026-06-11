defmodule MishkaChelekom.Kit.Verifiers.Catalog do
  @moduledoc """
  Compile-time checks against the real Mishka catalog (via `MishkaChelekom.Kit.Catalog`):
    * `from:` must be a real component of the right kind (styled vs headless, inferred from the
      rules), with a "did you mean?" suggestion — skipped when a custom `components`/`headless`
      namespace is configured (those modules are the user's own);
    * no two `customize`s may generate the same component name.

  Catches typos at **compile time** instead of an `UndefinedFunctionError` at render time. See
  `MishkaChelekom.Kit.Dsl` and the sibling `MishkaChelekom.Kit.Verifiers.Rules`.
  """
  use Spark.Dsl.Verifier

  alias MishkaChelekom.Kit.Catalog
  alias MishkaChelekom.Kit.Entities.{Rule, Customize}
  alias Spark.Dsl.Verifier

  @impl true
  def verify(dsl_state) do
    module = Verifier.get_persisted(dsl_state, :module)
    customizes = Verifier.get_entities(dsl_state, [:ui])

    ns = %{
      styled: Verifier.get_option(dsl_state, [:ui], :components),
      headless: Verifier.get_option(dsl_state, [:ui], :headless)
    }

    with :ok <- no_clashes(customizes, module) do
      Enum.reduce_while(customizes, :ok, fn c, :ok ->
        case check_from(c, ns, module) do
          :ok -> {:cont, :ok}
          error -> {:halt, error}
        end
      end)
    end
  end

  # Only well-formed customizes are checked (the Rules verifier handles mixed/empty ones), and only
  # under the default convention — a custom `components`/`headless` namespace owns its own modules.
  defp check_from(%Customize{name: name, rules: rules} = c, ns, module) do
    {dims, parts} = Enum.split_with(rules, &match?(%Rule{}, &1))
    kind = if parts != [], do: :headless, else: :styled

    cond do
      dims == [] and parts == [] -> :ok
      dims != [] and parts != [] -> :ok
      ns[kind] != nil -> :ok
      Catalog.member?(kind, c.from || name) -> :ok
      true -> not_found(c.from || name, name, kind, module)
    end
  end

  defp not_found(from, name, kind, module) do
    hint = if m = Catalog.suggest(kind, from), do: ". Did you mean #{inspect(m)}?", else: ""

    {:error,
     Spark.Error.DslError.exception(
       module: module,
       path: [:ui, :customize, name],
       message:
         "customize #{inspect(name)}: `from: #{inspect(from)}` is not a #{kind} Mishka component#{hint}"
     )}
  end

  defp no_clashes(customizes, module) do
    names = Enum.map(customizes, & &1.name)

    case names -- Enum.uniq(names) do
      [] ->
        :ok

      [dup | _] ->
        {:error,
         Spark.Error.DslError.exception(
           module: module,
           path: [:ui],
           message: "two customizes both generate #{inspect(dup)} — give one a different name"
         )}
    end
  end
end
