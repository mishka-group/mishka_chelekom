defmodule DevelopmentWeb.Showcase.HeadlessCatalog do
  @moduledoc """
  Loads headless component metadata at runtime from the library's `priv/headless/*.exs`, so
  the headless showcase auto-discovers every generated component (no hardcoded list).
  """

  def dir, do: Path.join(:code.priv_dir(:mishka_chelekom), "headless")

  def all do
    dir()
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.map(&load/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.name)
  end

  def get(name) when is_binary(name), do: Enum.find(all(), &(&1.name == name))

  @doc "The previous and next headless components around `name` (name-sorted order); nil at the ends."
  def neighbors(name) do
    list = all()

    case Enum.find_index(list, &(&1.name == name)) do
      nil -> {nil, nil}
      0 -> {nil, Enum.at(list, 1)}
      i -> {Enum.at(list, i - 1), Enum.at(list, i + 1)}
    end
  end

  def by_category do
    all() |> Enum.group_by(& &1.category) |> Enum.sort_by(fn {c, _} -> c end)
  end

  defp load(path) do
    name = Path.basename(path, ".exs")
    {term, _} = Code.eval_file(path)
    cfg = term[String.to_atom(name)]

    if cfg do
      # headless-only doc metadata (anatomy/aria_pattern/state_attributes/hooks) lives under `:headless`
      hl = cfg[:headless] || []
      aria = hl[:aria_pattern] || []

      %{
        name: name,
        category: to_string(cfg[:category] || "other"),
        pattern: aria[:pattern] || "—",
        keyboard: aria[:keyboard] || [],
        focus: aria[:focus],
        anatomy: hl[:anatomy] || [],
        hooks: hl[:hooks] || [],
        state: hl[:state_attributes] || [],
        doc_url: cfg[:doc_url],
        spec_url: cfg[:spec_url],
        description: DevelopmentWeb.Showcase.Meta.headless_description(name),
        sibling: DevelopmentWeb.Showcase.Meta.styled_sibling(name)
      }
    end
  rescue
    _ -> nil
  end
end
