defmodule MishkaMob.Showcase.Components.Avatar do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaAvatar`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :avatar,
      name: "Avatar",
      category: "Data display",
      order: 0,
      description: "An image with a text fallback, stacked so initials show until it loads."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Initials",
        description: "With no src, the fallback is the avatar.",
        code: ~S"""
        <MishkaAvatar initials="SH" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaAvatar initials="SH" />
            <Spacer size={12} />
            <MishkaAvatar initials="MK" background={0xFF7C3AED} color={0xFFFFFFFF} />
            <Spacer size={12} />
            <MishkaAvatar initials="AB" background={:primary} color={:on_primary} />
          </Row>
          """
        end
      },
      %Example{
        title: "Shapes",
        description: "A circle uses an exact size/2 radius, so it stays round at any size.",
        code: ~S"""
        <MishkaAvatar initials="SH" shape={:circle} />
        <MishkaAvatar initials="SH" shape={:rounded} />
        <MishkaAvatar initials="SH" shape={:square} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaAvatar initials="CI" shape={:circle} background={:primary} color={:on_primary} />
            <Spacer size={12} />
            <MishkaAvatar initials="RO" shape={:rounded} background={:primary} color={:on_primary} />
            <Spacer size={12} />
            <MishkaAvatar initials="SQ" shape={:square} background={:primary} color={:on_primary} />
          </Row>
          """
        end
      },
      %Example{
        title: "Sizes",
        description: "size sets both dimensions; the circle radius follows it.",
        code: ~S"""
        <MishkaAvatar initials="SH" size={28} />
        <MishkaAvatar initials="SH" size={64} text_size={:xl} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true} align={:bottom}>
            <MishkaAvatar initials="S" size={28} text_size={:sm} id="avatar-28" />
            <Spacer size={12} />
            <MishkaAvatar initials="SH" size={44} id="avatar-44" />
            <Spacer size={12} />
            <MishkaAvatar initials="SH" size={64} text_size={:xl} id="avatar-64" />
          </Row>
          """
        end
      },
      %Example{
        title: "In a row",
        description: "The usual home for an avatar — beside a name.",
        code: ~S"""
        <Row>
          <MishkaAvatar initials="SH" background={0xFF7C3AED} color={0xFFFFFFFF} />
          <Column>
            <Text text="Shahryar" />
            <Text text="shahryar@mishka.tools" />
          </Column>
        </Row>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaAvatar initials="SH" background={0xFF7C3AED} color={0xFFFFFFFF} />
            <Spacer size={12} />
            <Column fill_width={true}>
              <Text text="Shahryar" text_size={:lg} text_color={:on_surface} />
              <Spacer size={2} />
              <Text text="shahryar@mishka.tools" text_size={:sm} text_color={:muted} />
            </Column>
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
        name: "src",
        type: "string",
        default: "nil",
        description: "Image URL or on-device path. Absent renders the fallback alone."
      },
      %{name: "initials", type: "string", default: "nil", description: "Fallback text."},
      %{
        name: "size",
        type: "number",
        default: "44",
        description: "Width and height — an avatar is square."
      },
      %{
        name: "shape",
        type: ":circle · :rounded · :square",
        default: ":circle",
        description: "Circle uses an exact size/2 radius, so it stays round at any size."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Fallback background."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Initials colour."
      },
      %{name: "text_size", type: "size token", default: ":lg", description: "Initials size."}
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true}>
      <MishkaAvatar
        initials="M"
        size={34}
        background={:primary}
        color={:on_primary}
        text_size={:sm}
      />
      <Spacer size={8} />
      <MishkaAvatar initials="O" size={34} background={:muted} color={:on_surface} text_size={:sm} />
      <Spacer size={8} />
      <MishkaAvatar
        initials="B"
        size={34}
        shape={:rounded}
        background={:surface_raised}
        color={:on_surface}
        text_size={:sm}
      />
    </Row>
    """
  end
end
