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

  def by_category do
    all() |> Enum.group_by(& &1.category) |> Enum.sort_by(fn {c, _} -> c end)
  end

  defp load(path) do
    name = Path.basename(path, ".exs")
    {term, _} = Code.eval_file(path)
    cfg = term[String.to_atom(name)]

    if cfg do
      aria = cfg[:aria_pattern] || []

      %{
        name: name,
        category: to_string(cfg[:category] || "other"),
        pattern: aria[:pattern] || "—",
        keyboard: aria[:keyboard] || [],
        focus: aria[:focus],
        anatomy: cfg[:anatomy] || [],
        hooks: cfg[:hooks] || [],
        state: cfg[:state_attributes] || [],
        doc_url: cfg[:doc_url],
        description: DevelopmentWeb.Showcase.Meta.headless_description(name),
        sibling: DevelopmentWeb.Showcase.Meta.styled_sibling(name)
      }
    end
  rescue
    _ -> nil
  end
end
