# field (mob)

A labelled control with a description and validation errors. See [README](README.md) for the rules
every Mob component shares.

## Generate
`mix mishka.ui.gen.mob field` → `lib/<app>/components/field.ex`, tag `<Field />`. With
`--module-prefix mishka_` it is `<MishkaField />`.

## What it renders

```
column  fill_width
├── row  the label + a red * when required   ← omitted when there is no label
├── the control — your children, untouched
└── column  the description, OR the errors   ← never both
```

On the web this component is mostly *wiring*: it generates ids and hangs `for`,
`aria-describedby` and `aria-invalid` off them so a screen reader announces the label, the hint and
the error together. There are no ids to wire here, so what the port keeps is the part a user sees.

## Example

```elixir
~MOB"""
<MishkaField label="Email address" description="We'll never share it." required={true} errors={@errors}>
  {[email_input(@email, @errors)]}
</MishkaField>
"""

defp email_input(value, errors) do
  %{
    type: :text_field,
    props: %{
      value: value,
      placeholder: "ada@example.com",
      keyboard: "email",
      fill_width: true,
      on_change: {self(), :email},
      # invalid?/1 is exposed so the control can tint its own border to match.
      border_color: if(MishkaField.invalid?(%{errors: errors}), do: :error, else: :border),
      border_width: 1
    },
    children: []
  }
end
```

## Props

| Prop | Values | Default |
|---|---|---|
| `label` | string | `nil` |
| `description` | string | `nil` — hidden while there are errors |
| `errors` | list of strings | `[]` — blanks and `nil`s are ignored |
| `required` | boolean | `false` — appends a red `*` |
| `disabled` | boolean | `false` — mutes the label. See below |
| `space` | number | `6` — gap between the parts |
| `label_color` | colour token / ARGB int | `:on_surface` |
| `description_color` | colour token / ARGB int | `:muted` |
| `error_color` | colour token / ARGB int | `:error` |
| `text_size` | text token | `:sm` |

Helper: `invalid?/1`.

Not ported: `id`, `for`, `name` and the `*_class` attrs — the first three are DOM plumbing for
label/description association.

## Five things to know

**Errors replace the description; they never stack.** Showing "we'll never share this" directly
above "email is invalid" buries the thing the user has to act on. Errors also carry a `✕` prefix, so
a failure is not signalled by colour alone — the same reason the checkbox draws a dash for mixed
rather than only tinting.

**`disabled` does NOT reach the control.** It mutes this component's own label, and that is all it
can do: the control is an opaque child and nothing here knows whether it is a text field, a switch
or a whole subtree. **Disable the control yourself as well.** For a `TextField` that means
`enabled: false` — *not* merely withholding `on_change`. Withholding the handler stops the BEAM
hearing about edits but leaves the field focusable and editable, so it looks live and silently goes
nowhere.

**Hide errors until the user has earned them.** The web calls this `used_input?`. A form that
renders every changeset error immediately scolds you about six fields before you have typed
anything. Keep a `MapSet` of touched fields, add to it in `handle_change`, and show a field's errors
only when it is touched **or** the form has been submitted:

```elixir
defp shown(form, touched, submitted?, key) do
  if submitted? or MapSet.member?(touched, key), do: errors_for(form, key), else: []
end
```

**Validate in one pure function.** The error list, the control's border tint and any summary line
must all ask the same question, or they disagree the moment each is computed separately — a red
border over a field showing no message is the usual result. `invalid?/1` exists so the control can
share the field's answer.

**Colour follows the theme.** Errors, the `✕` and the required `*` use the `:error` **token**, not a
hardcoded red, so they track light, dark and any custom theme. Override with `error_color` if your
design system disagrees.

## Laying a form out

Two things bite when you build a real form from this:

- **Two buttons in one `Row` starve each other.** Compose measures unweighted row children first, so
  a wide "Create account" takes the whole row and "Reset" is laid out with **zero width** — present
  in the tree, tappable by a test harness, invisible to a finger. Wrap each in a `<Box weight={1}>`
  and give the buttons `fill_width={true}`.
- **A placeholder is only in the tree while the field is empty**, so a device test cannot find a
  field by its placeholder twice. Give inputs an `id` and select by test tag.

## Related
`fieldset` (a legend over a group of these; its `disabled` does not cascade either), `checkbox`,
`switch`, `otp_field`, `number_field`.
