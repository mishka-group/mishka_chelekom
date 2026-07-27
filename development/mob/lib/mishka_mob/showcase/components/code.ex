defmodule MishkaMob.Showcase.Components.Code do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaCode`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :code,
      name: "Code",
      category: "Data display",
      order: 5,
      description: "Inline code and horizontally scrolling code blocks."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Inline",
        description: "Hugs its text and sits in a sentence.",
        code: ~S"""
        <MishkaCode text="mix mob.deploy" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Row fill_width={true}>
            <Text text="Run " text_size={:base} text_color={:on_surface} />
            <MishkaCode text="mix mob.deploy" />
            <Text text=" to push." text_size={:base} text_color={:on_surface} />
          </Row>
          """
        end
      },
      %Example{
        title: "Block",
        description: "Fills the width, padded, and scrolls horizontally — code does not wrap.",
        code: ~S"""
        <MishkaCode text="…" block={true} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCode block={true} text="def render(assigns), do: ~MOB(<Text text={@title} />)" />
            <Spacer size={12} />
            <MishkaCode
              block={true}
              text="Mob.Composite.register(:mishka_code, {MishkaMob.Components.MishkaCode, :expand})"
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Without the scroller",
        description: "scroll: false lets a long line be clipped instead.",
        code: ~S"""
        <MishkaCode text="…" block={true} scroll={false} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCode
              block={true}
              scroll={false}
              text="a long line that will simply be clipped at the edge of the block"
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Colours",
        description: "background and color are props — a dark block in any theme.",
        code: ~S"""
        <MishkaCode text="…" block={true} background={0xFF0B1020} color={0xFF93C5FD} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaCode
              block={true}
              background={0xFF0B1020}
              color={0xFF93C5FD}
              text="iex> Mob.Test.screen(node)"
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
      %{name: "text", type: "string", default: "nil", description: "The code."},
      %{
        name: "block",
        type: "boolean",
        default: "false",
        description: "Block rather than inline."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Fill."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Code colour."
      },
      %{name: "text_size", type: "size token", default: ":sm", description: "Code size."},
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_md / 4",
        description: "Padding — block and inline differ."
      },
      %{
        name: "scroll",
        type: "boolean",
        default: "true (blocks)",
        description: "Scroll a block horizontally instead of clipping."
      }
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Box fill_width={true} background={0xFF0B1020} corner_radius={:radius_md} padding={10}>
      <Column fill_width={true}>
        <Box width={92} height={7} background={0xFF93C5FD} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={64} height={7} background={0xFF6EE7B7} corner_radius={:radius_sm} />
        <Spacer size={6} />
        <Box width={104} height={7} background={0xFF93C5FD} corner_radius={:radius_sm} />
      </Column>
    </Box>
    """
  end
end
