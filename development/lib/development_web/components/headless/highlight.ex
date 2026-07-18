defmodule DevelopmentWeb.Components.Headless.Highlight do
  @moduledoc """
  Headless **highlight** — highlight occurrences of a query within text (Mantine Highlight parity).

  Splits `text` at case-insensitive matches of `highlight` (a string or a list of strings) at
  **render time** and wraps each match in a `<mark data-part="mark">` — no JS. The surrounding text
  is escaped normally. Style the mark via `chelekom-highlight__mark`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/highlight
  """
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: "Optional unique id"
  attr :text, :string, required: true, doc: "The full text"

  attr :highlight, :any,
    required: true,
    doc: "Substring(s) to highlight — a string or a list of strings"

  attr :class, :any, default: nil, doc: "Extra classes for the wrapper"
  attr :mark_class, :any, default: nil, doc: "Extra classes for each <mark>"
  attr :rest, :global

  def highlight(assigns) do
    assigns = assign(assigns, :parts, highlight_parts(assigns.text, List.wrap(assigns.highlight)))

    ~H"""
    <span id={@id} class={["chelekom-highlight", @class]} {@rest}><.hl_part
      :for={p <- @parts}
      part={p}
      mark_class={@mark_class}
    /></span>
    """
  end

  attr :part, :any, required: true
  attr :mark_class, :any, default: nil

  defp hl_part(%{part: {:mark, _}} = assigns) do
    assigns = assign(assigns, :str, elem(assigns.part, 1))

    ~H"""
    <mark data-part="mark" class={["chelekom-highlight__mark", @mark_class]}>{@str}</mark>
    """
  end

  defp hl_part(assigns), do: ~H"{elem(@part, 1)}"

  defp highlight_parts(text, queries) do
    queries = Enum.reject(queries, &(&1 in [nil, ""]))

    if queries == [] do
      [{:text, text}]
    else
      pattern = queries |> Enum.map(&Regex.escape/1) |> Enum.join("|")
      re = Regex.compile!("(" <> pattern <> ")", "iu")
      match_re = Regex.compile!("\\A(?:" <> pattern <> ")\\z", "iu")

      re
      |> Regex.split(text, include_captures: true, trim: false)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(fn s -> if Regex.match?(match_re, s), do: {:mark, s}, else: {:text, s} end)
    end
  end
end
