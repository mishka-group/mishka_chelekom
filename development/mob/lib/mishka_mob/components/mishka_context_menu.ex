defmodule MishkaMob.Components.MishkaContextMenu do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Context Menu** — the actions
  for a particular row or object.

  Renders through `MishkaMob.Components.MishkaMenu`, because a context menu and a
  dropdown menu are the same list of actions; only what *summons* them differs.

  ## Long-press is the right-click

  On the web this opens on `contextmenu` — a right-click, or **a long press on
  touch**, which is what the web component's own keyboard/focus notes say. So
  that is what it opens on here: wrap the object in `trigger/2` and hold it.

  This shipped without a trigger at all, on the stated grounds that "Mob's
  Android bridge exposes no long-press gesture". Half of that was true: the
  handler has always been registered (`Mob.Renderer`, `on_long_press`) and iOS
  has always implemented it (`.onLongPressGesture`) — only our Android bridge
  was missing it, and that bridge is ours. It now wires `combinedClickable`, so
  a long press works on both platforms.

  What genuinely does not port is **placement at the pointer**: a touch has no
  cursor to open at, and a phone has no room for a menu pinned to a coordinate.
  That is about the coordinate, not about floating — the `:anchored` node
  (`MishkaMob.Components.Anchored`) does draw a panel over the page against a
  trigger's own box, and `MishkaMob.Components.MishkaPopover` is built on it.
  This renders through `MishkaMob.Components.MishkaMenu`, which has not been
  moved onto it, so the menu still opens where the caller puts it — in flow, or
  in a bottom `MishkaDrawer`, which is the shape a phone uses for exactly this.

  ## Props

  Everything `MishkaMob.Components.MishkaMenu` accepts, plus:

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `for_label` | string | `nil` | The object these actions apply to, shown as a heading. |

  `trigger/2` wraps whatever the actions belong to:

      <Column>
        {MishkaContextMenu.trigger(:report, [row_content()])}
        <MishkaContextMenu open={@open == :report} for_label="report.pdf" on_select={:act}>
          <MishkaMenuItem id={:rename} label="Rename" />
        </MishkaContextMenu>
      </Column>

      def handle_info({:tap, {:hold, id}}, socket), do: {:noreply, assign(socket, :open, id)}

  Not ported: placement at the pointer, and `id` / `*_class`.
  """

  alias MishkaMob.Components.{Event, MishkaMenu}

  @doc "Composite expander (`<MishkaContextMenu>`). Children are menu items."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: context_menu(props, children)

  @doc """
  Wrap the object the actions belong to, so holding it opens the menu.

  `on_hold` is the event tag; the message is `{:tap, {tag, id}}`, the same shape
  every other row-carrying component here uses, so one clause serves a list.

      trigger(:report, [row()], on_hold: :hold, test_id: "row-report")

  A long press is the touch equivalent of the web's right-click. A plain tap
  passes straight through, so the row keeps whatever it already did.
  """
  @spec trigger(term(), [map()], keyword()) :: map()
  def trigger(id, children, opts \\ []) do
    node = %{
      type: :box,
      props: %{fill_width: true},
      children: children
    }

    node =
      case Event.handler(Keyword.get(opts, :on_hold)) do
        nil -> node
        {pid, tag} -> put_in(node.props[:on_long_press], {pid, {tag, id}})
      end

    case Keyword.get(opts, :test_id) do
      nil -> node
      test_id -> put_in(node.props[:id], test_id)
    end
  end

  @doc """
  The context-menu node.

      <MishkaContextMenu
        open={@open?}
        for_label="report.pdf"
        on_select={:act}
      >{[
        MishkaMenu.item(:rename, "Rename"),
        MishkaMenu.item(:delete, "Delete", danger: true)
      ]}</MishkaContextMenu>
  """
  @spec context_menu(map() | keyword(), [map()]) :: map()
  def context_menu(props \\ %{}, children \\ []) do
    props = Map.new(props)

    children =
      case Map.get(props, :for_label) do
        nil -> children
        label -> [MishkaMenu.label(label) | children]
      end

    props
    |> Map.delete(:for_label)
    |> MishkaMenu.menu(children)
  end
end
