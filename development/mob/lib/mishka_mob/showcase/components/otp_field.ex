defmodule MishkaMob.Showcase.Components.OtpField do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaOtpField` and
  `MishkaMob.Components.MishkaMaskInput`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.{MishkaMaskInput, MishkaOtpField}
  alias MishkaMob.Showcase.Example

  @phone_mask "(999) 999-9999"

  @impl true
  def entry do
    %{
      slug: :otp_field,
      name: "OTP Field",
      category: "Forms",
      order: 12,
      description: "A segmented one-time-code input, plus a self-formatting mask input."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:otp_code, "")
    |> Mob.Socket.assign(:otp_focused, false)
    |> Mob.Socket.assign(:otp_masked_focused, false)
    |> Mob.Socket.assign(:otp_ref, "")
    |> Mob.Socket.assign(:otp_ref_focused, false)
    |> Mob.Socket.assign(:otp_grouped, "")
    |> Mob.Socket.assign(:otp_grouped_focused, false)
    |> Mob.Socket.assign(:otp_phone, "")
    |> Mob.Socket.assign(:otp_date, "")
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A 6-digit code",
        description: "One field behind the slots, so paste and backspace behave normally.",
        code: ~S'''
        # Registered once at boot, then it is a tag like any other:
        #   Mob.Composite.register(:mishka_otp_field, {MishkaOtpField, :expand})

        def render(assigns) do
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOtpField value={@code} length={6} on_change={:code} />
          </Column>
          """
        end

        def handle_info({:change, :code, raw}, socket) do
          {:noreply, assign(socket, :code, MishkaOtpField.sanitize(raw, length: 6))}
        end

        # The function form is still there and gives identical output, for
        # anything a tag cannot express:
        #
        #   import MishkaMob.Components.MishkaOtpField, only: [otp_field: 1]
        #   {otp_field(value: @code, length: 6, on_change: :code)}
        ''',
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOtpField
              id="otp-code"
              value={@otp_code}
              length={6}
              focused={@otp_focused}
              on_change={:otp_code}
              on_focus={:otp_focus}
              on_blur={:otp_blur}
            />
            <Spacer size={10} />
            <Text text={status(@otp_code)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Masked and shorter",
        description: "mask renders • instead of the digit; length sets the slots.",
        code: ~S'''
        ~MOB"""
        <Column fill_width={true}>
          <MishkaOtpField value={@code} length={4} mask={true} on_change={:code} />
        </Column>
        """
        ''',
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOtpField
              id="otp-masked"
              value={@otp_code}
              length={4}
              mask={true}
              focused={@otp_masked_focused}
              on_change={:otp_code}
              on_focus={:otp_masked_focus}
              on_blur={:otp_masked_blur}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Grouped, with a separator",
        description:
          "group splits the slots. An integer divides evenly (123-456); a list divides " <>
            "unevenly, which is how a reference like Ab-5563 comes out two then four.",
        code: ~S'''
        ~MOB"""
        <Column fill_width={true}>
          <MishkaOtpField value={@ref} length={6} group={[2, 4]} separator="-"
                          validation_type={:alphanumeric} on_change={:ref} />
        </Column>
        """

        # an even split needs only a number:
        #   <MishkaOtpField value={@code} length={6} group={3} separator="-" />
        ''',
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaOtpField
              id="otp-ref"
              value={@otp_ref}
              length={6}
              group={[2, 4]}
              separator="-"
              validation_type={:alphanumeric}
              focused={@otp_ref_focused}
              on_change={:otp_ref}
              on_focus={:otp_ref_focus}
              on_blur={:otp_ref_blur}
            />
            <Spacer size={10} />
            <Text text="Letters and digits — try Ab5563" text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Phone mask",
        description: "Type digits — the literals appear on their own, and re-masking is a no-op.",
        code: ~S'''
        ~MOB"""
        <Column fill_width={true}>
          <MishkaMaskInput value={@phone} mask="(999) 999-9999" on_change={:phone} />
        </Column>
        """

        # the mask is applied where the value settles — in the handler
        def handle_info({:change, :phone, raw}, socket) do
          {:noreply, assign(socket, :phone, MishkaMaskInput.apply_mask(raw, "(999) 999-9999"))}
        end
        ''',
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMaskInput value={@otp_phone} mask="(999) 999-9999" on_change={:otp_phone} />
            <Spacer size={10} />
            <Text
              text={"Unformatted: " <> MishkaMaskInput.strip(@otp_phone)}
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Date mask",
        description: "Any pattern: 9 digit, a letter, * alphanumeric, everything else literal.",
        code: ~S'''
        ~MOB"""
        <Column fill_width={true}>
          <MishkaMaskInput value={@date} mask="99/99/9999" placeholder="DD/MM/YYYY"
                           on_change={:date} />
        </Column>
        """
        ''',
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaMaskInput
              value={@otp_date}
              mask="99/99/9999"
              placeholder="DD/MM/YYYY"
              on_change={:otp_date}
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
      %{name: "value", type: "string", default: "\"\"", description: "The code so far."},
      %{name: "length", type: "integer", default: "6", description: "Number of slots."},
      %{
        name: "validation_type",
        type: "atom",
        default: ":numeric",
        description:
          ":numeric · :alpha · :alphanumeric · :none — what sanitize/2 keeps, and which keyboard opens."
      },
      %{
        name: "mask",
        type: "boolean",
        default: "false",
        description: "Render • instead of the character."
      },
      %{
        name: "group",
        type: "integer or list",
        default: "nil",
        description: "3 splits evenly (123-456); [2, 4] splits unevenly (Ab-5563)."
      },
      %{
        name: "separator",
        type: "string",
        default: "nil",
        description: "Drawn between groups. Needs `group` — one without the other does nothing."
      },
      %{
        name: "focused",
        type: "boolean",
        default: "false",
        description: "Draws the caret in the active slot. Track it with on_focus/on_blur."
      },
      %{
        name: "on_change",
        type: "event tag",
        default: "—",
        description: "{:change, tag, text} per keystroke. Sanitize it in the handler."
      },
      %{
        name: "on_focus / on_blur",
        type: "event tags",
        default: "—",
        description: "Arrive as {:focus, tag} / {:blur, tag} — NOT as taps."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Mutes the slots and disables the field natively."
      },
      %{
        name: "color",
        type: "color token / ARGB",
        default: ":primary",
        description: "Border of filled and active slots, and the caret."
      },
      %{
        name: "slot_width",
        type: "number",
        default: "44",
        description: "Width of one slot. Six at the default is about as wide as a card fits."
      },
      %{
        name: "id",
        type: "string",
        default: "nil",
        description: "Sets a native testTag on the input, for end-to-end tests."
      },
      %{
        name: "sanitize/2 · complete?/2 · boundaries/1",
        type: "helpers",
        default: "—",
        description: "Filter and truncate, is-it-full, and where the separators land."
      },
      %{
        name: "MaskInput: mask",
        type: "string",
        default: "nil",
        description: "9 digit · a letter · * alphanumeric · anything else literal."
      },
      %{
        name: "MaskInput.apply_mask/2 · strip/1",
        type: "helpers",
        default: "—",
        description: "Idempotent formatting, and the unformatted payload."
      }
    ]
  end

  @impl true
  # A flag per field: one shared flag would draw a caret in every OTP on the
  # page as soon as any of them was tapped.
  def handle(:otp_focus, socket), do: Mob.Socket.assign(socket, :otp_focused, true)
  def handle(:otp_blur, socket), do: Mob.Socket.assign(socket, :otp_focused, false)

  def handle(:otp_masked_focus, socket),
    do: Mob.Socket.assign(socket, :otp_masked_focused, true)

  def handle(:otp_masked_blur, socket),
    do: Mob.Socket.assign(socket, :otp_masked_focused, false)

  def handle(:otp_ref_focus, socket), do: Mob.Socket.assign(socket, :otp_ref_focused, true)
  def handle(:otp_ref_blur, socket), do: Mob.Socket.assign(socket, :otp_ref_focused, false)

  def handle(:otp_grouped_focus, socket),
    do: Mob.Socket.assign(socket, :otp_grouped_focused, true)

  def handle(:otp_grouped_blur, socket),
    do: Mob.Socket.assign(socket, :otp_grouped_focused, false)

  def handle(_tag, socket), do: socket

  @impl true
  def handle_change(:otp_grouped, raw, socket),
    do: Mob.Socket.assign(socket, :otp_grouped, MishkaOtpField.sanitize(raw, length: 6))

  def handle_change(:otp_ref, raw, socket),
    do:
      Mob.Socket.assign(
        socket,
        :otp_ref,
        MishkaOtpField.sanitize(raw, length: 6, validation_type: :alphanumeric)
      )

  def handle_change(:otp_code, raw, socket),
    do: Mob.Socket.assign(socket, :otp_code, MishkaOtpField.sanitize(raw, length: 6))

  def handle_change(:otp_phone, raw, socket),
    do: Mob.Socket.assign(socket, :otp_phone, MishkaMaskInput.apply_mask(raw, @phone_mask))

  def handle_change(:otp_date, raw, socket),
    do: Mob.Socket.assign(socket, :otp_date, MishkaMaskInput.apply_mask(raw, "99/99/9999"))

  def handle_change(_tag, _value, socket), do: socket

  defp status(code) do
    if MishkaOtpField.complete?(code, length: 6),
      do: "Complete — a screen would auto-submit here.",
      else: "#{String.length(code)} of 6 digits"
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Row fill_width={true}>
      <Box
        weight={1}
        height={34}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:primary}
        border_width={2}
      />
      <Spacer size={6} />
      <Box
        weight={1}
        height={34}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:primary}
        border_width={2}
      />
      <Spacer size={6} />
      <Box
        weight={1}
        height={34}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
      />
      <Spacer size={6} />
      <Box
        weight={1}
        height={34}
        background={:surface}
        corner_radius={:radius_sm}
        border_color={:border}
        border_width={1}
      />
    </Row>
    """
  end
end
