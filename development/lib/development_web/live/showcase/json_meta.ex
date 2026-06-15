defmodule DevelopmentWeb.Showcase.JsonMeta do
  @moduledoc """
  Reads the library's harvested metadata (`priv/components/chelekom.json`) and exposes, per styled
  component: its `attrs`, `slots`, real production `examples` (the actual `<.x …>` HEEx captured
  from the demo app), `dependencies` and `type`.

  This is what powers a component page's attribute table and "real examples" without anyone
  hand-writing them. Indexed by the component's function name (`extra.function`) and grouped by
  `extra.component` so a `button` page can also surface `button_group` examples.
  """

  @doc "Normalized attribute list for a component: `[%{name, type, default, values, doc}]`."
  def attrs(name) do
    case entry(name) do
      nil -> []
      e -> Enum.map(e["attrs"] || [], &norm_attr/1)
    end
  end

  @doc "Normalized slot list: `[%{name, required, doc, attrs}]`."
  def slots(name) do
    case entry(name) do
      nil -> []
      e -> Enum.map(e["slots"] || [], &norm_slot/1)
    end
  end

  @doc """
  Real, copy-pasteable HEEx examples for a component — dedented, deduped, and biased toward the
  shortest, cleanest snippets (the catalog can hold huge demo-page fragments with inline SVGs;
  those are only used as a last resort).
  """
  def examples(name, limit \\ 4) do
    raw =
      component_entries(name)
      |> Enum.flat_map(fn e -> get_in(e, ["extra", "demo_examples"]) || [] end)
      |> Enum.map(& &1["raw_source"])
      |> Enum.reject(&(is_nil(&1) or &1 == ""))
      |> Enum.map(&tidy/1)
      |> Enum.uniq()

    clean = Enum.filter(raw, &clean?(&1, name))
    pool = if clean == [], do: raw, else: clean

    pool
    |> Enum.sort_by(&String.length/1)
    |> Enum.take(limit)
  end

  defp clean?(s, name) do
    len = String.length(s)

    len >= 12 and len <= 700 and not String.contains?(s, "<svg") and
      String.contains?(s, "<.#{name}")
  end

  defp tidy(s) do
    case format_heex(s) do
      {:ok, formatted} -> formatted
      :error -> dedent(s)
    end
  end

  defp format_heex(s) do
    formatted =
      s
      |> Phoenix.LiveView.HTMLFormatter.format(line_length: 80)
      |> String.trim_trailing()

    if String.trim(formatted) == "", do: :error, else: {:ok, formatted}
  rescue
    _ -> :error
  catch
    _, _ -> :error
  end

  defp dedent(s) do
    lines = String.split(s, "\n")

    indent =
      lines
      |> Enum.reject(&(String.trim(&1) == ""))
      |> Enum.map(&(String.length(&1) - String.length(String.trim_leading(&1))))
      |> Enum.min(fn -> 0 end)

    lines
    |> Enum.map_join("\n", &String.slice(&1, indent..-1//1))
    |> String.trim_trailing()
  end

  @doc "Sibling component dependencies (e.g. button → [\"icon\"])."
  def dependencies(name) do
    case entry(name) do
      nil -> []
      e -> (e["dependencies"] || []) |> Enum.map(&String.replace_prefix(&1, "chelekom-", ""))
    end
  end

  @doc "The component's `type` (category) from the bundle metadata, or nil."
  def type(name), do: entry(name) && entry(name)["type"]

  defp entry(name) do
    idx = index()
    idx.by_function[name] || List.first(idx.by_component[name] || [])
  end

  defp component_entries(name) do
    idx = index()
    idx.by_component[name] || (idx.by_function[name] && [idx.by_function[name]]) || []
  end

  defp norm_attr(%{"name" => n, "type" => t} = a) do
    opts = a["opts"] || %{}

    %{
      name: n,
      type: t,
      default: format_default(opts["default"]),
      values: opts["values"],
      doc: opts["doc"]
    }
  end

  defp norm_slot(%{"name" => n} = s) do
    opts = s["opts"] || %{}

    %{
      name: n,
      required: opts["required"] == true,
      doc: opts["doc"],
      attrs: Enum.map(s["attrs"] || [], &norm_attr/1)
    }
  end

  defp format_default(nil), do: nil
  defp format_default(v) when is_binary(v), do: v
  defp format_default(v), do: inspect(v)

  defp index do
    case :persistent_term.get({__MODULE__, :index}, nil) do
      nil -> build_index() |> tap(&:persistent_term.put({__MODULE__, :index}, &1))
      idx -> idx
    end
  end

  defp build_index do
    entries =
      json_path()
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("components", [])

    by_function =
      for e <- entries, fun = get_in(e, ["extra", "function"]), into: %{}, do: {fun, e}

    by_component =
      entries
      |> Enum.group_by(fn e -> get_in(e, ["extra", "component"]) end)
      |> Map.delete(nil)

    %{by_function: by_function, by_component: by_component}
  rescue
    _ -> %{by_function: %{}, by_component: %{}}
  end

  defp json_path, do: Path.join([:code.priv_dir(:mishka_chelekom), "components", "chelekom.json"])
end
