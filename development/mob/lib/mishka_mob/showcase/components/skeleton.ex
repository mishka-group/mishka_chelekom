defmodule MishkaMob.Showcase.Components.Skeleton do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaSkeleton`.

  The first example is live: it swaps the placeholder for the real row, which is
  the only way to see whether the two actually line up.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :skeleton,
      name: "Skeleton",
      category: "Feedback",
      order: 7,
      description: "A placeholder for content that has not arrived."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :sk_loaded, false)

  @impl true
  def examples do
    [
      %Example{
        title: "Standing in for a real row",
        description:
          "Tap to load. A skeleton only works if it is the same shape as what " <>
            "replaces it — anything else makes the content jump on arrival.",
        code: ~S"""
        # Same sizes on both sides of the branch: a 40 circle and two text lines
        # either way, so nothing moves when the data lands.
        if @loaded do
          ~MOB"<MishkaAvatar src={@user.avatar} size={40} />"
        else
          ~MOB"<MishkaSkeleton shape={:circle} size={40} />"
        end

        def handle_info({:tap, :load}, socket) do
          {:noreply, Mob.Socket.assign(socket, :loaded, true)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Box
              fill_width={true}
              background={:surface}
              corner_radius={:radius_md}
              border_color={:border}
              border_width={1}
              padding={:space_md}
            >
              {row(@sk_loaded)}
            </Box>
            <Spacer size={12} />
            <Button
              text={if(@sk_loaded, do: "Reset", else: "Load")}
              background={:primary}
              text_color={:on_primary}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :sk_toggle}}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Text",
        description:
          "The last line is short, because a real paragraph does not end flush " <>
            "with the margin. It is a Row weight, not a measured width.",
        code: ~S"""
        <MishkaSkeleton shape={:text} lines={3} />
        <MishkaSkeleton shape={:text} lines={2} last_line={0.35} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSkeleton shape={:text} lines={3} id="sk-text" />
            <Spacer size={20} />
            <MishkaSkeleton shape={:text} lines={2} last_line={0.35} />
            <Spacer size={20} />
            <MishkaSkeleton shape={:text} lines={1} last_line={1.0} height={18} />
          </Column>
          """
        end
      },
      %Example{
        title: "Blocks and circles",
        description: "A block fills its parent unless given a width; a circle always hugs.",
        code: ~S"""
        <MishkaSkeleton shape={:circle} size={56} />
        <MishkaSkeleton height={90} />                 # fills the width
        <MishkaSkeleton width={120} height={40} />     # exactly 120 wide
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true} align={:center}>
              <MishkaSkeleton shape={:circle} size={56} />
              <Spacer size={12} />
              <MishkaSkeleton shape={:circle} size={40} />
              <Spacer size={12} />
              <MishkaSkeleton shape={:circle} size={28} />
            </Row>
            <Spacer size={16} />
            <MishkaSkeleton height={90} />
            <Spacer size={12} />
            <Row fill_width={true}>
              <MishkaSkeleton width={120} height={40} />
              <Spacer size={12} />
              <MishkaSkeleton width={70} height={40} corner_radius={0} />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "It does not shimmer",
        description:
          "Box, Text, Row and Column expose no opacity or transition, so nothing " <>
            "here can fade. A gpu_view shader could — it redraws every frame — but " <>
            "it needs a uniform pushed from Elixir at 60 Hz and a GL surface per " <>
            "placeholder, which is a lot to fade a grey box.",
        code: ~S"""
        # For motion that means "work is happening", these animate for free:
        <MishkaProgress />
        <MishkaLoadingOverlay visible={@busy?} />
        """,
        render: fn _assigns ->
          # Deliberately NOT rendering a live Progress here. An indeterminate
          # one animates forever, and Compose never reports idle while it does —
          # which hangs performScrollTo for every device test that lands on this
          # page afterwards, the whole suite included. A page about a static
          # placeholder is the last place to put a perpetual animation.
          ~MOB"""
          <Column fill_width={true}>
            <MishkaSkeleton shape={:text} lines={2} />
            <Spacer size={16} />
            <Text
              text="For a moving indicator see Progress or Loading Overlay."
              text_size={:sm}
              text_color={:muted}
            />
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
        name: "shape",
        type: ":block · :text · :circle",
        default: ":block",
        description: "What is being stood in for."
      },
      %{
        name: "width",
        type: "number",
        default: "fills",
        description: "Exact width. Omit and a block fills its parent."
      },
      %{
        name: "height",
        type: "number",
        default: "12 text / 80 block",
        description: "Bar or block height. A circle uses size instead."
      },
      %{name: "size", type: "number", default: "40", description: "Circle diameter, both axes."},
      %{name: "lines", type: "integer", default: "3", description: "Text only: how many bars."},
      %{
        name: "last_line",
        type: "0.0–1.0",
        default: "0.6",
        description: "Text only: the last bar's share of the width. Clamped."
      },
      %{name: "gap", type: "number", default: "8", description: "Text only: space between bars."},
      %{
        name: "color",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Placeholder fill."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: "per shape",
        description: "Pill for text, size/2 for a circle, :radius_md for a block."
      },
      %{
        name: "id",
        type: "string",
        default: "—",
        description: "A native testTag. :text numbers its bars id-0, id-1, … "
      }
    ]
  end

  @impl true
  def handle(:sk_toggle, socket),
    do: Mob.Socket.assign(socket, :sk_loaded, not socket.assigns.sk_loaded)

  def handle(_tag, socket), do: socket

  # Both branches build the same shape at the same sizes — that agreement is the
  # whole point of a skeleton, and it is what the example is there to show.
  defp row(true) do
    ~MOB"""
    <Row fill_width={true} align={:center}>
      <MishkaAvatar name="Ada Lovelace" size={40} />
      <Spacer size={12} />
      <Column fill_width={true}>
        <Text text="Ada Lovelace" text_size={:base} text_color={:on_surface} />
        <Spacer size={6} />
        <Text text="Wrote the first program" text_size={:sm} text_color={:muted} />
      </Column>
    </Row>
    """
  end

  defp row(false) do
    ~MOB"""
    <Row fill_width={true} align={:center}>
      <MishkaSkeleton shape={:circle} size={40} />
      <Spacer size={12} />
      <Column fill_width={true}>
        <MishkaSkeleton shape={:text} lines={2} last_line={0.5} />
      </Column>
    </Row>
    """
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true} align={:center}>
      <Box width={30} height={30} background={:muted} corner_radius={15} />
      <Spacer size={10} />
      <Column fill_width={true}>
        <Box fill_width={true} height={8} background={:muted} corner_radius={:radius_pill} />
        <Spacer size={7} />
        <Row fill_width={true}>
          <Box weight={0.55} height={8} background={:muted} corner_radius={:radius_pill} />
          <Spacer weight={0.45} />
        </Row>
      </Column>
    </Row>
    """
  end
end
