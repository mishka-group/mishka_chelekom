defmodule MishkaMob.Showcase.Components.Pill do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaPill`.

  The first example is live: the pills really are removable, and a reset button
  brings them back.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaPill, only: [pill: 1]

  alias MishkaMob.Showcase.Example

  # Enough tokens to need more than one line, like the headless "Inside inputs"
  # example — the point of that example is the wrapping, which a handful of
  # pills never shows.
  @tokens for i <- 0..9, do: {:"item_#{i}", "Item #{i}"}

  # Per row, declared rather than measured. Mob reports no geometry back to
  # render/1, so nothing can ask how many pills fit; MishkaOverflowList takes a
  # declared count for the same reason.
  @per_row 3

  @impl true
  def entry do
    %{
      slug: :pill,
      name: "Pill",
      category: "Data display",
      order: 1,
      description: "A compact label with an optional remove button."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:pill_tokens, Enum.map(@tokens, &elem(&1, 0)))
    |> Mob.Socket.assign(:pill_picked, nil)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Inside inputs",
        description:
          "The wrapping is the point: a Row does not wrap and Mob has no flow layout, " <>
            "so the screen chunks the tokens into rows itself.",
        code: ~S"""
        # A Row does not wrap, and Mob reports no geometry back, so nothing can
        # ask how many pills fit. Chunk by a DECLARED count and stack the rows.
        defp token_rows(tags) do
          rows =
            tags
            |> Enum.chunk_every(3)
            |> Enum.map(fn chunk ->
              pills =
                chunk
                |> Enum.map(fn tag ->
                  ~MOB"<MishkaPill label={tag.label} with_remove={true} on_remove={{:drop, tag.id}} />"
                end)
                |> Enum.intersperse(~MOB(<Spacer size={8} />))

              ~MOB"<Column fill_width={true}><Row>{pills}</Row><Spacer size={8} /></Column>"
            end)

          ~MOB"<Column fill_width={true}>{rows}</Column>"
        end

        # Each ✕ carries its own id, so one handler covers every token — a bare
        # {:drop} on all ten would arrive identically and name nothing.
        def handle_info({:tap, {:drop, id}}, socket) do
          {:noreply, assign(socket, :tags, List.delete(socket.assigns.tags, id))}
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
              {token_rows(@pill_tokens)}
            </Box>
            <Spacer size={14} />
            <Button
              text="Reset tokens"
              background={:surface_raised}
              text_color={:on_surface}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :token_reset}}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Tappable",
        description:
          "on_tap makes the body a target of its own. Tap one — the pick below " <>
            "comes back from the screen, not from the pill.",
        code: ~S"""
        <MishkaPill label="React" on_tap={{:pick, :react}} />
        <MishkaPill
          label="Elixir"
          on_tap={{:pick, :elixir}}
          background={@picked == :elixir && :primary || :surface_raised}
        />

        # on_tap is the BODY. Add on_remove and the two arrive as separate
        # events from separate targets, so one pill selects AND dismisses.
        def handle_info({:tap, {:pick, id}}, socket) do
          {:noreply, assign(socket, :picked, id)}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              {picker(:react, "React", @pill_picked)}
              <Spacer size={8} />
              {picker(:elixir, "Elixir", @pill_picked)}
              <Spacer size={8} />
              {picker(:swift, "Swift", @pill_picked)}
            </Row>
            <Spacer size={10} />
            <Text text={picked_label(@pill_picked)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Plain",
        description: "Without with_remove it is just a label, as wide as its text.",
        code: ~S"""
        <Row fill_width={true}>
          <MishkaPill label="read-only" />
          <Spacer size={8} />
          <MishkaPill label="v1.0.0" />
        </Row>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaPill label="read-only" />
            <Spacer size={8} />
            <MishkaPill label="v1.0.0" />
            <Spacer size={8} />
            <MishkaPill label="beta" />
          </Row>
          """
        end
      },
      %Example{
        title: "Colour",
        description: "background and color are props, and take a token or an ARGB int.",
        code: ~S"""
        <MishkaPill
          label="shipped"
          background={0xFF7C3AED}
          color={0xFFFFFFFF}
          with_remove={true}
          on_remove={:unship}
        />
        <MishkaPill label="queued" background={:primary} color={:on_primary} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaPill label="shipped" background={0xFF7C3AED} color={0xFFFFFFFF} with_remove={true} />
            <Spacer size={8} />
            <MishkaPill label="failed" background={0xFFDC2626} color={0xFFFFFFFF} />
            <Spacer size={8} />
            <MishkaPill label="queued" background={:primary} color={:on_primary} />
          </Row>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted, and neither the body nor the ✕ responds — the handlers are dropped.",
        code: ~S"""
        # on_tap and on_remove are both given here and NEITHER is wired: disabled
        # drops the handlers rather than guarding them, so no event is sent at all.
        <MishkaPill
          label="locked"
          with_remove={true}
          disabled={true}
          on_tap={:nope}
          on_remove={:nope}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaPill
              label="locked"
              with_remove={true}
              disabled={true}
              on_tap={:nope}
              on_remove={:nope}
            />
            <Spacer size={8} />
            <MishkaPill label="archived" disabled={true} disabled_color={0xFF9CA3AF} />
          </Row>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "label",
        type: "string",
        default: "nil",
        description: "The pill's text. Children override it."
      },
      %{
        name: "with_remove",
        type: "boolean",
        default: "false",
        description: "Render the trailing ✕."
      },
      %{
        name: "on_remove",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, tag} when the ✕ is tapped."
      },
      %{
        name: "on_tap",
        type: "event tag",
        default: "—",
        description: "Makes the pill body itself tappable, separately from the ✕."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Mutes it and wires no handlers, including the ✕."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Pill fill."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Label colour."
      },
      %{
        name: "disabled_color",
        type: "color / ARGB",
        default: ":muted",
        description: "Label colour while disabled."
      }
    ]
  end

  @impl true
  def handle({:token_drop, id}, socket),
    do: Mob.Socket.assign(socket, :pill_tokens, List.delete(socket.assigns.pill_tokens, id))

  def handle(:token_reset, socket),
    do: Mob.Socket.assign(socket, :pill_tokens, Enum.map(@tokens, &elem(&1, 0)))

  def handle({:pill_pick, id}, socket), do: Mob.Socket.assign(socket, :pill_picked, id)

  def handle(_tag, socket), do: socket

  # The selected pill is drawn differently — proof on screen that the tap made
  # the round trip rather than being swallowed.
  defp picker(id, label, picked) when id == picked do
    pill(label: label, background: :primary, color: :on_primary, on_tap: {:pill_pick, id})
  end

  defp picker(id, label, _picked), do: pill(label: label, on_tap: {:pill_pick, id})

  defp picked_label(nil), do: "Nothing picked yet — tap a pill."
  defp picked_label(id), do: "Picked: #{id} (sent as {:tap, {:pill_pick, :#{id}}})"

  # A Row does not wrap and Mob has no flow layout, so the wrap is done here:
  # chunk into rows of @per_row and stack them in a Column. That is the same
  # trade MishkaOverflowList makes — a declared count instead of a measured one.
  defp token_rows([]) do
    ~MOB(<Text text="No tags left. Reset to bring them back." text_size={:sm} text_color={:muted} />)
  end

  defp token_rows(ids) do
    rows =
      @tokens
      |> Enum.filter(fn {id, _} -> id in ids end)
      |> Enum.chunk_every(@per_row)
      |> Enum.map(fn chunk ->
        pills =
          chunk
          |> Enum.map(fn {id, label} ->
            pill(label: label, with_remove: true, on_remove: {:token_drop, id})
          end)
          |> Enum.intersperse(%{type: :spacer, props: %{size: 8}, children: []})

        ~MOB"""
        <Column fill_width={true}>
          <Row>
            {pills}
          </Row>
          <Spacer size={8} />
        </Column>
        """
      end)

    ~MOB(<Column fill_width={true}>
  {rows}
</Column>)
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={58} height={20} background={:surface_raised} corner_radius={:radius_pill} />
        <Spacer size={8} />
        <Box width={44} height={20} background={:surface_raised} corner_radius={:radius_pill} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={66} height={20} background={:primary} corner_radius={:radius_pill} />
        <Spacer size={8} />
        <Box width={34} height={20} background={:surface_raised} corner_radius={:radius_pill} />
      </Row>
    </Column>
    """
  end
end
