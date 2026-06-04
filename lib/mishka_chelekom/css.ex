defmodule MishkaChelekom.CSS do
  @moduledoc """
  Tailwind-aware class composition with a **swappable merge seam** (Layer 3).

  `classes/1` flattens nested/conditional class inputs (the same shapes HEEx accepts) into a
  single deduplicated string — last occurrence wins, so a caller's `@class` reliably overrides
  defaults. This is the zero-dependency built-in default.

  For real Tailwind conflict resolution (e.g. `px-2` vs `px-4`), point the seam at a
  `tailwind_merge`-style library:

      config :mishka_chelekom, :class_merger, {TailwindMerge, :merge, 1}

  The configured merger is resolved at runtime via `Application.get_env/3`; when unset, the
  built-in `dedupe/1` is used. This mirrors Pyro's approach and keeps the dependency optional.
  """

  @type input :: String.t() | [input] | nil | false | {boolean(), input}

  @doc """
  Flattens and merges class inputs into a single class string.

  Accepts strings, nested lists, `nil`/`false` (dropped), and `{condition, classes}` tuples.

      iex> MishkaChelekom.CSS.classes(["px-2 py-1", nil, {true, "font-bold"}, {false, "hidden"}])
      "px-2 py-1 font-bold"
  """
  @spec classes(input) :: String.t()
  def classes(input) do
    input
    |> flatten()
    |> Enum.join(" ")
    |> merge()
  end

  @doc """
  Runs the configured class merger over a space-separated class string. Defaults to
  `dedupe/1` (token de-duplication, last wins) when no `:class_merger` is configured.
  """
  @spec merge(String.t()) :: String.t()
  def merge(class_string) when is_binary(class_string) do
    case Application.get_env(:mishka_chelekom, :class_merger) do
      {mod, fun, 1} -> apply(mod, fun, [class_string])
      fun when is_function(fun, 1) -> fun.(class_string)
      _ -> dedupe(class_string)
    end
  end

  @doc """
  Built-in default merger: collapses whitespace and removes exact duplicate tokens, keeping
  the **last** occurrence so later (caller) classes win. Does not resolve Tailwind utility
  conflicts — adopt `tailwind_merge` via the seam for that.
  """
  @spec dedupe(String.t()) :: String.t()
  def dedupe(class_string) when is_binary(class_string) do
    class_string
    |> String.split(~r/\s+/, trim: true)
    |> Enum.reverse()
    |> Enum.uniq()
    |> Enum.reverse()
    |> Enum.join(" ")
  end

  defp flatten(nil), do: []
  defp flatten(false), do: []
  defp flatten(str) when is_binary(str), do: [String.trim(str)] |> Enum.reject(&(&1 == ""))
  defp flatten({cond?, value}), do: if(cond?, do: flatten(value), else: [])
  defp flatten(list) when is_list(list), do: Enum.flat_map(list, &flatten/1)
  defp flatten(_), do: []
end
