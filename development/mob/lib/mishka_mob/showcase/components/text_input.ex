defmodule MishkaMob.Showcase.Components.TextInput do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaTextInput`.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :text_input,
      name: "Text Input",
      category: "Forms",
      order: 6,
      description: "A single- or multi-line field with the form events and headless styling."
    }
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A field with a placeholder",
        description:
          "The screen owns the value. on_change reports the whole string; echo it " <>
            "back and the caret stays where the reader put it.",
        code: ~S"""
        <MishkaTextInput value={@query} placeholder="Search films"
                         on_change={:search_typed} />

        def handle_info({:change, :search_typed, value}, socket) do
          {:noreply, assign(socket, :query, value)}
        end
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaTextInput
            value=""
            placeholder="Search films"
            accessibility_id="showcase_text_plain"
            on_change={:showcase_text_typed}
          />
          """
        end
      },
      %Example{
        title: "Leading and trailing nodes",
        description:
          "leading and trailing put a node on either side of the field, separated " <>
            "by slot_gap. The field keeps its own props; the wrapper is only a " <>
            "fill-width row.",
        code: ~S"""
        <MishkaTextInput placeholder="Search films"
                         leading={<Text text="⌕" />}
                         trailing={<Text text="⚙" />}
                         slot_gap={8} />
        """,
        render: fn _assigns ->
          leading = ~MOB"""
          <Text text="⌕" text_size={:lg} text_color={:muted} />
          """

          trailing = ~MOB"""
          <Text text="⚙" text_size={:lg} text_color={:muted} />
          """

          assigns = %{leading: leading, trailing: trailing}

          ~MOB"""
          <MishkaTextInput
            placeholder="Search films"
            leading={@leading}
            trailing={@trailing}
            slot_gap={8}
            accessibility_id="showcase_text_slots"
          />
          """
        end
      },
      %Example{
        title: "A paragraph",
        description:
          "multiline keeps Return for a newline; lines declares a row count. The " <>
            "field grows with the text between those bounds.",
        code: ~S"""
        <MishkaTextInput multiline={true} lines={4} value={@review}
                         placeholder="What did you make of it?" />
        """,
        render: fn _assigns ->
          ~MOB"""
          <MishkaTextInput
            value=""
            placeholder="What did you make of it?"
            multiline={true}
            lines={4}
            accessibility_id="showcase_text_multiline"
          />
          """
        end
      },
      %Example{
        title: "Masked and typed keyboards",
        description:
          "secure masks the text; keyboard_type picks the keyboard. value_epoch is " <>
            "the escape hatch when the screen must replace what the field remembers.",
        code: ~S"""
        <MishkaTextInput secure={true} placeholder="Token" />
        <MishkaTextInput keyboard_type={:email} placeholder="you@example.com" />
        <MishkaTextInput value={@v} value_epoch={@epoch} />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaTextInput secure={true} placeholder="Token" accessibility_id="showcase_text_secure" />
            <Spacer size={10} />
            <MishkaTextInput
              keyboard_type={:email}
              placeholder="you@example.com"
              accessibility_id="showcase_text_email"
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
        name: "value",
        type: "string",
        default: "nil",
        description: "The current text, echoed back by the screen."
      },
      %{
        name: "placeholder",
        type: "string",
        default: "nil",
        description: "Hint shown while the field is empty."
      },
      %{
        name: "multiline / lines",
        type: "boolean / integer",
        default: "false / nil",
        description: "A paragraph field, optionally with a declared row count."
      },
      %{
        name: "value_epoch",
        type: "integer",
        default: "nil",
        description: "Bump to replace the text the native field remembers."
      },
      %{
        name: "leading / trailing",
        type: "node | list of nodes",
        default: "nil",
        description:
          "Content beside the field, separated by slot_gap. With neither set the " <>
            "node is the field itself."
      },
      %{
        name: "slot_gap",
        type: "number",
        default: "8",
        description: "Space between a slot and the field."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "Reports {:change, tag, value} with the whole string."
      },
      %{
        name: "on_submit / on_focus / on_blur",
        type: "event tag",
        default: "—",
        description: "Keyboard return, focus and blur. Tags rather than payloads."
      },
      %{
        name: "secure / keyboard_type / return_key / caret / underline",
        type: "boolean / atom / string / string / boolean",
        default: "nil",
        description: "Native field configuration, forwarded unchanged."
      },
      %{
        name: "text_size / text_color / placeholder_color",
        type: "token / color",
        default: ":base / :on_surface / :muted",
        description: "Type and inks."
      }
    ]
  end
end
