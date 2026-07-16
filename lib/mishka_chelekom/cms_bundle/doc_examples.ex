defmodule MishkaChelekom.CmsBundle.DocExamples do
  @moduledoc """
  Harvest the fenced snippets out of a component function's `@doc`
  `## Examples` section.

  These are the kit author's own canonical invocations — minimal, free
  of demo-page scaffolding, and written per function — which makes them
  the best source for a component's **base** example. 106 of the kit's
  132 public component functions carry one.

  Input is the `@doc` string of the **rendered** module (the exporter
  EEx-evals the `.eex` with all-options assigns before parsing), so
  `<.<%= @component_prefix %>card>` has already collapsed to `<.card>`.

  Returns raw HEEx snippets. Rewriting them to the runtime
  `<.component component_name=…/>` form is the caller's job — it needs
  the kit-wide component set, which this module has no business knowing.
  """

  @fence ~r/^[ \t]*```(?:elixir|heex)?[ \t]*\n(?<body>.*?)^[ \t]*```[ \t]*$/ms

  @doc """
  Fenced snippets from `doc`'s `## Examples` section that actually
  invoke `fn_name`. Returns `[]` for a nil/blank doc, a doc with no
  `## Examples` section, or a section whose fences never mention
  `fn_name`.
  """
  @spec from_doc(String.t() | nil, atom() | String.t()) :: [String.t()]
  def from_doc(nil, _fn_name), do: []

  def from_doc(doc, fn_name) when is_binary(doc) do
    doc
    |> examples_section()
    |> code_blocks()
    |> Enum.filter(&invokes?(&1, fn_name))
  end

  def from_doc(_doc, _fn_name), do: []

  # Everything between `## Examples` and the next same-level heading.
  defp examples_section(doc) do
    case Regex.run(~r/^[ \t]*##[ \t]+Examples[ \t]*$/m, doc, return: :index) do
      nil ->
        ""

      [{start, len}] ->
        rest = binary_part(doc, start + len, byte_size(doc) - start - len)

        case Regex.run(~r/^[ \t]*##[ \t]+\S/m, rest, return: :index) do
          nil -> rest
          [{next, _}] -> binary_part(rest, 0, next)
        end
    end
  end

  # Most sections fence their snippets; `back`, `icon` and `input` use a
  # plain 4-space markdown code block instead. Fences win when present.
  defp code_blocks(""), do: []

  defp code_blocks(text) do
    case fenced_blocks(text) do
      [] -> indented_blocks(text)
      blocks -> blocks
    end
  end

  defp fenced_blocks(text) do
    @fence
    |> Regex.scan(text, capture: ["body"])
    |> Enum.map(fn [body] -> String.trim(body) end)
    |> Enum.reject(&(&1 == ""))
  end

  defp indented_blocks(text) do
    text
    |> String.split("\n")
    |> Enum.chunk_by(&indented?/1)
    |> Enum.filter(&Enum.any?(&1, fn line -> indented?(line) and String.trim(line) != "" end))
    |> Enum.map(&(&1 |> Enum.map_join("\n", fn line -> dedent(line) end) |> String.trim()))
    |> Enum.reject(&(&1 == ""))
  end

  # A blank line does not end an indented block.
  defp indented?(line), do: String.trim(line) == "" or String.starts_with?(line, "    ")

  defp dedent("    " <> rest), do: rest
  defp dedent(line), do: line

  # `<.card` must not match `<.card_title`.
  defp invokes?(block, fn_name) do
    Regex.match?(~r/<\.#{Regex.escape(to_string(fn_name))}(?![A-Za-z0-9_])/, block)
  end
end
