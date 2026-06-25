defmodule DevelopmentWeb.Showcase.HeadlessApi do
  @moduledoc """
  Derives a headless component's public API straight from its template
  (`priv/headless/<name>.eex`): the `attr`/`slot` declarations, and a synthesized **direct-call**
  usage snippet (`<.popover id="…"><:trigger>…</:trigger>…</.popover>`) — i.e. how you actually
  use the generated unstyled component in a Phoenix template, independent of the demo styling.
  """

  alias DevelopmentWeb.Showcase.HeadlessCatalog

  @doc "Parsed `%{attrs: [...], slots: [...]}` for a headless component (UI-table shaped)."
  def parse(name) do
    case read(name) do
      nil -> %{attrs: [], slots: []}
      src -> %{attrs: parse_attrs(src), slots: parse_slots(src)}
    end
  end

  @doc "A copy-pasteable direct-call usage snippet for the component."
  def usage(name) do
    %{slots: slots} = parse(name)

    body =
      slots
      |> Enum.reject(&(&1.name in ~w(inner_block)))
      |> Enum.map(fn s -> "  <:#{s.name}>#{humanize(s.name)}</:#{s.name}>" end)

    inner =
      case Enum.find(slots, &(&1.name == "inner_block")) do
        nil -> []
        s -> ["  #{s.doc || "Content"}"]
      end

    lines = body ++ inner

    if lines == [] do
      ~s(<.#{name} id="#{name}-1" />)
    else
      "<.#{name} id=\"#{name}-1\">\n" <> Enum.join(lines, "\n") <> "\n</.#{name}>"
    end
  end

  @doc "The generated module a headless component lands in, for the import line."
  def module(name) do
    "MyAppWeb.Components.Headless." <>
      (name |> String.split("_") |> Enum.map_join(&String.capitalize/1))
  end

  defp read(name) do
    path = Path.join([:code.priv_dir(:mishka_chelekom), "headless", "#{name}.eex"])
    if File.exists?(path), do: File.read!(path)
  rescue
    _ -> nil
  end

  defp parse_attrs(src) do
    ~r/^\s*attr\s+:(\w+)\s*,\s*([^\s,]+)\s*(?:,\s*(.*?))?\s*$/m
    |> Regex.scan(src)
    |> Enum.map(fn
      [_, name, type, opts] -> attr(name, type, opts)
      [_, name, type] -> attr(name, type, "")
    end)
    |> Enum.reject(&(&1.name in ~w(rest)))
  end

  defp parse_slots(src) do
    ~r/^\s*slot\s+:(\w+)\s*(?:,\s*(.*?))?\s*(?:do)?\s*$/m
    |> Regex.scan(src)
    |> Enum.map(fn
      [_, name, opts] -> %{name: name, required: opts =~ ~r/required:\s*true/, doc: doc(opts)}
      [_, name] -> %{name: name, required: false, doc: nil}
    end)
  end

  defp attr(name, type, opts) do
    %{
      name: name,
      type: String.trim_leading(type, ":"),
      default: default(opts),
      values: values(opts),
      doc: doc(opts)
    }
  end

  defp doc(opts) do
    case Regex.run(~r/doc:\s*"([^"]*)"/, opts || "") do
      [_, d] -> d
      _ -> nil
    end
  end

  defp default(opts) do
    case Regex.run(~r/default:\s*("[^"]*"|[^\s,]+)/, opts || "") do
      [_, "nil"] -> nil
      [_, v] -> String.trim(v, "\"")
      _ -> nil
    end
  end

  defp values(opts) do
    cond do
      m = Regex.run(~r/values:\s*~w\(([^)]*)\)/, opts || "") ->
        String.split(Enum.at(m, 1))

      m = Regex.run(~r/values:\s*\[([^\]]*)\]/, opts || "") ->
        Regex.scan(~r/"([^"]*)"/, Enum.at(m, 1)) |> Enum.map(&Enum.at(&1, 1))

      true ->
        nil
    end
  end

  defp humanize(name), do: name |> String.replace("_", " ") |> String.capitalize()

  def for_component(%{name: name}), do: parse(name)
  def for_component(name) when is_binary(name), do: parse(name)
  def known?(name), do: HeadlessCatalog.get(name) != nil
end
