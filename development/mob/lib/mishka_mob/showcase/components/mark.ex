defmodule MishkaMob.Showcase.Components.Mark do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaMark`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

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
          "A Text cannot carry its own background, so a mark is a Text in a tinted " <>
            "Box — one that hugs the word rather than filling the line.",
        code: ~S"""
        <MishkaMark text="BEAM" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaMark text="BEAM" />
            <Spacer size={8} />
            <MishkaMark text="on device" />
          </Row>
          """
        end
      },
      %Example{
        title: "A colour per mark",
        description:
          "Highlight takes one fill for every match, so a line where each match " <>
            "means something different is composed from marks directly.",
        code: ~S"""
        # This is what the mark exists for: Highlight's single background cannot
        # say "red here, green there" — the web component has one mark_class too.
        <Row>
          <MishkaMark text="Error" background={0xFFFECACA} />
          <Text text=": Invalid input. " />
          <MishkaMark text="Warning" background={0xFFFDE68A} />
          <Text text=": Check this field. " />
          <MishkaMark text="Success" background={0xFFBBF7D0} />
          <Text text=": All tests passed." />
        </Row>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <Row>
              <MishkaMark text="Error" background={0xFFFECACA} />
              <Text text=": Invalid input." text_size={:base} text_color={:on_surface} />
            </Row>
            <Spacer size={8} />
            <Row>
              <MishkaMark text="Warning" background={0xFFFDE68A} />
              <Text text=": Check this field." text_size={:base} text_color={:on_surface} />
            </Row>
            <Spacer size={8} />
            <Row>
              <MishkaMark text="Success" background={0xFFBBF7D0} />
              <Text text=": All tests passed." text_size={:base} text_color={:on_surface} />
            </Row>
          </Column>
          """
        end
      },
      %Example{
        title: "In a sentence",
        description: "Sits inline beside ordinary text.",
        code: ~S"""
        <Row>
          <Text text="Runs on the " />
          <MishkaMark text="BEAM" />
          <Text text=" itself." />
        </Row>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <Text text="Runs on the " text_size={:base} text_color={:on_surface} />
            <MishkaMark text="BEAM" />
            <Text text=" itself." text_size={:base} text_color={:on_surface} />
          </Row>
          """
        end
      },
      %Example{
        title: "Colours",
        description: "The default pairs a light fill with dark ink so it reads in either theme.",
        code: ~S"""
        <MishkaMark text="shipped" background={0xFFBBF7D0} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <MishkaMark text="amber" />
            <Spacer size={8} />
            <MishkaMark text="green" background={0xFFBBF7D0} />
            <Spacer size={8} />
            <MishkaMark text="rose" background={0xFFFECDD3} />
            <Spacer size={8} />
            <MishkaMark text="violet" background={0xFFDDD6FE} />
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
