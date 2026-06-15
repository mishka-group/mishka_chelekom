defmodule DevelopmentWeb.Showcase.ExampleSource do
  @moduledoc false

  @doc """
  Returns the `~H` markup of an examples module's `example(%{section: id})` clause,
  dedented for display, or `nil` when it can't be extracted (e.g. the clause delegates
  to a helper instead of inlining `~H`).
  """
  def code(mod, section_id) when is_atom(mod) and is_binary(section_id) do
    with src when is_binary(src) <- read_source(mod),
         body when is_binary(body) <- extract(src, section_id) do
      dedent(body)
    else
      _ -> nil
    end
  end

  def code(_, _), do: nil

  defp read_source(mod) do
    with path when not is_nil(path) <- mod.module_info(:compile)[:source],
         {:ok, src} <- File.read(to_string(path)) do
      src
    else
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp extract(src, section_id) do
    re =
      ~r/def example\(%\{section:\s*"#{Regex.escape(section_id)}"\}(?:(?!\n  def ).)*?~H"""\r?\n(.*?)\r?\n[ \t]*"""/s

    case Regex.run(re, src) do
      [_, body] -> body
      _ -> nil
    end
  end

  defp dedent(text) do
    lines = String.split(text, "\n")

    min =
      lines
      |> Enum.reject(&(String.trim(&1) == ""))
      |> Enum.map(&(String.length(&1) - String.length(String.trim_leading(&1))))
      |> Enum.min(fn -> 0 end)

    lines
    |> Enum.map(fn
      line -> if String.trim(line) == "", do: "", else: String.slice(line, min..-1//1)
    end)
    |> Enum.join("\n")
    |> String.trim_trailing()
  end
end
