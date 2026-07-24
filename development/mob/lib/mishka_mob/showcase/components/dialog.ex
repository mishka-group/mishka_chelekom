defmodule MishkaMob.Showcase.Components.Dialog do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaDialog`.

  Like the Drawer, the dialog itself is rendered by `overlay/1` at the screen
  root so it stacks over the whole page; the example cards only hold the
  triggers. One shared dialog takes on the props of whichever example opened it.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaDialog, only: [dialog: 3]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :dialog,
      name: "Dialog",
      category: "Overlays",
      order: 1,
      description: "A centred modal over a dimmed backdrop."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :dlg, nil)

  @impl true
  def examples do
    [
      %Example{
        title: "A dialog",
        description: "Title, description, body and footer actions.",
        code: ~S"""
        {dialog([open: @open?, title: "Delete file?",
                 description: "This cannot be undone.",
                 on_close: :close], body, actions)}
        """,
        render: fn _assigns -> trigger("Open dialog", :basic) end
      },
      %Example{
        title: "Tap outside to dismiss",
        description: "dismissible is true by default — the backdrop closes it.",
        code: ~S"""
        {dialog([open: @open?, dismissible: true, on_close: :close], body)}
        """,
        render: fn _assigns -> trigger("Open dismissible", :dismissible) end
      },
      %Example{
        title: "Forced choice",
        description: "dismissible: false leaves the backdrop inert — pick an action.",
        code: ~S"""
        {dialog([open: @open?, dismissible: false, on_close: :close], body, actions)}
        """,
        render: fn _assigns -> trigger("Open non-dismissible", :forced) end
      },
      %Example{
        title: "Custom chrome",
        description: "width, background, corner_radius and scrim_color are props.",
        code: ~S"""
        {dialog([open: @open?, width: 280, background: 0xFF1E1B4B,
                 corner_radius: :radius_xl, scrim_color: 0x992E1065], body)}
        """,
        render: fn _assigns -> trigger("Open tinted", :tinted) end
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
        name: "dismissible",
        type: "boolean",
        default: "true",
        description: "Whether a backdrop tap closes it. false forces an explicit choice."
      },
      %{
        name: "on_close",
        type: "event tag",
        default: "—",
        description: "Sent on backdrop tap. Without it the backdrop is inert."
      },
      %{
        name: "width",
        type: "number",
        default: "320",
        description: "Panel width — a Box, so corners clip on both platforms."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface",
        description: "Panel background."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_lg",
        description: "Panel corners."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_lg",
        description: "Padding inside the panel."
      },
      %{
        name: "scrim_color",
        type: "ARGB / token",
        default: "0x99000000",
        description: "Backdrop fill."
      }
    ]
  end

  @impl true
  def overlay(assigns) do
    case assigns.dlg do
      nil -> nil
      variant -> dialog(dialog_props(variant), body(variant), actions(variant))
    end
  end

  @impl true
  def handle({:open_dlg, variant}, socket), do: Mob.Socket.assign(socket, :dlg, variant)
  def handle(:close_dlg, socket), do: Mob.Socket.assign(socket, :dlg, nil)
  def handle(_tag, socket), do: socket

  defp dialog_props(:forced) do
    [
      open: true,
      title: "Discard changes?",
      description: "The backdrop will not dismiss this — choose an action.",
      dismissible: false,
      on_close: :close_dlg
    ]
  end

  defp dialog_props(:tinted) do
    [
      open: true,
      title: "Tinted",
      description: "width, background, corner_radius and scrim_color are all props.",
      width: 280,
      background: 0xFF1E1B4B,
      corner_radius: :radius_xl,
      scrim_color: 0x99_2E_10_65,
      on_close: :close_dlg
    ]
  end

  defp dialog_props(:dismissible) do
    [
      open: true,
      title: "Tap outside",
      description: "Anywhere on the dimmed backdrop closes this.",
      on_close: :close_dlg
    ]
  end

  defp dialog_props(_basic) do
    [
      open: true,
      title: "Delete file?",
      description: "This cannot be undone.",
      on_close: :close_dlg
    ]
  end

  defp body(:tinted) do
    [
      %{
        type: :text,
        props: %{
          text: "Any colour token or ARGB int works.",
          text_size: :base,
          text_color: 0xCCFFFFFF
        },
        children: []
      }
    ]
  end

  defp body(_variant), do: []

  defp actions(:dismissible), do: []

  defp actions(_variant) do
    [
      %{
        type: :button,
        props: %{
          text: "Cancel",
          background: :surface_raised,
          text_color: :on_surface,
          padding: :space_sm,
          on_tap: {self(), :close_dlg}
        },
        children: []
      },
      %{type: :spacer, props: %{size: 8}, children: []},
      %{
        type: :button,
        props: %{
          text: "Confirm",
          background: :primary,
          text_color: :on_primary,
          padding: :space_sm,
          on_tap: {self(), :close_dlg}
        },
        children: []
      }
    ]
  end

  defp trigger(label, variant) do
    ~MOB"""
    <Button
      text={label}
      background={:primary}
      text_color={:on_primary}
      padding={:space_sm}
      fill_width={true}
      on_tap={{self(), {:open_dlg, variant}}}
    />
    """
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} height={70} background={:muted} corner_radius={:radius_sm} align={:center}>
      <Box width={76} height={46} background={:surface} corner_radius={:radius_sm} padding={6}>
        <Column fill_width={true}>
          <Box fill_width={true} height={7} background={:surface_raised} corner_radius={:radius_sm} />
          <Spacer size={5} />
          <Box width={40} height={5} background={:surface_raised} corner_radius={:radius_sm} />
          <Spacer size={9} />
          <Row fill_width={true}>
            <Spacer weight={1} />
            <Box width={22} height={9} background={:primary} corner_radius={:radius_sm} />
          </Row>
        </Column>
      </Box>
    </Box>
    """
  end
end
