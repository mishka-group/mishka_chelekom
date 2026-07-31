defmodule MishkaMob.Showcase.Components.Chip do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaChip`.

  Shows both selection shapes the web component gets from `type`: the first
  example toggles membership (checkbox chips), the second replaces the selection
  (radio chips). The difference lives in the handler, not the chip.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaChip, only: [chip: 1]

  alias MishkaMob.Showcase.Example

  @tags [{:elixir, "Elixir"}, {:erlang, "Erlang"}, {:gleam, "Gleam"}]
  @sizes [{:s, "Low"}, {:m, "Normal"}, {:l, "High"}]

  @impl true
  def entry do
    %{
      slug: :chip,
      name: "Chip",
      category: "Forms",
      order: 2,
      description: "A compact, selectable label."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:chip_tags, [:elixir])
    |> Mob.Socket.assign(:chip_size, :m)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Multi-select",
        description: "Checkbox chips: the handler toggles membership.",
        code: ~S"""
        <MishkaChip label="Elixir" checked={:elixir in @tags} on_toggle={{:tag, :elixir}} />

        # The tag is COMPOSED with the chip's id, so one clause serves every chip.
        # Note the shape: {:tag, id}, not a bare :tag — a bare atom would give you
        # no way to tell which chip was tapped.
        def handle({:tag, id}, socket) do
          tags = socket.assigns.tags

          next = if id in tags, do: List.delete(tags, id), else: [id | tags]
          Mob.Socket.assign(socket, :tags, next)
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row fill_width={true}>
              {tag_chips(@chip_tags)}
            </Row>
            <Spacer size={12} />
            <Text text={"Selected: " <> summary(@chip_tags)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Single select",
        description:
          "Radio chips: the handler replaces the selection. Labelled by " <>
            "priority, not by size — chips are all one size; only the label differs.",
        code: ~S"""
        # Single select replaces rather than toggles — there is no way to clear it,
        # which is exactly what makes it a radio group and not a checkbox set.
        def handle({:size, id}, socket),
          do: Mob.Socket.assign(socket, :size, id)
        """,
        render: fn assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {size_chips(@chip_size)}
          </Row>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Muted and inert, whether or not it is checked.",
        code: ~S"""
        <MishkaChip label="Locked" checked={true} disabled={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaChip label="Locked on" checked={true} disabled={true} />
            <Spacer size={8} />
            <MishkaChip label="Locked off" disabled={true} />
          </Row>
          """
        end
      },
      %Example{
        title: "Colour",
        description: "color fills the chip when checked; text_color labels it.",
        code: ~S"""
        <MishkaChip label="Violet" checked={true} color={0xFF7C3AED} text_color={0xFFFFFFFF} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaChip label="Violet" checked={true} color={0xFF7C3AED} text_color={0xFFFFFFFF} />
            <Spacer size={8} />
            <MishkaChip label="Danger" checked={true} color={0xFFDC2626} text_color={0xFFFFFFFF} />
            <Spacer size={8} />
            <MishkaChip label="Default" checked={true} />
          </Row>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "label", type: "string", default: "nil", description: "The chip's text."},
      %{
        name: "checked",
        type: "boolean",
        default: "false",
        description: "Whether it reads as selected. Lives in the screen."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Wires no handler and mutes the chip."
      },
      %{
        name: "on_toggle",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, tag}."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "Fill when checked."
      },
      %{
        name: "text_color",
        type: "color / ARGB",
        default: ":on_primary",
        description: "Label colour when checked."
      }
    ]
  end

  @impl true
  def handle({:chip_tag, id}, socket) do
    tags = socket.assigns.chip_tags
    next = if id in tags, do: List.delete(tags, id), else: tags ++ [id]
    Mob.Socket.assign(socket, :chip_tags, next)
  end

  def handle({:chip_size, id}, socket), do: Mob.Socket.assign(socket, :chip_size, id)
  def handle(_tag, socket), do: socket

  defp tag_chips(selected) do
    @tags
    |> Enum.map(fn {id, label} ->
      chip(label: label, checked: id in selected, on_toggle: {:chip_tag, id})
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 8}, children: []})
  end

  defp size_chips(selected) do
    @sizes
    |> Enum.map(fn {id, label} ->
      chip(label: label, checked: id == selected, on_toggle: {:chip_size, id})
    end)
    |> Enum.intersperse(%{type: :spacer, props: %{size: 8}, children: []})
  end

  defp summary([]), do: "none"
  defp summary(ids), do: Enum.map_join(ids, ", ", &to_string/1)

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={52} height={20} background={:primary} corner_radius={:radius_pill} />
        <Spacer size={8} />
        <Box width={44} height={20} background={:surface_raised} corner_radius={:radius_pill} />
      </Row>
      <Spacer size={10} />
      <Row fill_width={true}>
        <Box width={38} height={20} background={:surface_raised} corner_radius={:radius_pill} />
        <Spacer size={8} />
        <Box width={56} height={20} background={:surface_raised} corner_radius={:radius_pill} />
      </Row>
    </Column>
    """
  end
end
