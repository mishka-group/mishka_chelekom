defmodule MishkaMob.Showcase.Components.Field do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaField` and
  `MishkaMob.Components.MishkaFieldset`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaField, only: [field: 2]

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

  @blank %{name: "", email: "", age: "", role: nil, bio: ""}

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:fld_email, "")
    |> Mob.Socket.assign(:fld_name, "")
    |> Mob.Socket.assign(:form, @blank)
    # Which fields the user has touched. The web calls this `used_input?`: an
    # error for a field you have not reached yet is noise, so it stays hidden
    # until you edit that field — or until you submit, which touches all of them.
    |> Mob.Socket.assign(:touched, MapSet.new())
    |> Mob.Socket.assign(:submitted?, false)
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Label, hint and required",
        description: "The label sits above the control, the hint below it.",
        code: ~S"""
        <MishkaField label="Email" description="We'll never share it." required={true}>
          {[text_input(value: @email, placeholder: "you@example.com", on_change: :email)]}
        </MishkaField>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaField label="Email" description="We'll never share it." required={true}>
              {[input(@fld_email, "you@example.com", :fld_email, invalid?(@fld_email))]}
            </MishkaField>
          </Column>
          """
        end
      },
      %Example{
        title: "Errors replace the hint",
        description: "Type something without an @ — the hint gives way to the error.",
        code: ~S"""
        <MishkaField label="Email" description="…" errors={@errors}>{[input()]}</MishkaField>

        # The control tints its own border; invalid?/1 is exposed so it can match.
        border_color={if MishkaField.invalid?(%{errors: @errors}), do: :error, else: :border}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaField label="Email" description="We'll never share it." errors={errors(@fld_email)}>
              {[input(@fld_email, "you@example.com", :fld_email, invalid?(@fld_email))]}
            </MishkaField>
          </Column>
          """
        end
      },
      %Example{
        title: "A whole form",
        description:
          "Every control type, validated. Errors appear per field once you touch it, and all at once on submit.",
        code: ~S"""
        # A field is "touched" the first time it changes — the web calls this
        # used_input?. Submitting touches everything, so nothing stays hidden.
        def handle_change({:form, key}, value, socket) do
          form = Map.put(socket.assigns.form, key, value)
          touched = MapSet.put(socket.assigns.touched, key)

          {:noreply,
           socket |> assign(:form, form) |> assign(:touched, touched)}
        end

        def handle_info({:tap, :submit}, socket) do
          {:noreply, Mob.Socket.assign(socket, :submitted?, true)}
        end

        # shown/3 decides whether a field's errors are visible yet.
        defp shown(errors, key, socket) do
          if socket.assigns.submitted? or key in socket.assigns.touched,
            do: errors,
            else: []
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaField
              label="Full name"
              description="Between 2 and 40 characters."
              required={true}
              errors={shown(@form, @touched, @submitted?, :name)}
            >
              {[input(@form.name, "Ada Lovelace", {:form, :name}, err?(@form, @touched, @submitted?, :name), id: "fld-name")]}
            </MishkaField>
            <Spacer size={16} />
            <MishkaField
              label="Email address"
              description="We'll only use this to send account notifications."
              required={true}
              errors={shown(@form, @touched, @submitted?, :email)}
            >
              {[
                input(@form.email, "ada@example.com", {:form, :email}, err?(@form, @touched, @submitted?, :email),
                  keyboard: "email",
                  id: "fld-email"
                )
              ]}
            </MishkaField>
            <Spacer size={16} />
            <MishkaField
              label="Age"
              description="Optional — must be 18 or older."
              errors={shown(@form, @touched, @submitted?, :age)}
            >
              {[
                input(@form.age, "18", {:form, :age}, err?(@form, @touched, @submitted?, :age),
                  keyboard: "number",
                  id: "fld-age"
                )
              ]}
            </MishkaField>
            <Spacer size={16} />
            <MishkaField
              label="Role"
              description="A <select> on the web; a segmented control on a phone."
              required={true}
              errors={shown(@form, @touched, @submitted?, :role)}
            >
              {[role_picker(@form.role)]}
            </MishkaField>
            <Spacer size={16} />
            <MishkaField
              label="Short bio"
              description="Up to 160 characters."
              errors={shown(@form, @touched, @submitted?, :bio)}
            >
              {[
                input(@form.bio, "A sentence or two...", {:form, :bio}, err?(@form, @touched, @submitted?, :bio),
                  lines: 4,
                  max_length: 160,
                  id: "fld-bio"
                )
              ]}
            </MishkaField>
            <Spacer size={16} />
            <MishkaField
              label="Plan"
              description="A disabled field — the control is enabled={false}, not just handler-less."
              disabled={true}
            >
              {[input("Free — contact sales to upgrade", "", nil, false, enabled: false, id: "fld-plan")]}
            </MishkaField>
            <Spacer size={20} />
            <Row fill_width={true}>
              <Box weight={1}>
                <Button
                  text="Create account"
                  background={:primary}
                  text_color={:on_primary}
                  corner_radius={:radius_sm}
                  fill_width={true}
                  on_tap={{self(), :fld_submit}}
                />
              </Box>
              <Spacer size={10} />
              <Box weight={1}>
                <Button
                  text="Reset"
                  background={:surface_raised}
                  text_color={:on_surface}
                  corner_radius={:radius_sm}
                  fill_width={true}
                  on_tap={{self(), :fld_reset}}
                />
              </Box>
            </Row>
            <Spacer size={12} />
            <Text text={summary(@form, @submitted?)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Disabled",
        description: "The field mutes its label — you must disable the control as well.",
        code: ~S"""
        <MishkaField label="Account id" disabled={true}>
          {[text_input(value: "mishka-4821", enabled: false)]}
        </MishkaField>
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaField label="Account id" description="Assigned when you signed up." disabled={true}>
              {[input("mishka-4821", "", nil, false, enabled: false)]}
            </MishkaField>
          </Column>
          """
        end
      },
      %Example{
        title: "Fieldset",
        description:
          "A legend over a group. disabled dims it but does NOT cascade — see the docs.",
        code: ~S"""
        <MishkaFieldset legend="Billing address">{[line1(), city()]}</MishkaFieldset>
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaFieldset
              legend="Your details"
              background={:surface_raised}
              padding={:space_md}
              corner_radius={:radius_md}
            >
              {[
                 field([label: "Name"], [input(@fld_name, "Ada Lovelace", :fld_name, false)]),
                 %{type: :spacer, props: %{size: 14}, children: []},
                 field([label: "Email", errors: errors(@fld_email)],
                       [input(@fld_email, "you@example.com", :fld_email, invalid?(@fld_email))])
               ]}
            </MishkaFieldset>
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
      %{name: "space", type: "number", default: "6", description: "Gap between the parts."},
      %{
        name: "label_color / description_color",
        type: "color / ARGB",
        default: ":on_surface / :muted",
        description: "The label and the hint."
      },
      %{
        name: "error_color",
        type: "color / ARGB",
        default: ":error",
        description: "Errors, the ✕ and the required *. A theme token, so it follows the theme."
      },
      %{
        name: "text_size",
        type: "text token",
        default: ":sm",
        description: "Label, hint and errors."
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

  # Touching a field is what makes its errors visible. Without it the form
  # scolds you about six fields before you have typed anything.
  def handle_change({:form, key}, value, socket) do
    socket
    |> Mob.Socket.assign(:form, Map.put(socket.assigns.form, key, value))
    |> Mob.Socket.assign(:touched, MapSet.put(socket.assigns.touched, key))
  end

  def handle_change(_tag, _value, socket), do: socket

  @impl true
  def handle(:fld_submit, socket), do: Mob.Socket.assign(socket, :submitted?, true)

  def handle({:fld_role, id}, socket) do
    socket
    |> Mob.Socket.assign(:form, Map.put(socket.assigns.form, :role, id))
    |> Mob.Socket.assign(:touched, MapSet.put(socket.assigns.touched, :role))
  end

  def handle(:fld_reset, socket) do
    socket
    |> Mob.Socket.assign(:form, @blank)
    |> Mob.Socket.assign(:touched, MapSet.new())
    |> Mob.Socket.assign(:submitted?, false)
  end

  def handle(_tag, socket), do: socket

  # --- the simple email example, kept for the first two cards ---

  defp errors(""), do: []
  defp errors(value), do: if(String.contains?(value, "@"), do: [], else: ["Must contain an @."])

  defp invalid?(value), do: errors(value) != []

  # --- the whole-form example ---

  @doc false
  # Validation is a pure function of the form, so the same rules drive the
  # error list, the border tint and the summary line — three things that
  # disagree the moment each is computed separately.
  defp validate(form) do
    %{
      name: name_errors(form.name),
      email: email_errors(form.email),
      age: age_errors(form.age),
      role: if(is_nil(form.role), do: ["Pick a role."], else: []),
      # "At most 160 characters.", phrased like name_errors/1's "At most 40
      # characters." below, because "Up to 160 characters." was word for word
      # the bio field's own hint above. A device test cannot ask whether the bio
      # error is showing while the answer is yes on a page nobody has touched —
      # the same trap "Ready to submit" was named to avoid, see summary/2.
      bio: if(String.length(form.bio) > 160, do: ["At most 160 characters."], else: [])
    }
  end

  defp name_errors(""), do: ["Required."]
  defp name_errors(v) when byte_size(v) < 2, do: ["At least 2 characters."]
  defp name_errors(v), do: if(String.length(v) > 40, do: ["At most 40 characters."], else: [])

  defp email_errors(""), do: ["Required."]

  defp email_errors(v) do
    if String.contains?(v, "@") and String.contains?(v, "."),
      do: [],
      else: ["That does not look like an email address."]
  end

  # Optional: blank is fine, but anything present has to be a number and 18+.
  defp age_errors(""), do: []

  defp age_errors(v) do
    case Integer.parse(v) do
      {n, ""} when n >= 18 -> []
      {_n, ""} -> ["Must be 18 or older."]
      _ -> ["Digits only."]
    end
  end

  # Errors for one field, but only once the user has earned them.
  defp shown(form, touched, submitted?, key) do
    if submitted? or MapSet.member?(touched, key),
      do: Map.fetch!(validate(form), key),
      else: []
  end

  # The border tint asks the same question the error list does, so a red border
  # can never appear over a field that is showing no message.
  # The border tint asks exactly the question the error list asks — including
  # "has the user earned this yet". Computing it from validate/1 alone put a red
  # border around every empty required field the moment the page opened, with no
  # message underneath to explain it.
  defp err?(form, touched, submitted?, key), do: shown(form, touched, submitted?, key) != []

  # The summary tracks validity LIVE, and only names the offending fields once
  # you have submitted — before that, listing fields you have not reached yet is
  # exactly the noise `shown/4` exists to suppress.
  #
  # "Ready to submit" is deliberately distinctive: "Valid" alone is a substring
  # of "Validation messages" in the props table below, so a device test asserting
  # on it would pass on a page nobody had touched.
  defp summary(form, submitted?) do
    case Enum.filter(validate(form), &(elem(&1, 1) != [])) do
      [] ->
        "✓ Ready to submit — nothing is saved, this is validation only."

      bad when submitted? ->
        "#{length(bad)} field(s) to fix: " <> Enum.map_join(bad, ", ", &to_string(elem(&1, 0)))

      bad ->
        "#{length(bad)} field(s) to fix"
    end
  end

  @roles [{:owner, "Owner"}, {:admin, "Admin"}, {:member, "Member"}]

  defp role_picker(value) do
    MishkaMob.Components.MishkaSegmentedControl.segmented_control(
      %{value: value, on_change: :fld_role, id: "fld-role", text_size: :sm},
      Enum.map(@roles, fn {id, label} ->
        MishkaMob.Components.MishkaSegmentedControl.option(id, label)
      end)
    )
  end

  defp input(value, placeholder, tag, invalid?, opts \\ []) do
    props =
      %{
        value: value,
        placeholder: placeholder,
        fill_width: true,
        background: :surface,
        corner_radius: :radius_sm,
        border_width: 1,
        # :error is a theme token, so the invalid border follows the theme.
        border_color: if(invalid?, do: :error, else: :border)
      }
      |> Map.merge(Map.new(opts))

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
