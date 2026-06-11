defmodule MishkaChelekom.Kit.Catalog do
  @moduledoc """
  Reads the Mishka component catalog from the `mishka_chelekom` priv dir, for **compile-time** Kit
  validation (the verifier) and to decide whether a `customize`'s `from:` is a real component before
  generating its wrapper. Styled names come from `priv/components/*.exs`, headless from
  `priv/headless/*.exs`.
  """

  @doc "Known component names for a kind (`:styled` | `:headless`)."
  def names(:headless), do: list("headless")
  def names(:styled), do: list("components")

  @doc "Whether `name` is a real component of the given kind."
  def member?(kind, name), do: name in names(kind)

  @doc "The closest known name to `name` (for a \"did you mean?\" hint), or nil."
  def suggest(kind, name) do
    Enum.find(names(kind), &(String.jaro_distance(to_string(name), to_string(&1)) > 0.8))
  end

  defp list(dir) do
    [:code.priv_dir(:mishka_chelekom), dir, "*.exs"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(&String.to_atom(Path.basename(&1, ".exs")))
  end
end
