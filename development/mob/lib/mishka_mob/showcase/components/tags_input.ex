defmodule MishkaMob.Showcase.Components.TagsInput do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTagsInput`.

  Fully live: type a tag, press return, tap a ✕ to remove it.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaTagsInput
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :tags_input,
      name: "Tags Input",
      category: "Forms",
      order: 13,
      description: "Removable tokens with a draft field, committed on return."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:ti_tags, ["elixir", "beam"])
    |> Mob.Socket.assign(:ti_draft, "")
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Add and remove",
        description: "Press return to commit the draft; each token's ✕ removes it.",
        code: ~S"""
        <MishkaTagsInput
          tags={@tags}
          draft={@draft}
          on_draft={:draft}
          on_add={:add}
          on_remove={:remove}
        />

        # submit carries no text — commit the draft you already hold
        def handle_info({:submit, :add}, socket) do
          {:noreply, socket
             |> assign(:tags, MishkaTagsInput.add(socket.assigns.tags, socket.assigns.draft))
             |> assign(:draft, "")}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTagsInput
              tags={@ti_tags}
              draft={@ti_draft}
              placeholder="Add a tag…"
              on_draft={:ti_draft}
              on_add={:ti_add}
              on_remove={:ti_remove}
            />
            <Spacer size={10} />
            <Text text={summary(@ti_tags)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Duplicates are refused",
        description: "add/3 trims and rejects a repeat, so callers cannot forget to.",
        code: ~S"""
        MishkaTagsInput.add(["elixir"], "  elixir  ")   #=> ["elixir"]
        MishkaTagsInput.add(["elixir"], "elixir", allow_duplicates: true)
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Text
              text="Try adding a tag you already have — it is trimmed and refused."
              text_size={:sm}
              text_color={:muted}
            />
            <Spacer size={10} />
            <MishkaTagsInput
              tags={@ti_tags}
              draft={@ti_draft}
              on_draft={:ti_draft}
              on_add={:ti_add}
              on_remove={:ti_remove}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Empty and disabled",
        description: "With no tags the control is just its draft field.",
        code: ~S"""
        <MishkaTagsInput tags={[]} placeholder="Nothing yet" />
        <MishkaTagsInput tags={["locked"]} disabled={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTagsInput tags={[]} placeholder="Nothing yet…" />
            <Spacer size={12} />
            <MishkaTagsInput tags={["locked", "readonly"]} disabled={true} placeholder="Disabled" />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "tags", type: "list of strings", default: "[]", description: "The current tokens."},
      %{name: "draft", type: "string", default: "\"\"", description: "The text field's value."},
      %{
        name: "placeholder",
        type: "string",
        default: "nil",
        description: "Draft placeholder."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Mutes and unwires everything."
      },
      %{
        name: "on_draft / on_add / on_remove",
        type: "event tags",
        default: "—",
        description: "{:change,…} typing, {:submit,…} on return, {:tap, {tag, string}} from a ✕."
      },
      %{
        name: "add/3 · remove/2",
        type: "helpers",
        default: "—",
        description: "Trim, reject blanks and duplicates; remove by value."
      }
    ]
  end

  @impl true
  def handle({:ti_remove, tag}, socket),
    do: Mob.Socket.assign(socket, :ti_tags, MishkaTagsInput.remove(socket.assigns.ti_tags, tag))

  # A submit carries no payload, so the draft we already hold is what commits.
  def handle(:ti_add, socket) do
    socket
    |> Mob.Socket.assign(
      :ti_tags,
      MishkaTagsInput.add(socket.assigns.ti_tags, socket.assigns.ti_draft)
    )
    |> Mob.Socket.assign(:ti_draft, "")
  end

  def handle(_tag, socket), do: socket

  @impl true
  def handle_change(:ti_draft, text, socket), do: Mob.Socket.assign(socket, :ti_draft, text)
  def handle_change(_tag, _value, socket), do: socket

  defp summary([]), do: "No tags"
  defp summary(tags), do: "#{length(tags)} tag(s): " <> Enum.join(tags, ", ")

  @impl true
  def card_preview do
    ~MOB"""
    <Box
      fill_width={true}
      background={:surface}
      corner_radius={:radius_md}
      border_color={:border}
      border_width={1}
      padding={8}
    >
      <Column fill_width={true}>
        <Row fill_width={true}>
          <Box width={54} height={20} background={:surface_raised} corner_radius={:radius_pill} />
          <Spacer size={6} />
          <Box width={44} height={20} background={:surface_raised} corner_radius={:radius_pill} />
        </Row>
        <Spacer size={8} />
        <Box fill_width={true} height={16} background={:surface_raised} corner_radius={:radius_sm} />
      </Column>
    </Box>
    """
  end
end
