defmodule MishkaMob.Showcase.Components.Field do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaField` and
  `MishkaMob.Components.MishkaFieldset`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaField, only: [field: 2]
  import MishkaMob.Components.MishkaFieldset, only: [fieldset: 2]

  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :field,
      name: "Field",
      category: "Forms",
      order: 10,
      description: "A labelled control with a description and validation errors."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:fld_email, "")
    |> Mob.Socket.assign(:fld_name, "")
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Label and hint",
        description: "The label sits above the control, the hint below it.",
        code: ~S"""
        {field([label: "Email", description: "We'll never share it."], [input()])}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {field(
               [label: "Email", description: "We'll never share it.", required: true],
               [input(@fld_email, "you@example.com", :fld_email, invalid?(@fld_email))]
             )}
          </Column>
          """
        end
      },
      %Example{
        title: "Errors replace the hint",
        description: "Type something without an @ — the hint gives way to the error.",
        code: ~S"""
        {field([label: "Email", description: "…", errors: @errors], [input()])}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {field(
               [label: "Email", description: "We'll never share it.", errors: errors(@fld_email)],
               [input(@fld_email, "you@example.com", :fld_email, invalid?(@fld_email))]
             )}
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "Label and hint go muted.",
        code: ~S"""
        {field([label: "Locked", description: "…", disabled: true], [input()])}
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {field([label: "Account id", description: "Assigned when you signed up.", disabled: true],
                   [input("mishka-4821", "", nil, false)])}
          </Column>
          """
        end
      },
      %Example{
        title: "Fieldset",
        description:
          "A legend over a group. disabled dims it but does NOT cascade — see the docs.",
        code: ~S"""
        {fieldset([legend: "Billing address"], [line1(), city()])}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {fieldset(
               [legend: "Your details", background: :surface_raised,
                padding: :space_md, corner_radius: :radius_md],
               [
                 field([label: "Name"], [input(@fld_name, "Ada Lovelace", :fld_name, false)]),
                 %{type: :spacer, props: %{size: 14}, children: []},
                 field([label: "Email", errors: errors(@fld_email)],
                       [input(@fld_email, "you@example.com", :fld_email, invalid?(@fld_email))])
               ]
             )}
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{name: "label", type: "string", default: "nil", description: "Label above the control."},
      %{
        name: "description",
        type: "string",
        default: "nil",
        description: "Hint below it. Hidden while there are errors."
      },
      %{
        name: "errors",
        type: "list of strings",
        default: "[]",
        description: "Validation messages, prefixed with ✕ so colour is not the only signal."
      },
      %{
        name: "required",
        type: "boolean",
        default: "false",
        description: "Appends a * to the label."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Mutes the label and hint."
      },
      %{
        name: "invalid?/1",
        type: "helper",
        default: "—",
        description: "Whether props describe an invalid field, so a control can match its border."
      },
      %{
        name: "Fieldset: legend / disabled / background / padding",
        type: "see MishkaFieldset",
        default: "—",
        description: "A group under a legend. disabled does not cascade to children."
      }
    ]
  end

  @impl true
  def handle_change(:fld_email, value, socket), do: Mob.Socket.assign(socket, :fld_email, value)
  def handle_change(:fld_name, value, socket), do: Mob.Socket.assign(socket, :fld_name, value)
  def handle_change(_tag, _value, socket), do: socket

  defp errors(""), do: []
  defp errors(value), do: if(String.contains?(value, "@"), do: [], else: ["Must contain an @."])

  defp invalid?(value), do: errors(value) != []

  defp input(value, placeholder, tag, invalid?) do
    props = %{
      value: value,
      placeholder: placeholder,
      keyboard: "email",
      fill_width: true,
      background: :surface,
      corner_radius: :radius_sm,
      padding: :space_sm,
      border_width: 1,
      border_color: if(invalid?, do: 0xFFDC2626, else: :border)
    }

    props = if tag, do: Map.put(props, :on_change, {self(), tag}), else: props

    %{type: :text_field, props: props, children: []}
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true}>
      <Box width={40} height={7} background={:muted} corner_radius={:radius_sm} />
      <Spacer size={7} />
      <Box
        fill_width={true}
        height={26}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
      />
      <Spacer size={7} />
      <Box width={92} height={6} background={:surface_raised} corner_radius={:radius_sm} />
    </Column>
    """
  end
end
