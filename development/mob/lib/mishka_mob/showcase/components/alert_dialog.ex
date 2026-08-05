defmodule MishkaMob.Showcase.Components.AlertDialog do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaAlertDialog`.

  Rendered through `overlay/1` at the screen root, like the Dialog and Drawer.

  Every dialog here is written as MARKUP — `<MishkaAlertDialog>` with its slot
  tags inside it — so `overlay/1` returns a composite node rather than a widget
  tree, and the screen's composite pass is what turns it into one. A test
  reading this page therefore has to run `Mob.Composite.expand/2` first, the
  same way the Toolbar and Tree pages' tests do.

  Every example owns its own assign and its own testTag prefix. That is not
  tidiness: the whole page scrolls as one, and the code samples are text nodes
  too, so a test that asked "is 'Delete account?' on screen" would be answered
  by whichever example happened to print the words. Only a tag says which
  dialog is up.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaAlertDialog
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
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:ad_confirm, false)
    |> Mob.Socket.assign(:ad_confirm_choice, nil)
    |> Mob.Socket.assign(:ad_stubborn, false)
    |> Mob.Socket.assign(:ad_stubborn_leaks, 0)
    |> Mob.Socket.assign(:ad_delete, false)
    |> Mob.Socket.assign(:ad_delete_done, false)
    |> Mob.Socket.assign(:ad_slots, false)
    |> Mob.Socket.assign(:ad_chrome, false)
  end

  @impl true
  def examples do
    [
      confirm_example(),
      stubborn_example(),
      destructive_example(),
      slots_example(),
      chrome_example()
    ]
  end

  defp confirm_example do
    %Example{
      title: "Confirm or cancel",
      description:
        "Every part is a tag. Cancel carries close: true and nothing else, so it fires the " <>
          "dialog's on_close — the port of the web's data-close. Confirm brings its own " <>
          "handler, which wins.",
      code: ~S"""
      <MishkaAlertDialog id="discard" open={@discard?} on_close={:discard_cancel}>
        <MishkaDialogTitle text="Discard changes?" />
        <MishkaDialogDescription text="Your edits will be lost." />
        <MishkaAlertDialogAction text="Cancel" id="discard-cancel" />
        <MishkaAlertDialogAction
          text="Discard"
          id="discard-go"
          variant={:primary}
          on_tap={:discard_go}
        />
      </MishkaAlertDialog>

      # close: true routes here; the Discard button routes to its own tag.
      def handle_info({:tap, :discard_cancel}, socket) do
        {:noreply, Mob.Socket.assign(socket, :discard?, false)}
      end

      def handle_info({:tap, :discard_go}, socket) do
        {:noreply, socket |> Mob.Socket.assign(:discard?, false) |> discard()}
      end

      # REQUIRED: the backdrop and the panel both route stray taps to tags
      # nobody handles, so a catch-all has to swallow them.
      def handle_info(_msg, socket), do: {:noreply, socket}
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          {trigger("Discard changes?", :ad_confirm_open, "ad-confirm-trigger")}
          <Spacer size={8} />
          <Text
            text={choice_label(@ad_confirm_choice)}
            text_size={:sm}
            text_color={:muted}
            max_lines={1}
            id={"ad-confirm-choice-#{@ad_confirm_choice || "none"}"}
          />
        </Column>
        """
      end
    }
  end

  defp stubborn_example do
    %Example{
      title: "The backdrop will not dismiss it",
      description:
        "dismissible: true is passed here and ignored. Tap the dim anywhere — including " <>
          "over the card below, which counts every tap that reaches it.",
      code: ~S"""
      # Identical: dismissible is forced to false either way.
      <MishkaAlertDialog id="stubborn" open={@open?} dismissible={true}>…</MishkaAlertDialog>
      <MishkaAlertDialog id="stubborn" open={@open?}>…</MishkaAlertDialog>

      # The card underneath keeps its own handler and never hears from it while
      # the dialog is up — the backdrop absorbs the tap rather than passing it on.
      def handle_info({:tap, :leak}, socket) do
        {:noreply, Mob.Socket.assign(socket, :leaks, socket.assigns.leaks + 1)}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          {trigger("Try to tap it away", :ad_stubborn_open, "ad-stubborn-trigger")}
          <Spacer size={8} />
          <Box
            fill_width={true}
            padding={:space_sm}
            background={:surface_raised}
            corner_radius={:radius_sm}
            on_tap={{self(), :ad_stubborn_leak}}
            id={"ad-stubborn-leaks-#{@ad_stubborn_leaks}"}
          >
            <Text
              text={"Taps that got through: #{@ad_stubborn_leaks}"}
              text_size={:sm}
              text_color={:on_surface}
              max_lines={1}
            />
          </Box>
        </Column>
        """
      end
    }
  end

  defp destructive_example do
    %Example{
      title: "Destructive",
      description:
        "variant: :danger tints with the :error token, and folds \"danger\" into the " <>
          "button's testTag — a red fill is not something a device test can read. This one " <>
          "builds its footer from DATA, which is the one place the function form still wins.",
      code: ~S"""
      # A footer that comes from a list is a comprehension, not markup written
      # out N times — so action/2 stays, and the actions prop is how it lands.
      # Both forms build the identical node, so mixing them is not a compromise.
      actions =
        Enum.map(@choices, fn choice ->
          MishkaAlertDialog.action(choice.label,
            id: choice.id,
            variant: choice.variant,
            on_tap: choice.on_tap
          )
        end)

      <MishkaAlertDialog id="delete" open={@deleting?} on_close={:delete_cancel}
                         actions={actions}>
        <MishkaDialogTitle text="Delete account?" />
        <MishkaDialogDescription text="This cannot be undone." />
      </MishkaAlertDialog>

      # testTags: "delete-cancel-neutral" and "delete-go-danger".
      def handle_info({:tap, :delete_go}, socket) do
        {:noreply, socket |> Mob.Socket.assign(:deleting?, false) |> delete_account()}
      end
      """,
      render: fn assigns ->
        ~MOB"""
        <Column fill_width={true}>
          {trigger("Delete account", :ad_delete_open, "ad-delete-trigger")}
          <Spacer size={8} />
          <Text
            text={deleted_label(@ad_delete_done)}
            text_size={:sm}
            text_color={:muted}
            max_lines={1}
            id={"ad-delete-state-#{if @ad_delete_done, do: "gone", else: "intact"}"}
          />
        </Column>
        """
      end
    }
  end

  defp slots_example do
    %Example{
      title: "A title that is not a string",
      description:
        "A slot tag with a subtree inside it is the whole point of a slot: the web's " <>
          "required <:title> and <:description> take blocks, not strings. The text= " <>
          "attribute is the shorthand.",
      code: ~S"""
      # Give the tag children instead of a text= and the subtree IS the part.
      # <MishkaDialogFooter> wraps the footer when it holds more than actions.
      <MishkaAlertDialog id="quota" open={@open?} on_close={:quota_close}>
        <MishkaDialogTitle>
          <Row fill_width={true}>
            <Text text="⚠" text_size={:xl} text_color={:error} />
            <Spacer size={8} />
            <Text text="Storage full" text_size={:xl} text_color={:on_surface} />
          </Row>
        </MishkaDialogTitle>
        <MishkaDialogDescription>
          {usage_bar(0.98)}
        </MishkaDialogDescription>
        <MishkaDialogFooter>
          <MishkaAlertDialogAction text="Got it" id="quota-ok" />
        </MishkaDialogFooter>
      </MishkaAlertDialog>

      def handle_info({:tap, :quota_close}, socket) do
        {:noreply, Mob.Socket.assign(socket, :open?, false)}
      end
      """,
      render: fn _assigns -> trigger("Storage full", :ad_slots_open, "ad-slots-trigger") end
    }
  end

  defp chrome_example do
    %Example{
      title: "Its own chrome",
      description:
        "width, padding, corners, panel fill and scrim all pass through to Dialog. This one " <>
          "also carries a body, which sits between the description and the actions.",
      code: ~S"""
      <MishkaAlertDialog
        id="chrome"
        open={@open?}
        width={260}
        padding={:space_md}
        corner_radius={:radius_sm}
        background={:surface_raised}
        scrim_color={0xCC000000}
        on_close={:chrome_close}
      >
        <MishkaDialogTitle text="Narrower, darker" />
        <MishkaDialogDescription text="260dp wide, tighter padding, a heavier scrim." />
        <Text text="Anything that is not a slot tag is the body." text_color={:on_surface} />
        <MishkaAlertDialogAction text="Close" id="chrome-close" />
      </MishkaAlertDialog>

      def handle_info({:tap, :chrome_close}, socket) do
        {:noreply, Mob.Socket.assign(socket, :open?, false)}
      end
      """,
      render: fn _assigns -> trigger("A 260dp panel", :ad_chrome_open, "ad-chrome-trigger") end
    }
  end

  @impl true
  def props do
    [
      %{
        name: "id",
        type: "string",
        default: "nil",
        description:
          "testTag stem. Yields <id>-open / -backdrop-modal / -panel / -title / " <>
            "-description / -content / -footer — Dialog's names, so a test need " <>
            "not know which of the two it has."
      },
      %{
        name: "open",
        type: "boolean",
        default: "false",
        description: "Whether the dialog is shown. Lives in the screen."
      },
      %{
        name: "<MishkaDialogTitle>",
        type: "slot tag",
        default: "—",
        description:
          "The heading. text=\"…\" for a line, or children for a subtree. " <>
            "title/1 builds the same node; the title string prop is the shorthand."
      },
      %{
        name: "<MishkaDialogDescription>",
        type: "slot tag",
        default: "—",
        description:
          "The supporting part under the heading. Same two forms as the title. " <>
            "description/1 builds the same node."
      },
      %{
        name: "<MishkaAlertDialogAction>",
        type: "slot tag",
        default: "—",
        description:
          "One footer button: text, id, variant, on_tap, close. Repeat it per " <>
            "choice. action/2 builds the same node."
      },
      %{
        name: "<MishkaDialogFooter>",
        type: "slot tag",
        default: "—",
        description:
          "The whole footer at once, for one holding more than action buttons. " <>
            "Actions written inside it are still resolved. actions/1 builds it."
      },
      %{
        name: "actions",
        type: "list of nodes",
        default: "[]",
        description:
          "The footer as a prop — for buttons built from data with action/2. " <>
            "Action tags win over it."
      },
      %{
        name: "on_close",
        type: "event tag",
        default: "nil",
        description: "Fired by an action carrying close: true. NOT wired to the backdrop."
      },
      %{
        name: "dismissible",
        type: "—",
        default: "false",
        description: "Always false. An alert dialog that closes on a backdrop tap is a Dialog."
      },
      %{
        name: "modal",
        type: "—",
        default: "true",
        description: "Always true. The web's alert dialog has no such attribute; it is never not."
      },
      %{
        name: "width / background / corner_radius",
        type: "see Dialog",
        default: "—",
        description: "The panel's size and skin. Passed straight through."
      },
      %{
        name: "padding / inset / scrim_color",
        type: "see Dialog",
        default: "—",
        description: "Inside the panel, around it, and the backdrop fill."
      }
    ]
  end

  # At most one of these can be up at a time — an open backdrop absorbs every
  # tap on the page, so no second trigger is reachable. They still stack rather
  # than picking a winner, because silently dropping an open dialog would hide
  # exactly the state bug this page exists to show.
  @impl true
  def overlay(assigns) do
    case Enum.filter(dialogs(assigns), & &1) do
      [] -> nil
      open -> %{type: :box, props: %{fill_width: true, fill_height: true}, children: open}
    end
  end

  defp dialogs(assigns) do
    [
      assigns.ad_confirm && confirm_dialog(),
      assigns.ad_stubborn && stubborn_dialog(),
      assigns.ad_delete && delete_dialog(),
      assigns.ad_slots && slots_dialog(),
      assigns.ad_chrome && chrome_dialog()
    ]
  end

  defp confirm_dialog do
    ~MOB"""
    <MishkaAlertDialog id="ad-confirm" open={true} on_close={:ad_confirm_cancel}>
      <MishkaDialogTitle text="Discard changes?" />
      <MishkaDialogDescription text="Your edits will be lost." />
      <MishkaAlertDialogAction text="Cancel" id="ad-confirm-cancel" />
      <MishkaAlertDialogAction
        text="Discard"
        id="ad-confirm-go"
        variant={:primary}
        on_tap={:ad_confirm_go}
      />
    </MishkaAlertDialog>
    """
  end

  # dismissible={true} is passed on purpose. It is dropped, and the unit tests
  # prove it — an alert dialog you can tap away is a Dialog.
  defp stubborn_dialog do
    ~MOB"""
    <MishkaAlertDialog id="ad-stubborn" open={true} dismissible={true} on_close={:ad_stubborn_close}>
      <MishkaDialogTitle text="Tap the backdrop" />
      <MishkaDialogDescription text="Nothing happens, and nothing behind it hears the tap either." />
      <MishkaAlertDialogAction text="Let me out" id="ad-stubborn-ok" />
    </MishkaAlertDialog>
    """
  end

  # The one dialog whose footer comes from DATA, and so the one that keeps the
  # function form. Two entries is a small list, but the shape is the point: a
  # comprehension grows with the data and repeated markup does not, which is why
  # action/2 and the actions prop are still here beside the tags.
  @delete_choices [
    %{label: "Cancel", id: "ad-delete-cancel", variant: :neutral, on_tap: nil},
    %{label: "Delete", id: "ad-delete-go", variant: :danger, on_tap: :ad_delete_go}
  ]

  defp delete_dialog do
    choices =
      Enum.map(@delete_choices, fn choice ->
        MishkaAlertDialog.action(choice.label,
          id: choice.id,
          variant: choice.variant,
          on_tap: choice.on_tap
        )
      end)

    ~MOB"""
    <MishkaAlertDialog id="ad-delete" open={true} on_close={:ad_delete_cancel} actions={choices}>
      <MishkaDialogTitle text="Delete account?" />
      <MishkaDialogDescription
        text="Everything you have stored will be removed. This cannot be undone."
      />
    </MishkaAlertDialog>
    """
  end

  # Subtrees rather than text= attributes: the title is an icon beside a heading
  # and the description is a meter, neither of which is expressible as a string.
  # The footer goes through <MishkaDialogFooter> so the nesting is exercised too
  # — an action tag inside another slot tag still has to become a button.
  #
  # The filled part of that meter is a fixed 230dp inside a fill-width track,
  # not a weighted Box: SwiftUI has no layout weight at all, so a proportional
  # bar would read as 98% on Android and as nothing on iOS. 230 is comfortably
  # inside the 320dp panel less its padding.
  defp slots_dialog do
    ~MOB"""
    <MishkaAlertDialog id="ad-slots" open={true} on_close={:ad_slots_close}>
      <MishkaDialogTitle>
        <Row fill_width={true}>
          <Text text="⚠" text_size={:xl} text_color={:error} />
          <Spacer size={8} />
          <Text text="Storage full" text_size={:xl} text_color={:on_surface} max_lines={1} />
        </Row>
      </MishkaDialogTitle>
      <MishkaDialogDescription>
        <Column fill_width={true}>
          <Text text="19.6 GB of 20 GB used" text_size={:base} text_color={:muted} />
          <Spacer size={6} />
          <Box fill_width={true} height={6} background={:border} corner_radius={:radius_sm}>
            <Box width={230} height={6} background={:error} corner_radius={:radius_sm} />
          </Box>
        </Column>
      </MishkaDialogDescription>
      <MishkaDialogFooter>
        <MishkaAlertDialogAction text="Got it" id="ad-slots-ok" />
      </MishkaDialogFooter>
    </MishkaAlertDialog>
    """
  end

  # The only example with a body — the bare Text below is not a slot tag, so it
  # lands in the content block and the -content tag has somewhere to go.
  defp chrome_dialog do
    ~MOB"""
    <MishkaAlertDialog
      id="ad-chrome"
      open={true}
      width={260}
      padding={:space_md}
      corner_radius={:radius_sm}
      background={:surface_raised}
      scrim_color={0xCC_00_00_00}
      on_close={:ad_chrome_close}
    >
      <MishkaDialogTitle text="Narrower, darker" />
      <MishkaDialogDescription text="260dp wide, tighter padding, a heavier scrim." />
      <Text
        text="Anything that is not a slot tag is the body."
        text_size={:base}
        text_color={:on_surface}
      />
      <MishkaAlertDialogAction text="Close" id="ad-chrome-ok" />
    </MishkaAlertDialog>
    """
  end

  @impl true
  def handle(:ad_confirm_open, socket), do: Mob.Socket.assign(socket, :ad_confirm, true)

  def handle(:ad_confirm_cancel, socket) do
    socket
    |> Mob.Socket.assign(:ad_confirm, false)
    |> Mob.Socket.assign(:ad_confirm_choice, "cancel")
  end

  def handle(:ad_confirm_go, socket) do
    socket
    |> Mob.Socket.assign(:ad_confirm, false)
    |> Mob.Socket.assign(:ad_confirm_choice, "discard")
  end

  def handle(:ad_stubborn_open, socket), do: Mob.Socket.assign(socket, :ad_stubborn, true)
  def handle(:ad_stubborn_close, socket), do: Mob.Socket.assign(socket, :ad_stubborn, false)

  def handle(:ad_stubborn_leak, socket),
    do: Mob.Socket.assign(socket, :ad_stubborn_leaks, socket.assigns.ad_stubborn_leaks + 1)

  def handle(:ad_delete_open, socket), do: Mob.Socket.assign(socket, :ad_delete, true)
  def handle(:ad_delete_cancel, socket), do: Mob.Socket.assign(socket, :ad_delete, false)

  def handle(:ad_delete_go, socket) do
    socket
    |> Mob.Socket.assign(:ad_delete, false)
    |> Mob.Socket.assign(:ad_delete_done, true)
  end

  def handle(:ad_slots_open, socket), do: Mob.Socket.assign(socket, :ad_slots, true)
  def handle(:ad_slots_close, socket), do: Mob.Socket.assign(socket, :ad_slots, false)

  def handle(:ad_chrome_open, socket), do: Mob.Socket.assign(socket, :ad_chrome, true)
  def handle(:ad_chrome_close, socket), do: Mob.Socket.assign(socket, :ad_chrome, false)

  # Both absorb tags land here: the backdrop's and the panel's. Swallowing them
  # is the contract every host screen owes an overlay.
  def handle(_tag, socket), do: socket

  defp trigger(label, tag, test_id) do
    ~MOB"""
    <Button
      text={label}
      background={:primary}
      text_color={:on_primary}
      padding={:space_sm}
      fill_width={true}
      on_tap={{self(), tag}}
      id={test_id}
    />
    """
  end

  defp choice_label(nil), do: "Nothing chosen yet"
  defp choice_label(choice), do: "You chose: #{choice}"

  defp deleted_label(true), do: "Account deleted"
  defp deleted_label(_intact), do: "Account intact"

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
            <Box width={20} height={9} background={:error} corner_radius={:radius_sm} />
          </Row>
        </Column>
      </Box>
    </Box>
    """
  end
end
