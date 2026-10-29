defmodule MishkaChelekom.HeadlessClosedPopupsTest do
  @moduledoc """
  Every headless popup is out of sight while it is closed without a class from the caller.

  The popups carry `data-open` / `data-closed`, and the headless stylesheet is what removes a
  closed one; a popup it does not name stays on the page until the skin hides it.
  """
  use ExUnit.Case, async: true

  @stylesheet Application.app_dir(
                :mishka_chelekom,
                "priv/assets/css/mishka_chelekom_headless.css"
              )
  @templates Path.wildcard(Application.app_dir(:mishka_chelekom, "priv/headless/*.eex"))

  # The navigation menu's popup sits inside its positioner, and the positioner is what closes.
  @closed_through %{"chelekom-navigation_menu__popup" => "chelekom-navigation_menu__positioner"}

  defp popups do
    for path <- @templates,
        [_, class] <- Regex.scan(~r/"(chelekom-[\w-]+__[\w-]*popup)"/, File.read!(path)),
        uniq: true,
        do: class
  end

  test "there are popups to check" do
    assert "chelekom-fab__popup" in popups()
  end

  test "the stylesheet has a closed state for every popup" do
    css = File.read!(@stylesheet)

    missing =
      for class <- popups(),
          closing = Map.get(@closed_through, class, class),
          not (css =~ ~r/\.#{Regex.escape(closing)}(\[[^\]]*\])*\[data-closed\]/),
          do: class

    assert missing == []
  end
end
