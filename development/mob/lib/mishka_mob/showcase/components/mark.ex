defmodule MishkaMob.Showcase.Components.Mark do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaMark`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaMark, only: [mark: 1]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :mark,
      name: "Mark",
      category: "Data display",
      order: 2,
      description: "Highlighted text — the native equivalent of <mark>."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Highlighted text",
        description:
          "A Text cannot carry its own background, so a mark is a Text in a tinted Box.",
        code: ~S"""
        {mark(text: "BEAM")}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {mark(text: "BEAM")}
            <Spacer size={8} />
            {mark(text: "on device")}
          </Row>
          """
        end
      },
      %Example{
        title: "In a sentence",
        description: "Sits inline beside ordinary text.",
        code: ~S"""
        <Row>
          <Text text="Runs on the " />
          {mark(text: "BEAM")}
          <Text text=" itself." />
        </Row>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <Text text="Runs on the " text_size={:base} text_color={:on_surface} />
            {mark(text: "BEAM")}
            <Text text=" itself." text_size={:base} text_color={:on_surface} />
          </Row>
          """
        end
      },
      %Example{
        title: "Colours",
        description: "The default pairs a light fill with dark ink so it reads in either theme.",
        code: ~S"""
        {mark(text: "shipped", background: 0xFFBBF7D0)}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            {mark(text: "amber")}
            <Spacer size={8} />
            {mark(text: "green", background: 0xFFBBF7D0)}
            <Spacer size={8} />
            {mark(text: "rose", background: 0xFFFECDD3)}
            <Spacer size={8} />
            {mark(text: "violet", background: 0xFFDDD6FE)}
          </Row>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "text", type: "string", default: "nil", description: "The text to highlight."},
      %{
        name: "background",
        type: "color / ARGB",
        default: "0xFFFDE68A",
        description: "Highlight fill."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: "0xFF111827",
        description: "Text colour — dark, so it stays legible on a light fill in either theme."
      },
      %{name: "text_size", type: "size token", default: ":base", description: "Text size."}
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Row fill_width={true}>
        <Box width={30} height={10} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={44} height={14} background={0xFFFDE68A} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={22} height={10} background={:muted} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={12} />
      <Row fill_width={true}>
        <Box width={38} height={14} background={0xFFDDD6FE} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={40} height={10} background={:muted} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end
end
