defmodule MishkaMob.Showcase.Components.Spoiler do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSpoiler`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @long "Mob runs the BEAM on the device itself, so a screen is a GenServer and the UI is a tree of native widgets rather than a WebView. Hot code push means a new render can arrive without a rebuild, and the whole OTP toolkit — supervisors, ETS, Ecto — is available on the phone."
  @short "Mob runs the BEAM on the device itself, so a screen is a GenServer…"

  @impl true
  def entry do
    %{
      slug: :spoiler,
      name: "Spoiler",
      category: "Disclosure",
      order: 2,
      description: "Long content behind a Show more control."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:sp_open, false)
    |> Mob.Socket.assign(:sp_plain, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Revealing the rest",
        description: "The control sits under the content and changes label as it works.",
        code: ~S"""
        <MishkaSpoiler
          expanded={@open?}
          preview={preview()}
          on_toggle={:more}
        >{full_text()}</MishkaSpoiler>

        # A bare tag: a spoiler has one region, so nothing needs identifying.
        # The control's label follows the boolean — "Show more" becomes
        # "Show less" — so the screen only ever flips it.
        def handle_info({:tap, :more}, socket) do
          {:noreply, Mob.Socket.assign(socket, :open?, not socket.assigns.open?)}
        end

        def handle_info(_msg, socket), do: {:noreply, socket}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSpoiler expanded={@sp_open} preview={para(short())} on_toggle={:sp_open}>
              {para(long())}
            </MishkaSpoiler>
          </Column>
          """
        end
      },
      %Example{
        title: "Custom labels",
        description: "show_label and hide_label replace the defaults.",
        code: ~S"""
        <MishkaSpoiler
          show_label="Read the rest"
          hide_label="Collapse"
        >{content}</MishkaSpoiler>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSpoiler
              expanded={@sp_plain}
              show_label="Read the rest"
              hide_label="Collapse"
              on_toggle={:sp_plain}
            >
              {para(long())}
            </MishkaSpoiler>
          </Column>
          """
        end
      },
      %Example{
        title: "No preview",
        description: "Without a preview the control stands alone until it is opened.",
        code: ~S"""
        <MishkaSpoiler expanded={@open?} on_toggle={:more}>{content}</MishkaSpoiler>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSpoiler expanded={@sp_plain} on_toggle={:sp_plain}>
              {para("Surprise — this was hidden.")}
            </MishkaSpoiler>
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "expanded",
        type: "boolean",
        default: "false",
        description: "Whether the content is revealed. Lives in the screen."
      },
      %{
        name: "show_label",
        type: "string",
        default: "\"Show more\"",
        description: "Control label while collapsed."
      },
      %{
        name: "hide_label",
        type: "string",
        default: "\"Show less\"",
        description: "Control label while expanded."
      },
      %{
        name: "preview",
        type: "list of nodes",
        default: "[]",
        description: "What to show while collapsed, e.g. a truncated line."
      },
      %{name: "on_toggle", type: "event tag", default: "—", description: "Sent as {:tap, tag}."},
      %{
        name: "padding",
        type: "number",
        default: "10",
        description: "Vertical padding around the control — it IS the tap target."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Control colour."
      }
    ]
  end

  @impl true
  def handle(:sp_open, socket), do: flip(socket, :sp_open)
  def handle(:sp_plain, socket), do: flip(socket, :sp_plain)
  def handle(_tag, socket), do: socket

  defp flip(socket, key), do: Mob.Socket.assign(socket, key, not Map.fetch!(socket.assigns, key))

  defp para(text),
    do: [%{type: :text, props: %{text: text, text_size: :base, text_color: :muted}, children: []}]

  defp long, do: @long
  defp short, do: @short

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box fill_width={true} height={8} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={5} />
      <Box fill_width={true} height={8} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={5} />
      <Box width={80} height={8} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={10} />
      <Box width={54} height={9} background={:primary} corner_radius={:radius_sm} />
    </Column>
    """
  end
end
