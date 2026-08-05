defmodule MishkaMob.Components.MishkaCloseButton do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Close Button** — the ✕ that
  dismisses a dialog, a drawer, a toast or a card.

  A thin wrapper over `MishkaMob.Components.MishkaActionIcon` with the ✕ and a
  circular shape baked in, rather than a second copy of the tap-target logic. It
  exists as its own component because "close" appears everywhere and deserves
  one spelling — including its finger-sized default, which the Action Icon
  already enforces.

  ## Props

  Everything `MishkaMob.Components.MishkaActionIcon` accepts. `icon` defaults to
  `"✕"` and `shape` to `:circle`; both can still be overridden.

  `label` is not ported — it is an `aria-label`, and Mob exposes no accessible
  name on a box.
  """

  alias MishkaMob.Components.MishkaActionIcon

  @doc "Composite expander (`<MishkaCloseButton />`). Children override the ✕."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: close_button(props, children)

  @doc """
  The close-button node.

      close_button(on_tap: :dismiss)
  """
  @spec close_button(map() | keyword(), [map()]) :: map()
  def close_button(props \\ %{}, content \\ []) do
    props
    |> Map.new()
    |> Map.put_new(:icon, "✕")
    |> Map.put_new(:shape, :circle)
    |> MishkaActionIcon.action_icon(content)
  end
end
