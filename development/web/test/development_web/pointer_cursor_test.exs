defmodule DevelopmentWeb.PointerCursorTest do
  @moduledoc """
  A button on a showcase page shows the pointer.

  Tailwind v3's preflight gave `button` and `[role=button]` `cursor: pointer`; v4's does not. The
  generated components carry the class themselves (the library's `TailwindV4ClassesTest` reads
  their templates), but a page's own buttons and the buttons a page puts inside a component's
  slot do not, so the pages are read here. The Base UI and daisyUI example catalogs reproduce those
  design systems, whose buttons set their own cursor, and are left out.
  """
  use ExUnit.Case, async: true

  @catalogs ~w(headless_baseui_examples.ex headless_daisyui_examples.ex)

  @pages for path <- Path.wildcard(Path.expand("../../lib/development_web/**/*.ex", __DIR__)),
             not String.contains?(path, "/lib/development_web/components/"),
             Path.basename(path) not in @catalogs,
             do: path

  defp opening_tags(text) do
    for [{start, _length}] <- Regex.scan(~r/<[a-z][a-z0-9]*\b/, text, return: :index) do
      rest = binary_part(text, start, byte_size(text) - start)
      binary_part(rest, 0, tag_end(rest, 0, 0, nil) + 1)
    end
  end

  defp tag_end(<<>>, position, _depth, _quote), do: max(position - 1, 0)

  defp tag_end(<<char, rest::binary>>, position, depth, quote) when quote == char,
    do: tag_end(rest, position + 1, depth, nil)

  defp tag_end(<<_char, rest::binary>>, position, depth, quote) when not is_nil(quote),
    do: tag_end(rest, position + 1, depth, quote)

  defp tag_end(<<char, rest::binary>>, position, depth, nil) when char in [?", ?'],
    do: tag_end(rest, position + 1, depth, char)

  defp tag_end(<<?{, rest::binary>>, position, depth, nil),
    do: tag_end(rest, position + 1, depth + 1, nil)

  defp tag_end(<<?}, rest::binary>>, position, depth, nil),
    do: tag_end(rest, position + 1, depth - 1, nil)

  defp tag_end(<<?>, _rest::binary>>, position, 0, nil), do: position

  defp tag_end(<<_char, rest::binary>>, position, depth, nil),
    do: tag_end(rest, position + 1, depth, nil)

  defp clickable?(tag) do
    String.starts_with?(tag, "<button") or String.contains?(tag, ~s(role="button"))
  end

  defp without_pointer(text) do
    for tag <- opening_tags(text),
        clickable?(tag),
        not String.contains?(tag, "cursor-pointer"),
        do: tag |> String.replace(~r/\s+/, " ") |> String.slice(0, 100)
  end

  test "there are pages to read" do
    assert length(@pages) > 50
  end

  test "every button and role=button on a page has cursor-pointer" do
    found =
      for path <- @pages,
          tag <- without_pointer(File.read!(path)),
          do: "#{Path.relative_to_cwd(path)}: #{tag}"

    assert Enum.take(found, 20) == []
  end

  test "reads a button without the class" do
    assert without_pointer(~s(<button type="button" class="group shrink-0 p-1 -m-1">)) != []
    assert without_pointer(~s(<div role="button" class={["a", @b]}>)) != []
    assert without_pointer(~s(<button class="p-1 cursor-pointer">)) == []
    assert without_pointer(~s(<a class="p-1">)) == []
  end
end
