defmodule MishkaMob.Showcase.Components.Rating do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaRating`.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :rating,
      name: "Rating",
      category: "Forms",
      order: 10,
      description: "A row of stars with a real half star."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Whole stars",
        description: "The value is in stars: 0 is an unrated row, 5 is all filled.",
        code: ~S"""
        <MishkaRating value={4} />
        <MishkaRating value={2} />
        <MishkaRating value={0} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRating id="rating-four" value={4} />
            <Spacer size={10} />
            <MishkaRating id="rating-two" value={2} />
            <Spacer size={10} />
            <MishkaRating id="rating-none" value={0} />
          </Column>
          """
        end
      },
      %Example{
        title: "Halves",
        description:
          "A value with a fraction of 0.5 or more draws the outline with a filled " <>
            "star clipped over its leading half.",
        code: ~S"""
        <MishkaRating value={4.5} />
        <MishkaRating value={3.5} />
        <MishkaRating value={2.5} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRating id="rating-45" value={4.5} />
            <Spacer size={10} />
            <MishkaRating id="rating-35" value={3.5} />
            <Spacer size={10} />
            <MishkaRating id="rating-25" value={2.5} />
          </Column>
          """
        end
      },
      %Example{
        title: "Count, size and gap",
        description: "A ten-point row, then a row that is smaller and tighter.",
        code: ~S"""
        <MishkaRating value={7} count={10} size={16} gap={1} />
        <MishkaRating value={3} size={30} gap={4} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRating id="rating-ten" value={7} count={10} size={16} gap={1} />
            <Spacer size={12} />
            <MishkaRating id="rating-large" value={3} size={30} gap={4} />
          </Column>
          """
        end
      },
      %Example{
        title: "Colours and glyphs",
        description:
          "icon and empty_icon take glyph strings, a node or a list of nodes. " <>
            "A string is drawn at size in its colour; a node is used as given.",
        code: ~S"""
        <MishkaRating value={3.5} color={:primary} empty_color={:muted} />
        <MishkaRating value={3.5} icon="★" empty_icon="✩" color={:danger} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaRating id="rating-primary" value={3.5} color={:primary} empty_color={:muted} />
            <Spacer size={10} />
            <MishkaRating id="rating-glyphs" value={3.5} icon="★" empty_icon="✩" color={:danger} />
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
        name: "value",
        type: "number",
        default: "0",
        description: "The rating in stars; 3.5 is three and a half."
      },
      %{name: "count", type: "integer", default: "5", description: "How many cells."},
      %{
        name: "size",
        type: "number",
        default: "22",
        description: "One cell's edge, and a string glyph's text size."
      },
      %{name: "gap", type: "number", default: "2", description: "Space between cells."},
      %{
        name: "icon",
        type: "string | node | list of nodes",
        default: "\"★\"",
        description: "A full cell."
      },
      %{
        name: "empty_icon",
        type: "string | node | list of nodes",
        default: "\"☆\"",
        description: "An empty cell, and the outline under a half."
      },
      %{
        name: "color",
        type: "color token / ARGB int",
        default: ":warning",
        description: "A string icon's ink."
      },
      %{
        name: "empty_color",
        type: "color token / ARGB int",
        default: "color",
        description: "A string empty_icon's ink."
      },
      %{
        name: "half",
        type: "boolean",
        default: "true",
        description: "Draw the half step when the value has one."
      },
      %{name: "id", type: "string", default: "nil", description: "Native testTag."}
    ]
  end
end
