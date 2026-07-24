defmodule MishkaMob.Showcase.Components.AlertDialog do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaAlertDialog`.

  Rendered through `overlay/1` at the screen root, like the Dialog and Drawer.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaAlertDialog, only: [alert_dialog: 3]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :alert_dialog,
      name: "Alert Dialog",
      category: "Overlays",
      order: 2,
      description: "A confirmation modal whose backdrop will not dismiss it."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :alert, nil)

  @impl true
  def examples do
    [
      %Example{
        title: "Confirm or cancel",
        description: "Tapping the backdrop does nothing — the choice is the only way out.",
        code: ~S"""
        {alert_dialog([open: @open?, title: "Discard changes?",
                       description: "Your edits will be lost.",
                       on_close: :cancel], [], actions)}
        """,
        render: fn _assigns -> trigger("Discard changes?", :discard) end
      },
      %Example{
        title: "Destructive",
        description: "The confirming action carries the weight, so colour it.",
        code: ~S"""
        # a red confirm button in the actions list
        {alert_dialog(props, [], [cancel_button(), delete_button()])}
        """,
        render: fn _assigns -> trigger("Delete account", :delete) end
      },
      %Example{
        title: "Why not a Dialog",
        description: "dismissible is forced to false — passing it changes nothing.",
        code: ~S"""
        # both of these are identical: the backdrop stays inert
        {alert_dialog([open: true, dismissible: true], [], actions)}
        {alert_dialog([open: true], [], actions)}
        """,
        render: fn _assigns -> trigger("Try to dismiss it", :stubborn) end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the dialog is shown. Lives in the screen."
      },
      %{name: "title", type: "string", default: "nil", description: "Heading."},
      %{
        name: "description",
        type: "string",
        default: "nil",
        description: "Supporting line under the heading."
      },
      %{
        name: "on_close",
        type: "event tag",
        default: "—",
        description: "What a Cancel action calls. NOT wired to the backdrop."
      },
      %{
        name: "dismissible",
        type: "—",
        default: "false",
        description: "Always false. An alert dialog that closes on a backdrop tap is a Dialog."
      },
      %{
        name: "width / background / corner_radius / padding / scrim_color",
        type: "see Dialog",
        default: "—",
        description: "Everything else is passed straight through to Dialog."
      }
    ]
  end

  @impl true
  def overlay(assigns) do
    case assigns.alert do
      nil -> nil
      variant -> alert_dialog(alert_props(variant), [], actions(variant))
    end
  end

  @impl true
  def handle({:open_alert, variant}, socket), do: Mob.Socket.assign(socket, :alert, variant)
  def handle(:close_alert, socket), do: Mob.Socket.assign(socket, :alert, nil)
  def handle(_tag, socket), do: socket

  defp alert_props(:delete) do
    [
      open: true,
      title: "Delete account?",
      description: "Everything you have stored will be removed. This cannot be undone.",
      on_close: :close_alert
    ]
  end

  defp alert_props(:stubborn) do
    [
      open: true,
      title: "Tap the backdrop",
      description: "Nothing happens — that is the whole point of an alert dialog.",
      dismissible: true,
      on_close: :close_alert
    ]
  end

  defp alert_props(_discard) do
    [
      open: true,
      title: "Discard changes?",
      description: "Your edits will be lost.",
      on_close: :close_alert
    ]
  end

  defp actions(:delete),
    do: [
      button("Cancel", :surface_raised, :on_surface),
      gap(),
      button("Delete", 0xFFDC2626, 0xFFFFFFFF)
    ]

  defp actions(_variant),
    do: [
      button("Cancel", :surface_raised, :on_surface),
      gap(),
      button("Confirm", :primary, :on_primary)
    ]

  defp button(label, background, text_color) do
    %{
      type: :button,
      props: %{
        text: label,
        background: background,
        text_color: text_color,
        padding: :space_sm,
        on_tap: {self(), :close_alert}
      },
      children: []
    }
  end

  defp gap, do: %{type: :spacer, props: %{size: 8}, children: []}

  defp trigger(label, variant) do
    ~MOB"""
    <Button
      text={label}
      background={:primary}
      text_color={:on_primary}
      padding={:space_sm}
      fill_width={true}
      on_tap={{self(), {:open_alert, variant}}}
    />
    """
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} height={70} background={:muted} corner_radius={:radius_sm} align={:center}>
      <Box width={80} height={48} background={:surface} corner_radius={:radius_sm} padding={6}>
        <Column fill_width={true}>
          <Box width={44} height={7} background={:surface_raised} corner_radius={:radius_sm} />
          <Spacer size={5} />
          <Box fill_width={true} height={5} background={:surface_raised} corner_radius={:radius_sm} />
          <Spacer size={9} />
          <Row fill_width={true}>
            <Spacer weight={1} />
            <Box width={20} height={9} background={:surface_raised} corner_radius={:radius_sm} />
            <Spacer size={4} />
            <Box width={20} height={9} background={0xFFDC2626} corner_radius={:radius_sm} />
          </Row>
        </Column>
      </Box>
    </Box>
    """
  end
end
