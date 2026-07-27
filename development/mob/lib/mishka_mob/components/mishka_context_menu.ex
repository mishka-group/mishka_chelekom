defmodule MishkaMob.Components.MishkaContextMenu do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Context Menu** — the actions
  for a particular row or object.

  Renders through `MishkaMob.Components.MishkaMenu`, because a context menu and a
  dropdown menu are the same list of actions; only what *summons* them differs.

  ## The right-click is the part that does not port

  On the web this opens on `contextmenu` — a right-click, or a long press on
  touch — at the pointer's coordinates. Mob's Android bridge exposes no
  long-press gesture and no pointer coordinates, so neither the trigger nor the
  at-the-cursor placement can be reproduced. Rather than invent a worse gesture,
  the port keeps the **subject**: `for_label` names the object the actions belong
  to and renders as a heading, which is what a phone context menu (an action
  sheet) does and what makes it unambiguous which row you are acting on.

  Open it from whatever the caller likes — a ⋯ button on the row is the usual
  phone answer — and place it in flow or inside a bottom `MishkaDrawer`.

  ## Props

  Everything `MishkaMob.Components.MishkaMenu` accepts, plus:

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `for_label` | string | `nil` | The object these actions apply to, shown as a heading. |

  Not ported: the `contextmenu` trigger, pointer placement, and `id` /
  `*_class`.
  """

  alias MishkaMob.Components.MishkaMenu

  @doc "Composite expander (`<MishkaContextMenu>`). Children are menu items."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: context_menu(props, children)

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
