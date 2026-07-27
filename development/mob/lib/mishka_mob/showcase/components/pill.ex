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

  @all [{:elixir, "elixir"}, {:beam, "beam"}, {:mobile, "mobile"}, {:native, "native"}]

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
  def mount(socket), do: Mob.Socket.assign(socket, :pill_tags, Enum.map(@all, &elem(&1, 0)))

  @impl true
  def examples do
    [
      %Example{
        title: "Removable tokens",
        description: "The ✕ carries its own handler — tap it to drop a tag.",
        code: ~S"""
        <MishkaPill label="elixir" with_remove={true} on_remove={{:drop, :elixir}} />

        def handle_info({:tap, {:drop, id}}, socket) do
          {:noreply, assign(socket, :tags, List.delete(socket.assigns.tags, id))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              {token_pills(@pill_tags)}
            </Row>
            <Spacer size={14} />
            <Button
              text="Reset tags"
              background={:surface_raised}
              text_color={:on_surface}
              padding={:space_sm}
              fill_width={true}
              on_tap={{self(), :pill_reset}}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Plain",
        description: "Without with_remove it is just a label.",
        code: ~S"""
        <MishkaPill label="read-only" />
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
        description: "background and color are props.",
        code: ~S"""
        <MishkaPill label="shipped" background={0xFF7C3AED} color={0xFFFFFFFF} />
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
        description: "Muted, and neither the body nor the ✕ responds.",
        code: ~S"""
        <MishkaPill label="locked" with_remove={true} disabled={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaPill label="locked" with_remove={true} disabled={true} on_remove={:nope} />
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
      }
    ]
  end

  @impl true
  def handle({:pill_drop, id}, socket),
    do: Mob.Socket.assign(socket, :pill_tags, List.delete(socket.assigns.pill_tags, id))

  def handle(:pill_reset, socket),
    do: Mob.Socket.assign(socket, :pill_tags, Enum.map(@all, &elem(&1, 0)))

  def handle(_tag, socket), do: socket

  defp token_pills([]) do
    [
      %{
        type: :text,
        props: %{text: "All removed.", text_size: :sm, text_color: :muted},
        children: []
      }
    ]
  end

  defp token_pills(ids) do
    @all
    |> Enum.filter(fn {id, _} -> id in ids end)
    |> Enum.map(fn {id, label} ->
      pill(label: label, with_remove: true, on_remove: {:pill_drop, id})
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 8}, children: []})
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
