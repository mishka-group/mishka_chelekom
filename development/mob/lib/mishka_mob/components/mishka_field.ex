defmodule MishkaMob.Components.MishkaField do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Field** — a labelled control
  with a description and validation errors.

  On the web this is mostly *wiring*: it generates ids and hangs `for`,
  `aria-describedby` and `aria-invalid` off them so a screen reader announces the
  label, the hint and the error together. There are no ids to wire here, so what
  the port keeps is the part a user sees — the label above, the hint and the
  errors below — and the visual state that says something is wrong.

  ## Errors replace the description, and colour is not the only signal

  When a field has errors the description is hidden: showing "we'll never share
  this" directly above "email is invalid" buries the thing the user has to act
  on. Errors also carry a ✕ prefix and tint the control's border, so the failure
  is not conveyed by colour alone — which matters for the same reason the
  Checkbox draws a dash rather than only tinting.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | Label above the control. |
  | `description` | string | `nil` | Hint below it. Hidden while there are errors. |
  | `errors` | list of strings | `[]` | Validation messages. |
  | `required` | boolean | `false` | Appends a `*` to the label. |
  | `disabled` | boolean | `false` | Mutes the label. See the warning below. |
  | `space` | number | `6` | Gap between the parts. |
  | `label_color` | color token / ARGB int | `:on_surface` | The label. |
  | `description_color` | color token / ARGB int | `:muted` | The hint. |
  | `error_color` | color token / ARGB int | `:error` | Errors, the `*` and the ✕. |
  | `text_size` | text token | `:sm` | Label, hint and errors. |

  Children are the control itself — a `TextField`, a
  `MishkaMob.Components.MishkaSwitch`, anything.

  ## `disabled` does NOT reach the control

  It mutes this component's own label, and that is all it can do: the control is
  an opaque child, and nothing here knows whether it is a text field, a switch or
  a whole subtree. **Disable the control yourself as well** — a `TextField` needs
  `enabled={false}`, not merely a withheld `on_change`. Withholding the handler
  stops the BEAM hearing about edits but leaves the field focusable and
  editable, so it looks live and silently goes nowhere.

  Not ported: `id`, `for`, `name` and the `*_class` attrs — the first three are
  DOM plumbing for label/description association.
  """

  import Mob.Sigil

  @doc "Composite expander (`<MishkaField>`). Children are the control."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: field(props, children)

  @doc """
  The field node.

      <MishkaField label="Email" errors={@errors}>{[email_input()]}</MishkaField>
  """
  @spec field(map() | keyword(), [map()]) :: map()
  def field(props \\ %{}, control \\ []) do
    props = Map.new(props)
    errors = props |> Map.get(:errors, []) |> List.wrap() |> Enum.reject(&(&1 in [nil, ""]))
    disabled? = truthy?(Map.get(props, :disabled, false))
    space = Map.get(props, :space) || 6

    ~MOB"""
    <Column fill_width={true}>
      {label(props, disabled?)}
      <Spacer size={space} :if={label?(props)} />
      <Column fill_width={true}>
        {control}
      </Column>
      {footer(props, errors, space)}
    </Column>
    """
  end

  # `:error` is a THEME token, so the red follows light, dark and every custom
  # theme. It used to be a hardcoded 0xFFDC2626, which stayed the same shade of
  # red whatever the theme did — the one colour in the component that could not
  # be themed, on the one element that most needs to stand out.
  defp danger(props), do: Map.get(props, :error_color) || :error
  defp size(props), do: Map.get(props, :text_size) || :sm

  @doc """
  Whether a set of props describes a field in an invalid state — exposed so a
  control can tint its own border to match.

      iex> MishkaMob.Components.MishkaField.invalid?(%{errors: ["too short"]})
      true
      iex> MishkaMob.Components.MishkaField.invalid?(%{errors: []})
      false
      iex> MishkaMob.Components.MishkaField.invalid?(%{errors: [nil, ""]})
      false
  """
  @spec invalid?(map() | keyword()) :: boolean()
  def invalid?(props) do
    props
    |> Map.new()
    |> Map.get(:errors, [])
    |> List.wrap()
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Kernel.!=([])
  end

  defp label?(props), do: is_binary(Map.get(props, :label))

  defp label(props, disabled?) do
    text = Map.get(props, :label)
    required? = truthy?(Map.get(props, :required, false))
    color = if disabled?, do: :muted, else: Map.get(props, :label_color) || :on_surface
    danger = danger(props)
    size = size(props)

    ~MOB"""
    <Row fill_width={true} :if={is_binary(text)}>
      <Text text={text} text_size={size} text_color={color} />
      <Text text=" *" text_size={size} text_color={danger} :if={required?} />
    </Row>
    """
  end

  # Errors replace the description: stacking a hint above a failure buries the
  # thing the user has to act on.
  #
  # The hint takes no `disabled?` argument, because it never used it — the old
  # clause read `if disabled?, do: :muted, else: :muted`, so the moduledoc's
  # promise to mute the hint was a branch that could not fire. The hint is muted
  # in both states, and `disabled` mutes the label; that is what actually
  # happens, and now what is documented.
  defp footer(props, [], space) do
    description = Map.get(props, :description)
    color = Map.get(props, :description_color) || :muted
    size = size(props)

    ~MOB"""
    <Column fill_width={true} :if={is_binary(description)}>
      <Spacer size={space} />
      <Text text={description} text_size={size} text_color={color} />
    </Column>
    """
  end

  defp footer(props, errors, space) do
    danger = danger(props)
    size = size(props)

    lines =
      Enum.map(errors, fn message ->
        ~MOB"""
        <Row fill_width={true}>
          <Text text="✕ " text_size={size} text_color={danger} />
          <Text text={message} text_size={size} text_color={danger} />
        </Row>
        """
      end)

    ~MOB"""
    <Column fill_width={true}>
      <Spacer size={space} />
      {lines}
    </Column>
    """
  end

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
