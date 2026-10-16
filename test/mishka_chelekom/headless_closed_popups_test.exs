defmodule MishkaChelekom.HeadlessClosedPopupsTest do
  @moduledoc """
  Every headless popup is out of sight while it is closed without a class from the caller.

  The popups carry `data-open` / `data-closed`, and a `data-closed:` class of the popup's own is what
  removes a closed one (`data-closed:hidden`, or the drawer's slide off its edge); a popup without
  one stays on the page until the skin hides it.
  """
  use ExUnit.Case, async: true

  @templates Path.wildcard(Path.expand("../../priv/headless/*.eex", __DIR__))

  # The navigation menu's popup sits inside its positioner, and the positioner is what closes.
  @closed_through %{"chelekom-navigation_menu__popup" => "chelekom-navigation_menu__positioner"}

  defp sources, do: Enum.map(@templates, &File.read!/1)

  defp popups do
    for source <- sources(),
        [_, class] <- Regex.scan(~r/"(chelekom-[\w-]+__[\w-]*popup)[\s"]/, source),
        uniq: true,
        do: class
  end

  # The component's own classes: what follows the part's marker class, up to the caller's class.
  defp own_classes(class) do
    for source <- sources(),
        [_, own] <- Regex.scan(~r/"#{Regex.escape(class)}((?:[^@\]]|\][^}])*)@/s, source),
        do: own
  end

  test "there are popups to check" do
    assert "chelekom-fab__popup" in popups()
  end

  test "every popup has a closed state of its own" do
    missing =
      for class <- popups(),
          closing = Map.get(@closed_through, class, class),
          own = own_classes(closing),
          own == [] or Enum.any?(own, &(not String.contains?(&1, "data-closed:"))),
          do: class

    assert missing == []
  end
end
