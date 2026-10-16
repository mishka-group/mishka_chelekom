defmodule MishkaChelekom.HeadlessFunctionalClassesTest do
  @moduledoc """
  The headless components carry their functional styling as Tailwind classes on their own parts.

  The headless stylesheet keeps only what a class cannot say: the navigation menu's `@keyframes`
  and the page-indent rule for `[data-drawer-content]`, an element the app renders. Each part
  lists its classes after its marker class and before the caller's `*_class`, and the state that
  must hold whatever the caller adds (a closed popup hidden, a disabled item inert) is `!important`.
  """
  use ExUnit.Case, async: true

  @dir Path.expand("../../priv/headless", __DIR__)
  @stylesheet Path.expand("../../priv/assets/css/mishka_chelekom_headless.css", __DIR__)

  @dis ~w|data-disabled:pointer-events-none! data-disabled:opacity-50|

  @parts [
    {"alert_dialog", "chelekom-alert-dialog", ~w|group/alert-dialog contents|},
    {"alert_dialog", "chelekom-alert-dialog__backdrop",
     ~w|fixed inset-0 z-40 group-data-closed/alert-dialog:hidden!|},
    {"alert_dialog", "chelekom-alert-dialog__popup",
     ~w|fixed top-1/2 left-1/2 z-50 [transform:translate(-50%,-50%)] data-closed:hidden!|},
    {"dialog", "chelekom-dialog", ~w|group/dialog contents|},
    {"dialog", "chelekom-dialog__backdrop",
     ~w|fixed inset-0 z-40 group-data-closed/dialog:hidden!|},
    {"dialog", "chelekom-dialog__viewport",
     ~w|pointer-events-none fixed inset-0 z-50 grid place-items-center overflow-y-auto|},
    {"dialog", "chelekom-dialog__popup",
     ~w|pointer-events-auto relative max-h-[90vh] overflow-auto data-closed:hidden!|},
    {"drawer", "chelekom-drawer", ~w|group/drawer contents|},
    {"drawer", "chelekom-drawer__swipe-area", ~w|pointer-events-auto touch-none|},
    {"drawer", "chelekom-drawer__backdrop",
     ~w|fixed inset-0 z-40 data-swiping:duration-0 group-data-closed/drawer:opacity-0! group-data-closed/drawer:pointer-events-none!|},
    {"drawer", "chelekom-drawer__viewport",
     ~w|pointer-events-none fixed inset-0 z-50 overflow-hidden|},
    {"drawer", "chelekom-drawer__popup",
     ~w|pointer-events-auto absolute data-swiping:duration-0 data-swiping:select-none| ++
       ~w|data-[side=right]:data-closed:[transform:translateX(100%)] data-[side=left]:data-starting-style:[transform:translateX(-100%)]| ++
       ~w|data-[side=bottom]:data-ending-style:[transform:translateY(100%)] data-[side=top]:data-closed:[transform:translateY(-100%)]|},
    {"fab", "chelekom-fab__popup", ~w|data-closed:hidden!|},
    {"otp_field", "chelekom-otp_field", ~w|inline-flex gap-2|},
    {"popover", "chelekom-popover", ~w|group/popover relative|},
    {"popover", "chelekom-popover__backdrop",
     ~w|fixed inset-0 z-40 group-data-closed/popover:hidden!|},
    {"popover", "chelekom-popover__popup", ~w|fixed z-50 data-closed:hidden!|},
    {"tooltip", "chelekom-tooltip__popup", ~w|fixed z-50 data-closed:hidden!|},
    {"preview_card", "chelekom-preview_card__popup", ~w|fixed z-50 data-closed:hidden!|},
    {"menu", "chelekom-menu__popup", ~w|fixed z-50 data-closed:hidden!|},
    {"menu", "chelekom-menu__submenu-popup", ~w|fixed z-50 data-closed:hidden!|},
    {"menu", "chelekom-menu__indicator", ~w|data-unchecked:invisible!|},
    {"menu", "chelekom-menu__item", @dis},
    {"context_menu", "chelekom-context_menu__popup", ~w|fixed z-50 data-closed:hidden!|},
    {"context_menu", "chelekom-context_menu__submenu-popup", ~w|fixed z-50 data-closed:hidden!|},
    {"context_menu", "chelekom-context_menu__indicator", ~w|data-unchecked:invisible!|},
    {"context_menu", "chelekom-context_menu__item", @dis},
    {"menubar", "chelekom-menubar__menu", ~w|relative|},
    {"menubar", "chelekom-menubar__popup", ~w|absolute z-40 data-closed:hidden!|},
    {"select", "chelekom-select", ~w|relative|},
    {"select", "chelekom-select__popup", ~w|absolute z-40 data-closed:hidden!|},
    {"select", "chelekom-select__option", ["group/select-option" | @dis]},
    {"select", "chelekom-select__indicator",
     ~w|group-not-data-selected/select-option:invisible!|},
    {"combobox", "chelekom-combobox__popup", ~w|absolute z-40 data-closed:hidden!|},
    {"combobox", "chelekom-combobox__item", ["data-hidden:hidden!" | @dis]},
    {"combobox", "chelekom-combobox__group", ~w|data-hidden:hidden!|},
    {"combobox", "chelekom-combobox__empty", ~w|data-hidden:hidden!|},
    {"autocomplete", "chelekom-autocomplete__popup", ~w|absolute z-40 data-closed:hidden!|},
    {"autocomplete", "chelekom-autocomplete__item", ~w|data-hidden:hidden!|},
    {"autocomplete", "chelekom-autocomplete__group", ~w|data-hidden:hidden!|},
    {"autocomplete", "chelekom-autocomplete__empty", ~w|data-hidden:hidden!|},
    {"navigation_menu", "chelekom-navigation_menu", ~w|group/navigation-menu relative|},
    {"navigation_menu", "chelekom-navigation_menu__list",
     ~w|flex group-data-[orientation=vertical]/navigation-menu:flex-col|},
    {"navigation_menu", "chelekom-navigation_menu__content",
     ~w|[&[hidden]]:hidden! data-[activation-direction=right]:animate-[chelekom-nm-right_0.2s_ease]|},
    {"navigation_menu", "chelekom-navigation_menu__positioner",
     ~w|group/navigation-menu-positioner absolute z-40 data-closed:hidden!|},
    {"navigation_menu", "chelekom-navigation_menu__popup",
     ~w|relative overflow-hidden group-data-instant/navigation-menu-positioner:[transition:none]|},
    {"navigation_menu", "chelekom-navigation_menu__viewport",
     ~w|relative h-full w-full overflow-hidden|},
    {"slider", "chelekom-slider__thumb", ~w|absolute|},
    {"scroll_area", "chelekom-scroll_area", ~w|group/scroll-area relative|},
    {"scroll_area", "chelekom-scroll_area__viewport",
     ~w|h-full w-full overflow-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden| ++
       ~w|group-data-[orientation=vertical]/scroll-area:overflow-x-hidden|},
    {"scroll_area", "chelekom-scroll_area__scrollbar", ~w|absolute!|},
    {"tabs", "chelekom-tabs__list", ~w|relative|},
    {"tabs", "chelekom-tabs__panel", ~w|[&[hidden]]:hidden!|},
    {"number_field", "chelekom-number_field__scrub-cursor", ~w|not-data-scrubbing:hidden!|},
    {"accordion", "chelekom-accordion__item", @dis},
    {"collapsible", "chelekom-collapsible__item", @dis},
    {"checkbox_group", "chelekom-checkbox_group__item", @dis},
    {"dock", "chelekom-dock__item", @dis},
    {"radio_group", "chelekom-radio-group__item", @dis},
    {"segmented_control", "chelekom-segmented-control__item", @dis},
    {"toggle_group", "chelekom-toggle-group__item", @dis},
    {"overflow_list", "chelekom-overflow-list__item", ~w|data-hidden:hidden!|},
    {"editor", "chelekom-editor", ~w|group/editor|},
    {"editor", "chelekom-editor__surface",
     ~w|flex flex-col [&_.ProseMirror]:whitespace-pre-wrap [&_.cm-editor]:[outline:none]!| ++
       ~w|group-data-empty/editor:[&_.ProseMirror]:before:content-[attr(data-placeholder)]|}
  ]

  # Every occurrence of the part's class list: the marker's own string and the strings after it,
  # up to the first caller-supplied value.
  defp own_classes(component, marker) do
    source = File.read!(Path.join(@dir, "#{component}.eex"))

    for [_, inline, following] <-
          Regex.scan(~r/"#{Regex.escape(marker)}((?:\s[^"]*)?)"((?:,\s*"[^"]*")*)/, source) do
      strings = ~r/"([^"]*)"/ |> Regex.scan(following, capture: :all_but_first) |> List.flatten()
      Enum.flat_map([inline | strings], &String.split/1)
    end
  end

  # The `class={[...]}` lists that start with a part's marker class.
  defp class_lists(source) do
    ~r/class=\{\["chelekom-/
    |> Regex.scan(source, return: :index)
    |> Enum.map(fn [{start, _}] ->
      source |> binary_part(start, byte_size(source) - start) |> list_body()
    end)
  end

  defp list_body(rest), do: list_body(rest, false, [])

  defp list_body(<<"]}", _::binary>>, false, acc),
    do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  defp list_body(<<?", rest::binary>>, quoted, acc), do: list_body(rest, not quoted, [?" | acc])
  defp list_body(<<c, rest::binary>>, quoted, acc), do: list_body(rest, quoted, [c | acc])

  for {component, marker, classes} <- @parts do
    test "#{marker} carries its functional classes" do
      lists = own_classes(unquote(component), unquote(marker))

      assert lists != [], "#{unquote(marker)} is not in #{unquote(component)}.eex"

      for own <- lists, class <- unquote(classes) do
        assert class in own, "#{unquote(marker)} lacks #{class}: #{inspect(own)}"
      end
    end
  end

  test "the caller's classes come after the component's own" do
    for path <- Path.wildcard(Path.join(@dir, "*.eex")),
        list <- class_lists(File.read!(path)),
        String.contains?(list, "@") do
      [_, after_caller] = String.split(list, "@", parts: 2)
      refute after_caller =~ ~r/,\s*"/, "a component class follows the caller's in #{list}"
    end
  end

  test "the visually-hidden inputs use Tailwind's sr-only" do
    for path <- Path.wildcard(Path.join(@dir, "*.eex")) do
      refute File.read!(path) =~ "chelekom-sr-only",
             "#{Path.basename(path)} uses chelekom-sr-only"
    end
  end

  describe "the headless stylesheet" do
    setup do
      %{css: File.read!(@stylesheet)}
    end

    test "has no rule for a component part", %{css: css} do
      refute css =~ ~r/\.chelekom-/
      refute css =~ ~r/\[data-part/
    end

    test "keeps only the page indent and the navigation menu's keyframes", %{css: css} do
      selectors =
        ~r/^([^\s@\/*}][^{]*)\{/m
        |> Regex.scan(css, capture: :all_but_first)
        |> List.flatten()
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 in ["from", "to"]))

      assert selectors == ["[data-drawer-content]"]

      assert ~r/@keyframes ([\w-]+)/ |> Regex.scan(css, capture: :all_but_first) |> List.flatten() ==
               ~w|chelekom-nm-right chelekom-nm-left chelekom-nm-down chelekom-nm-up|
    end

    test "declares only keyframes a template plays", %{css: css} do
      template = File.read!(Path.join(@dir, "navigation_menu.eex"))

      for [name] <- Regex.scan(~r/@keyframes ([\w-]+)/, css, capture: :all_but_first) do
        assert template =~ "animate-[#{name}_", "no template plays #{name}"
      end
    end
  end
end
