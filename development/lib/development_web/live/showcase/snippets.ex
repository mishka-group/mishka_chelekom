defmodule DevelopmentWeb.Showcase.Snippets do
  @moduledoc """
  Builds copy-pasteable snippets for a component page from its real catalog data: the live-usage
  tag, the `customize` block (styled), and the `skin` block (headless). All reuse the existing
  component — none build HTML from scratch.
  """

  @sample "Mishka Chelekom"

  @doc "The live `<.name attr=\"v\">…</.name>` usage for the current control selection (right column)."
  def usage(name, props, sample \\ @sample)
  def usage(name, props, _sample) when map_size(props) == 0, do: "<.#{name} />"

  def usage(name, props, sample) do
    attrs = props |> Enum.sort() |> Enum.map_join("\n", fn {k, v} -> "  " <> attr(k, v) end)
    "<.#{name}\n#{attrs}\n>\n  #{sample}\n</.#{name}>"
  end

  defp attr(k, v) when is_atom(v) and not is_boolean(v), do: "#{k}={#{inspect(v)}}"
  defp attr(k, v), do: ~s(#{k}="#{v}")

  @doc "A `customize` block for a styled component — add a new color/variant and restyle an existing one."
  def customize(%{name: name, dims: dims}) do
    color = Enum.find(dims, &(&1.key == "color"))
    variant = Enum.find(dims, &(&1.key == "variant"))
    existing = color && List.first(color.values)

    lines =
      [
        color && ~s(  #{color.attr} :brand, "bg-indigo-600 text-white"      # add a new color),
        color && existing &&
          ~s(  #{color.attr} :#{existing}, "…"                     # restyle an existing one),
        variant && ~s(  variant :glow, "shadow-[0_0_20px_currentColor]"   # add a new variant),
        ~s(  default #{color && "#{color.attr}: :brand"})
      ]
      |> Enum.reject(&(&1 in [nil, false]))

    "customize :#{name} do\n" <> Enum.join(lines, "\n") <> "\nend"
  end

  @doc "How to call the customized component (a same-named wrapper in your Kit module)."
  def customize_usage(%{name: name, dims: dims}) do
    color = Enum.find(dims, &(&1.key == "color"))

    call =
      if color,
        do: ~s(<.#{name} #{color.attr}={:brand}>#{@sample}</.#{name}>),
        else: ~s(<.#{name}>#{@sample}</.#{name}>)

    "# import MyAppWeb.Kit, then:\n#{call}"
  end

  @doc "A `customize` block for a headless component — `part` rules under a new name."
  def customize_headless(%{name: name, anatomy: anatomy}) do
    parts = (anatomy[:parts] || []) |> Keyword.keys() |> Enum.take(4)

    part_lines =
      case parts do
        [] -> ~s(  part :root, "…")
        ps -> Enum.map_join(ps, "\n", &~s(  part :#{&1}, "…"))
      end

    "customize :my_#{name} do\n  from :#{name}\n#{part_lines}\nend"
  end

  def customize_headless(%{name: name}), do: "customize :my_#{name} do\n  from :#{name}\n  part :…, \"…\"\nend"
end
