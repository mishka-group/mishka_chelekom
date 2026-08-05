defmodule MishkaMob.Showcase.Components.LoadingOverlay do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaLoadingOverlay`.

  Every example is live: the overlay really covers its region, and the counter
  under the first one proves it really absorbs the taps aimed at what it covers.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :loading_overlay,
      name: "Loading Overlay",
      category: "Feedback",
      order: 6,
      description: "A scrim over a busy region that also absorbs taps."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:lo_busy, false)
    |> Mob.Socket.assign(:lo_hits, 0)
    |> Mob.Socket.assign(:lo_plain, false)
    |> Mob.Socket.assign(:lo_custom, false)
    |> Mob.Socket.assign(:lo_page, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "It absorbs the taps it covers",
        description:
          "Tap the card to raise the count, then start the work and tap it again. " <>
            "The count does not move — which is what a spinner beside the button " <>
            "cannot give you.",
        code: ~S"""
        # Put it LAST inside the Box it covers: a Box stacks its children, so
        # whatever comes after is drawn on top and takes the taps.
        <Box>
          {content}
          <MishkaLoadingOverlay visible={@saving?} label="Saving…" />
        </Box>

        def handle_info({:tap, :save}, socket) do
          {:noreply, Mob.Socket.assign(socket, :saving?, true)}
        end

        # The scrim sends a no-op tag of its own while visible. The catch-all
        # every screen needs already swallows it — that is the whole mechanism.
        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Box
              fill_width={true}
              height={120}
              background={:surface_raised}
              corner_radius={:radius_md}
              on_tap={{self(), :lo_hit}}
            >
              <Column fill_width={true} padding={:space_md}>
                <Text text="Order #1042" text_size={:lg} text_color={:on_surface} />
                <Spacer size={6} />
                <Text text={hits_label(@lo_hits)} text_size={:sm} text_color={:muted} />
              </Column>
              <MishkaLoadingOverlay visible={@lo_busy} label="Saving…" corner_radius={:radius_md} />
            </Box>
            <Spacer size={12} />
            <Button
              text={if(@lo_busy, do: "Finish", else: "Start saving")}
              background={:primary}
              text_color={:on_primary}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :lo_busy}}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Without a label",
        description: "The indicator alone, when the surrounding screen already says why.",
        code: ~S"""
        <MishkaLoadingOverlay visible={@busy?} />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Box fill_width={true} height={90} background={:surface_raised} corner_radius={:radius_md}>
              <Column fill_width={true} padding={:space_md}>
                <Text text="Refreshing prices" text_size={:base} text_color={:on_surface} />
              </Column>
              <MishkaLoadingOverlay visible={@lo_plain} corner_radius={:radius_md} />
            </Box>
            <Spacer size={12} />
            <Button
              text={if(@lo_plain, do: "Stop", else: "Refresh")}
              background={:surface_raised}
              text_color={:on_surface}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :lo_plain}}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Its own scrim, panel and indicator",
        description:
          "scrim_color, panel_color and color are props. A dark scrim wants a " <>
            "dark panel — the indicator sits on the panel, not on the scrim.",
        code: ~S"""
        <MishkaLoadingOverlay
          visible={@busy?}
          scrim_color={0xE6111827}
          panel_color={0xFF1F2937}
          color={:on_primary}
          label="Uploading…"
        />

        # Or supply your own body — children replace the indicator:
        <MishkaLoadingOverlay visible={@busy?}>{[my_spinner()]}</MishkaLoadingOverlay>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Box fill_width={true} height={110} background={:surface_raised} corner_radius={:radius_md}>
              <Column fill_width={true} padding={:space_md}>
                <Text text="photo-2048.heic" text_size={:base} text_color={:on_surface} />
                <Spacer size={4} />
                <Text text="4.2 MB" text_size={:sm} text_color={:muted} />
              </Column>
              <MishkaLoadingOverlay
                visible={@lo_custom}
                scrim_color={0xE6111827}
                panel_color={0xFF1F2937}
                color={:on_primary}
                label="Uploading…"
                corner_radius={:radius_md}
              />
            </Box>
            <Spacer size={12} />
            <Button
              text={if(@lo_custom, do: "Cancel", else: "Upload")}
              background={:surface_raised}
              text_color={:on_surface}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :lo_custom}}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Over the whole page, with a body of your own",
        description:
          "The real-world shape: a glass scrim over the entire screen with the " <>
            "content straight on it — icon, headline, progress detail and a way " <>
            "out, no card of its own. Children replace the indicator, so " <>
            "everything inside is yours.",
        code: ~S"""
        # A screen-wide overlay goes at the SCREEN root, not inside a card. Here
        # that is the showcase's overlay/1; in your app it is the outermost Box
        # of render/1, with the overlay as its last child.
        def overlay(assigns) do
          panel = sync_panel()
          ~MOB(<MishkaLoadingOverlay visible={@syncing?} scrim_color={0xE6FFFFFF}>
            {panel}
          </MishkaLoadingOverlay>)
        end

        # Children replace the indicator entirely — panel and all — so supply
        # your own Progress, or nothing on the overlay will move.
        #   <Box width={272}>
        #     <Text text="☁️" fill_width={true} text_align={:center} />
        #     <Text text="Syncing your library" ... />
        #     <Progress color={:primary} />
        #     <Button text="Cancel" background={:transparent} text_color={:primary}
        #             fill_width={true} on_tap={{self(), :cancel}} />
        #   </Box>
        #
        # No background anywhere — the content sits on the glass. The button
        # needs background={:transparent} explicitly, or Compose draws a filled
        # M3 button in its place.
        #
        # A Column cannot centre its children, so the Texts centre themselves
        # with text_align and the Progress and Button fill the panel instead.

        # The scrim absorbs taps, but a control INSIDE it still gets its own —
        # children are hit-tested before the scrim beneath them.
        def handle(:cancel, socket), do: Mob.Socket.assign(socket, :syncing?, false)
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="Covers the whole screen, not just a card — scroll is blocked and every tap is absorbed until it finishes."
              text_size={:sm}
              text_color={:muted}
            />
            <Spacer size={12} />
            <Button
              text="Sync 12 files"
              background={:primary}
              text_color={:on_primary}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :lo_page}}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Invisible costs nothing",
        description: "Not visible renders an empty Column — no scrim, no indicator, no handler.",
        code: ~S"""
        # Safe to leave in the tree permanently; it builds nothing until it is
        # asked to. There is no need to wrap it in an :if.
        <MishkaLoadingOverlay visible={false} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Box fill_width={true} height={70} background={:surface_raised} corner_radius={:radius_md}>
            <Column fill_width={true} padding={:space_md}>
              <Text
                text="Nothing covers this — the overlay below is invisible."
                text_size={:sm}
                text_color={:muted}
              />
            </Column>
            <MishkaLoadingOverlay visible={false} />
          </Box>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "visible",
        type: "boolean",
        default: "false",
        description: "Whether the overlay is shown. False renders an empty Column."
      },
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "Text under the indicator. Omitted entirely when nil."
      },
      %{
        name: "scrim_color",
        type: "ARGB / token",
        default: "0xCCFFFFFF",
        description: "Scrim fill. Semi-transparent, so the covered content stays legible."
      },
      %{
        name: "panel_color",
        type: "color / ARGB",
        default: ":surface",
        description: "The panel the indicator sits on. Go dark when the scrim is dark."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Indicator colour."
      },
      %{
        name: "corner_radius",
        type: "radius token / number",
        default: "nil",
        description:
          "Match the region it covers — on iOS the scrim overhangs a rounded card without it."
      },
      %{
        name: "children",
        type: "nodes",
        default: "—",
        description: "Replace the indicator and label with a body of your own."
      }
    ]
  end

  # A screen-wide overlay belongs at the screen root. ComponentScreen stacks
  # whatever overlay/1 returns over the whole page, which is the same slot the
  # Drawer and Toast use — inside an example card it could only ever cover the
  # card.
  @impl true
  def overlay(%{lo_page: true}) do
    panel = sync_panel()

    ~MOB"""
    <MishkaLoadingOverlay visible={true} scrim_color={0xE6FFFFFF}>
      {panel}
    </MishkaLoadingOverlay>
    """
  end

  def overlay(_assigns), do: nil

  # Nothing here has a surface of its own: the content sits straight on the
  # glass, which is what the scrim's alpha is for. The Cancel button gets
  # `background: :transparent` (renderer.ex resolves it to 0x00000000) — without
  # it, Compose falls back to `ButtonDefaults.buttonColors()` and draws a filled
  # M3 button, which is the grey box this deliberately does not have.
  #
  # Children replace the indicator, panel and all, so this supplies its own
  # Progress or nothing on the overlay would move. A Column cannot centre its
  # children, so the Texts centre themselves with text_align and the Progress
  # and Button fill the width instead.
  defp sync_panel do
    cancel = {self(), :lo_page_cancel}

    ~MOB"""
    <Box width={272}>
      <Column fill_width={true}>
        <Text text="☁️" text_size={:"3xl"} fill_width={true} text_align={:center} />
        <Spacer size={10} />
        <Text
          text="Syncing your library"
          text_size={:base}
          text_color={:on_surface}
          font_weight={:semibold}
          fill_width={true}
          text_align={:center}
        />
        <Spacer size={4} />
        <Text
          text="3 of 12 files · 4.2 MB"
          text_size={:sm}
          text_color={:muted}
          fill_width={true}
          text_align={:center}
        />
        <Spacer size={18} />
        <Progress color={:primary} />
        <Spacer size={14} />
        <Button
          text="Cancel"
          background={:transparent}
          text_color={:primary}
          padding={:space_sm}
          fill_width={true}
          on_tap={cancel}
        />
      </Column>
    </Box>
    """
  end

  def handle(:lo_page, socket),
    do: Mob.Socket.assign(socket, :lo_page, true)

  def handle(:lo_page_cancel, socket),
    do: Mob.Socket.assign(socket, :lo_page, false)

  @impl true
  def handle(:lo_busy, socket),
    do: Mob.Socket.assign(socket, :lo_busy, not socket.assigns.lo_busy)

  def handle(:lo_plain, socket),
    do: Mob.Socket.assign(socket, :lo_plain, not socket.assigns.lo_plain)

  def handle(:lo_custom, socket),
    do: Mob.Socket.assign(socket, :lo_custom, not socket.assigns.lo_custom)

  # The count the first example is really about: this handler is wired to the
  # card UNDER the scrim, so it must stop moving the moment the overlay appears.
  def handle(:lo_hit, socket),
    do: Mob.Socket.assign(socket, :lo_hits, socket.assigns.lo_hits + 1)

  def handle(_tag, socket), do: socket

  defp hits_label(0), do: "Tapped 0 times — tap this card."
  defp hits_label(1), do: "Tapped once."
  defp hits_label(n), do: "Tapped #{n} times."

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} height={64} background={:surface_raised} corner_radius={:radius_md}>
      <Column fill_width={true} padding={8}>
        <Box width={70} height={8} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box width={46} height={8} background={:muted} corner_radius={:radius_sm} />
      </Column>
      <Box
        fill_width={true}
        fill_height={true}
        align={:center}
        background={0xCCFFFFFF}
        corner_radius={:radius_md}
      >
        <Box width={80} height={6} background={:primary} corner_radius={:radius_pill} />
      </Box>
    </Box>
    """
  end
end
