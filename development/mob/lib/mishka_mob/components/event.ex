defmodule MishkaMob.Components.Event do
  @moduledoc """
  Normalises the event handlers a Chelekom component accepts.

  Mob's renderer only registers a handler when the prop is `{screen_pid, tag}`
  (see the `on_tap` / `on_change` clauses in `Mob.Renderer`). Anything else —
  notably a bare tag atom — falls through to ordinary prop serialisation, and the
  native side reads a handle that was never registered. The control then renders
  perfectly and does nothing, which is the worst kind of bug: invisible until a
  human taps it.

  `Mob.Composite` performs this widening for tag props automatically, so
  `<MishkaDrawer on_close={:close} />` works. Calling a component as a plain
  function skips that machinery, so components route their handler props through
  `handler/1` to get the same result:

      handler(:save)              #=> {self(), :save}
      handler({pid, :save})       #=> {pid, :save}   (already wired, left alone)
      handler(nil)                #=> nil            (prop omitted entirely)

  `self()` is the right pid because a component function is called from inside
  the screen's `render/1`, which runs in the screen's own process.
  """

  @doc """
  Widen an event prop to the `{pid, tag}` shape the renderer registers.

  Returns `nil` when there is no handler, so callers can omit the prop rather
  than sending an explicit `nil` the native side would have to interpret.
  """
  @spec handler(term()) :: {pid(), term()} | nil
  def handler(nil), do: nil
  def handler({pid, _tag} = wired) when is_pid(pid), do: wired
  def handler(tag), do: {self(), tag}
end
