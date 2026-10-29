defmodule MishkaChelekom.HeadlessEditorSurfaceTest do
  @moduledoc """
  The headless editor's functional styling is Tailwind classes on its own root and surface.

  The surface must fill its box, take no outline, keep ProseMirror's `white-space` and draw the
  placeholder of an empty document. Those rules are classes on the editor's parts, listed after
  each part's marker class and before the caller's `*_class`, so the headless stylesheet keeps no
  editor rule and does not style the editor a second time.
  """
  use ExUnit.Case, async: true

  @template Application.app_dir(:mishka_chelekom, "priv/headless/editor.eex")
  @stylesheet Application.app_dir(
                :mishka_chelekom,
                "priv/assets/css/mishka_chelekom_headless.css"
              )

  @parts [
    {"chelekom-editor", ~w|group/editor|},
    {"chelekom-editor__surface",
     ~w|flex flex-col *:min-w-0 *:flex-auto [&_.milkdown]:flex [&_.milkdown]:flex-col| ++
       ~w|[&_.ProseMirror]:flex-auto [&_.ProseMirror]:[outline:none] [&_.cm-editor]:[outline:none]!| ++
       ~w|[&_.ProseMirror]:whitespace-pre-wrap [&_.ProseMirror]:[word-break:break-word]| ++
       ~w|group-data-empty/editor:[&_.ProseMirror]:before:content-[attr(data-placeholder)]| ++
       ~w|group-data-empty/editor:[&_[data-part=lexical-content]]:before:content-[attr(data-placeholder)]|}
  ]

  # Every occurrence of the part's class list: the marker's own string and the strings after it,
  # up to the first caller-supplied value.
  defp own_classes(marker) do
    source = File.read!(@template)

    for [_, inline, following] <-
          Regex.scan(~r/"#{Regex.escape(marker)}((?:\s[^"]*)?)"((?:,\s*"[^"]*")*)/, source) do
      strings = ~r/"([^"]*)"/ |> Regex.scan(following, capture: :all_but_first) |> List.flatten()
      Enum.flat_map([inline | strings], &String.split/1)
    end
  end

  for {marker, classes} <- @parts do
    test "#{marker} carries its functional classes" do
      lists = own_classes(unquote(marker))

      assert lists != [], "#{unquote(marker)} is not in editor.eex"

      for own <- lists, class <- unquote(classes) do
        assert class in own, "#{unquote(marker)} lacks #{class}: #{inspect(own)}"
      end
    end
  end

  describe "the headless stylesheet" do
    setup do
      %{css: File.read!(@stylesheet)}
    end

    test "has no editor rule", %{css: css} do
      for name <- ~w(chelekom-editor ProseMirror cm-editor milkdown lexical-content) do
        refute css =~ name, "the stylesheet still styles #{name}"
      end
    end

    test "keeps its rules for the other headless components", %{css: css} do
      for rule <- [
            ".chelekom-dialog__popup[data-closed]",
            ".chelekom-drawer__popup[data-side=\"right\"]",
            ".chelekom-select__option:not([data-selected]) .chelekom-select__indicator",
            ".chelekom-sr-only",
            "@keyframes chelekom-nm-right"
          ] do
        assert css =~ rule, "the stylesheet lost #{rule}"
      end
    end
  end
end
