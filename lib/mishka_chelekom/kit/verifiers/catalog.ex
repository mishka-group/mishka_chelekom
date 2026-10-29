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
      Enum.reduce_while(customizes, :ok, fn c, :ok -> halt_on_error(check_from(c, ns, module)) end)
    end
  end

  defp halt_on_error(:ok), do: {:cont, :ok}
  defp halt_on_error(error), do: {:halt, error}

  # Only well-formed customizes are checked (the Rules verifier handles mixed/empty ones), and only
  # under the default convention — a custom `components`/`headless` namespace owns its own modules.
  defp check_from(%Customize{name: name, rules: rules} = c, ns, module) do
    {dims, parts} = Enum.split_with(rules, &match?(%Rule{}, &1))
    kind = if parts != [], do: :headless, else: :styled

    cond do
      not catalog_component?(dims, parts, c.from, ns[kind]) -> :ok
      Catalog.member?(kind, c.from || name) -> :ok
      true -> not_found(c.from || name, name, kind, module)
    end
  end

  # Mixed or empty rules are left to the Rules verifier. An explicit {Module, :function} tuple, or
  # any `from` under a custom namespace, is the user's own module — not a catalog component.
  defp catalog_component?([], [], _from, _ns), do: false
  defp catalog_component?([_ | _], [_ | _], _from, _ns), do: false
  defp catalog_component?(_dims, _parts, from, _ns) when is_tuple(from), do: false
  defp catalog_component?(_dims, _parts, _from, ns), do: is_nil(ns)

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
