defmodule MishkaMob.Showcase.Components.Dialog do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaDialog`.

  Like the Drawer, the dialogs themselves are rendered by `overlay/1` at the
  screen root so they stack over the whole page; the example cards hold only the
  triggers. Each example owns a **separate assign and a separate `id`** — one
  shared dialog wearing whichever props opened it would leave a device test
  unable to say which example it had touched.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  # Every dialog on the page, in the order overlay/1 stacks them. The assign is
  # what the trigger flips; the id is the stem of every testTag the dialog emits.
  @variants [
    {:dlg_basic, "dlg-basic"},
    {:dlg_slots, "dlg-slots"},
    {:dlg_dismiss, "dlg-dismiss"},
    {:dlg_forced, "dlg-forced"},
    {:dlg_plain, "dlg-plain"},
    {:dlg_tinted, "dlg-tinted"},
    {:dlg_disabled, "dlg-disabled"}
  ]

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
  def mount(socket) do
    @variants
    |> Enum.reduce(socket, fn {key, _id}, acc -> Mob.Socket.assign(acc, key, false) end)
    |> Mob.Socket.assign(:dlg_change, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "The whole anatomy",
        description:
          "Title, description, body and footer actions, each one a tagged part: " <>
            "dlg-basic-title, -description, -content, -footer.",
        code: ~S"""
        <MishkaDialog
          id="confirm"
          open={@confirm?}
          title="Delete file?"
          description="This cannot be undone."
          on_close={:close_confirm}
        >
          <Text text="report.pdf will be removed from every device." />
          <MishkaDialogFooter>
            <Button text="Cancel" id="confirm-close" on_tap={{self(), :close_confirm}} />
            <Button text="Delete" id="confirm-confirm" on_tap={{self(), :close_confirm}} />
          </MishkaDialogFooter>
        </MishkaDialog>

        # The trigger is a slot too — a closed dialog draws nothing else, so the
        # tag can sit where the button belongs while the panel stacks at the
        # screen root. `id` is what ties the two together.
        <MishkaDialog id="confirm" open={false}>
          <MishkaDialogTrigger label="Delete" on_tap={:open_confirm} />
        </MishkaDialog>

        def handle_info({:tap, :open_confirm}, socket) do
          {:noreply, Mob.Socket.assign(socket, :confirm?, true)}
        end

        def handle_info({:tap, :close_confirm}, socket) do
          {:noreply, Mob.Socket.assign(socket, :confirm?, false)}
        end
        """,
        render: fn _assigns -> open_button(:dlg_basic, "Open dialog") end
      },
      %Example{
        title: "Slots, not strings",
        description:
          "<MishkaDialogTitle>, <MishkaDialogDescription> and <MishkaDialogFooter> take " <>
            "arbitrary nodes — the string props are only the shorthand. A slot child wins " <>
            "when both are given.",
        code: ~S"""
        <MishkaDialog id="move" open={@move?} on_close={:close_move}>
          <MishkaDialogTitle>
            <Row fill_width={true}>
              <Text text="🗂" text_size={:xl} />
              <Spacer size={8} />
              <Box weight={1}><Text text="Move to trash" text_size={:xl} max_lines={1} /></Box>
            </Row>
          </MishkaDialogTitle>
          <MishkaDialogDescription text="Items in the trash are deleted after 30 days." />
          <Text text="Two files selected." />
          <MishkaDialogFooter>
            <Button text="Got it" id="move-close" on_tap={{self(), :close_move}} />
          </MishkaDialogFooter>
        </MishkaDialog>

        def handle_info({:tap, :close_move}, socket) do
          {:noreply, Mob.Socket.assign(socket, :move?, false)}
        end
        """,
        render: fn _assigns -> open_button(:dlg_slots, "Open with slots") end
      },
      %Example{
        title: "Tap outside to dismiss",
        description:
          "dismissible is true by default. This one reports through on_open_change, " <>
            "so the readout below changes the moment the backdrop is tapped.",
        code: ~S"""
        <MishkaDialog
          id="notice"
          open={@notice?}
          dismissible={true}
          on_open_change={:notice_changed}
        >
          <Text text="There is no footer here — the backdrop is the only way out." />
        </MishkaDialog>

        # on_open_change carries the new state, exactly like the web's {open}.
        def handle_info({:tap, {:notice_changed, open?}}, socket) do
          {:noreply, Mob.Socket.assign(socket, :notice?, open?)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {open_button(:dlg_dismiss, "Open dismissible")}
            <Spacer size={10} />
            <Text
              text={change_text(@dlg_change)}
              text_size={:sm}
              text_color={:muted}
              id={change_tag(@dlg_change)}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Forced choice",
        description: "dismissible: false leaves the backdrop inert — pick an action.",
        code: ~S"""
        <MishkaDialog id="discard" open={@discard?} dismissible={false} on_close={:close_discard}>
          <Text text="Your edits to report.pdf have not been saved." />
          <MishkaDialogFooter>
            <Button text="Cancel" id="discard-close" on_tap={{self(), :close_discard}} />
            <Button text="Discard" id="discard-confirm" on_tap={{self(), :close_discard}} />
          </MishkaDialogFooter>
        </MishkaDialog>

        # The backdrop is inert, so the footer buttons are the only way out.
        def handle_info({:tap, :close_discard}, socket) do
          {:noreply, Mob.Socket.assign(socket, :discard?, false)}
        end
        """,
        render: fn _assigns -> open_button(:dlg_forced, "Open non-dismissible") end
      },
      %Example{
        title: "Not modal",
        description:
          "modal={false} (and \"trap-focus\", which renders the same) leaves the backdrop " <>
            "transparent. The focus trap it also named has no native counterpart.",
        code: ~S"""
        <MishkaDialog id="hint" open={@hint?} modal={false} on_close={:close_hint}>
          <Text text="The backdrop is still there; it simply has no fill." />
          <MishkaDialogFooter>
            <Button text="Close" id="hint-close" on_tap={{self(), :close_hint}} />
          </MishkaDialogFooter>
        </MishkaDialog>

        def handle_info({:tap, :close_hint}, socket) do
          {:noreply, Mob.Socket.assign(socket, :hint?, false)}
        end
        """,
        render: fn _assigns -> open_button(:dlg_plain, "Open without a dim") end
      },
      %Example{
        title: "Custom chrome",
        description: "width, background, corner_radius, padding, inset and scrim_color.",
        code: ~S"""
        <MishkaDialog
          id="tinted"
          open={@tinted?}
          width={280}
          background={0xFF1E1B4B}
          corner_radius={:radius_xl}
          padding={:space_xl}
          inset={:space_xl}
          scrim_color={0x992E1065}
          on_close={:close_tinted}
        >
          <Text text="Any colour token or ARGB int works." text_color={0xCCFFFFFF} />
          <MishkaDialogFooter>
            <Button text="Close" id="tinted-close" on_tap={{self(), :close_tinted}} />
          </MishkaDialogFooter>
        </MishkaDialog>
        """,
        render: fn _assigns -> open_button(:dlg_tinted, "Open tinted") end
      },
      %Example{
        title: "A disabled trigger",
        description:
          "disabled: true wires no handler at all and tags itself -trigger-disabled, " <>
            "because the muted colour that says so is invisible to a device test.",
        code: ~S"""
        <MishkaDialog id="export" open={@export?}>
          <MishkaDialogTrigger label="Export (Pro only)" disabled={true} on_tap={:open_export} />
        </MishkaDialog>

        # Or, when the trigger cannot live inside the tag — because the panel has
        # to cover the page the button scrolls in, or two buttons open the same
        # dialog — the identical node from the builder:
        {MishkaDialog.trigger("export", "Export (Pro only)", disabled: true, on_tap: :open_export)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaDialog id="dlg-disabled" open={false}>
            <MishkaDialogTrigger label="Unavailable" disabled={true} on_tap={{:dlg_open, :dlg_disabled}} />
          </MishkaDialog>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Tag stem for every part: <id>-open, -panel, -title, -content, -footer."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the dialog is shown. Lives in the screen."
      },
      %{
        name: "modal",
        type: "true / false / \"trap-focus\"",
        default: "true",
        description: "Whether the backdrop dims. The focus trap does not port."
      },
      %{name: "title", type: "string", default: "nil", description: "Heading. See title/1."},
      %{
        name: "description",
        type: "string",
        default: "nil",
        description: "Supporting line under the heading. See description/1."
      },
      %{
        name: "actions",
        type: "list of nodes",
        default: "[]",
        description: "Footer buttons, trailing-aligned. See footer/1."
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
        description: "Sent as {:tap, tag} on backdrop tap."
      },
      %{
        name: "on_open_change",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, false}} on backdrop tap. on_close wins over it."
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
        name: "inset",
        type: "spacing / number",
        default: ":space_lg",
        description: "The viewport gap between the panel and the screen edges."
      },
      %{
        name: "scrim_color",
        type: "ARGB / token",
        default: "0x99000000",
        description: "Backdrop fill. 0x00000000 when modal is false."
      },
      %{
        name: "trigger/3",
        type: "builder",
        default: "—",
        description: "id, label, plus :on_tap, :on_open_change, :disabled and the chrome props."
      },
      %{
        name: "title/1 · description/1 · footer/1",
        type: "slots",
        default: "—",
        description: "Slot children carrying arbitrary nodes, not just a line of text."
      }
    ]
  end

  @impl true
  def overlay(assigns) do
    case Enum.filter(@variants, fn {key, _id} -> Map.get(assigns, key) end) do
      [] -> nil
      open -> stack(Enum.map(open, fn {key, id} -> build(key, id) end))
    end
  end

  @impl true
  def handle({:dlg_open, key}, socket), do: Mob.Socket.assign(socket, key, true)
  def handle({:dlg_close, key}, socket), do: Mob.Socket.assign(socket, key, false)

  # on_open_change composes the caller's tag with the new state, so the tag this
  # page passed arrives nested: {{:dlg_changed, key}, open?}.
  def handle({{:dlg_changed, key}, open?}, socket) do
    socket
    |> Mob.Socket.assign(key, open?)
    |> Mob.Socket.assign(:dlg_change, open?)
  end

  def handle(_tag, socket), do: socket

  defp build(:dlg_basic = key, id) do
    ~MOB"""
    <MishkaDialog
      id={id}
      open={true}
      title="Delete file?"
      description="This cannot be undone."
      on_close={{:dlg_close, key}}
    >
      {note("report.pdf will be removed from every device.")}
      <MishkaDialogFooter>
        {cancel(id, key)}
        {confirm(id, key, "Delete")}
      </MishkaDialogFooter>
    </MishkaDialog>
    """
  end

  # The slot form: a title that is a Row rather than a line of text, which is
  # the whole reason the web has a <:title> slot and not a title attribute.
  defp build(:dlg_slots = key, id) do
    ~MOB"""
    <MishkaDialog id={id} open={true} on_close={{:dlg_close, key}}>
      <MishkaDialogTitle>
        <Row fill_width={true}>
          <Text text="🗂" text_size={:xl} />
          <Spacer size={8} />
          <Box weight={1}>
            <Text text="Move to trash" text_size={:xl} text_color={:on_surface} max_lines={1} />
          </Box>
        </Row>
      </MishkaDialogTitle>
      <MishkaDialogDescription text="Items in the trash are deleted after 30 days." />
      {note("Two files selected.")}
      <MishkaDialogFooter>
        {close(id, key, "Got it")}
      </MishkaDialogFooter>
    </MishkaDialog>
    """
  end

  defp build(:dlg_dismiss = key, id) do
    ~MOB"""
    <MishkaDialog
      id={id}
      open={true}
      title="Tap outside"
      description="Anywhere on the dimmed backdrop closes this."
      on_open_change={{:dlg_changed, key}}
    >
      {note("There is no footer here — the backdrop is the only way out.")}
    </MishkaDialog>
    """
  end

  defp build(:dlg_forced = key, id) do
    ~MOB"""
    <MishkaDialog
      id={id}
      open={true}
      title="Discard changes?"
      description="The backdrop will not dismiss this — choose an action."
      dismissible={false}
      on_close={{:dlg_close, key}}
    >
      {note("Your edits to report.pdf have not been saved.")}
      <MishkaDialogFooter>
        {cancel(id, key)}
        {confirm(id, key, "Discard")}
      </MishkaDialogFooter>
    </MishkaDialog>
    """
  end

  defp build(:dlg_plain = key, id) do
    ~MOB"""
    <MishkaDialog
      id={id}
      open={true}
      modal={false}
      title="No dim"
      description="modal={false} keeps the page visible behind the panel."
      on_close={{:dlg_close, key}}
    >
      {note("The backdrop is still there; it simply has no fill.")}
      <MishkaDialogFooter>
        {close(id, key, "Close")}
      </MishkaDialogFooter>
    </MishkaDialog>
    """
  end

  defp build(:dlg_tinted = key, id) do
    ~MOB"""
    <MishkaDialog
      id={id}
      open={true}
      title="Tinted"
      description="Every piece of chrome is a prop."
      width={280}
      background={0xFF1E1B4B}
      corner_radius={:radius_xl}
      padding={:space_xl}
      inset={:space_xl}
      scrim_color={0x992E1065}
      on_close={{:dlg_close, key}}
    >
      <Text text="Any colour token or ARGB int works." text_size={:base} text_color={0xCCFFFFFF} />
      <MishkaDialogFooter>
        {close(id, key, "Close")}
      </MishkaDialogFooter>
    </MishkaDialog>
    """
  end

  defp build(:dlg_disabled = key, id) do
    ~MOB"""
    <MishkaDialog id={id} open={true} title="Unreachable" on_close={{:dlg_close, key}}>
      {note("A disabled trigger wires no handler, so this cannot be opened.")}
      <MishkaDialogFooter>
        {close(id, key, "Close")}
      </MishkaDialogFooter>
    </MishkaDialog>
    """
  end

  # A closed dialog draws nothing but its trigger slot, so the card can hold the
  # <MishkaDialog> tag itself and the panel still stacks at the screen root
  # under its own assign. Same node `trigger/3` builds, same `<id>-trigger` tag.
  defp open_button(key, label) do
    ~MOB"""
    <MishkaDialog id={id_for(key)} open={false}>
      <MishkaDialogTrigger label={label} on_tap={{:dlg_open, key}} />
    </MishkaDialog>
    """
  end

  defp id_for(key) do
    {_key, id} = Enum.find(@variants, fn {k, _id} -> k == key end)
    id
  end

  defp stack(children),
    do: %{type: :box, props: %{fill_width: true, fill_height: true}, children: children}

  defp note(text) do
    ~MOB"""
    <Text text={text} text_size={:base} text_color={:on_surface} />
    """
  end

  # Footer buttons carry their own tags: a device test that can only see the
  # panel has no other way to say which button it pressed.
  defp cancel(id, key, label \\ "Cancel") do
    button(label, id <> "-close", {:dlg_close, key}, :surface_raised, :on_surface)
  end

  defp confirm(id, key, label) do
    button(label, id <> "-confirm", {:dlg_close, key}, :primary, :on_primary)
  end

  defp close(id, key, label) do
    button(label, id <> "-close", {:dlg_close, key}, :primary, :on_primary)
  end

  defp button(label, test_id, tag, background, text_color) do
    ~MOB"""
    <Button
      text={label}
      background={background}
      text_color={text_color}
      padding={:space_sm}
      on_tap={{self(), tag}}
      id={test_id}
    />
    """
  end

  # The readout folds the reported state into its own tag. A page-wide text
  # query would be answered by the code sample above it, which also says
  # "on_open_change" — the tag is the only thing that names this node alone.
  defp change_text(nil), do: "on_open_change: nothing reported yet"
  defp change_text(true), do: "on_open_change reported: true"
  defp change_text(false), do: "on_open_change reported: false"

  defp change_tag(nil), do: "dlg-dismiss-readout-idle"
  defp change_tag(true), do: "dlg-dismiss-readout-true"
  defp change_tag(false), do: "dlg-dismiss-readout-false"

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
