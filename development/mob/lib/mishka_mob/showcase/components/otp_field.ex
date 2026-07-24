defmodule MishkaMob.Showcase.Components.OtpField do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaOtpField` and
  `MishkaMob.Components.MishkaMaskInput`.
  """
  use MishkaMob.Showcase

  import Mob.Sigil
  import MishkaMob.Components.MishkaOtpField, only: [otp_field: 1]
  import MishkaMob.Components.MishkaMaskInput, only: [mask_input: 1]

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
    |> Mob.Socket.assign(:otp_phone, "")
    |> Mob.Socket.assign(:otp_date, "")
  end

  @impl true
  def examples do
    [
      %Example{
        title: "A 6-digit code",
        description: "One field behind the slots, so paste and backspace behave normally.",
        code: ~S"""
        {otp_field(value: @code, length: 6, on_change: :code)}

        def handle_info({:change, :code, raw}, socket) do
          {:noreply, assign(socket, :code, MishkaOtpField.sanitize(raw, length: 6))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {otp_field(value: @otp_code, length: 6, on_change: :otp_code)}
            <Spacer size={10} />
            <Text text={status(@otp_code)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      },
      %Example{
        title: "Masked and shorter",
        description: "mask renders • instead of the digit; length sets the slots.",
        code: ~S"""
        {otp_field(value: @code, length: 4, mask: true)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {otp_field(value: @otp_code, length: 4, mask: true, on_change: :otp_code)}
          </Column>
          """
        end
      },
      %Example{
        title: "Phone mask",
        description: "Type digits — the literals appear on their own, and re-masking is a no-op.",
        code: ~S"""
        {mask_input(value: @phone, mask: "(999) 999-9999", on_change: :phone)}

        MishkaMaskInput.apply_mask(raw, "(999) 999-9999")
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {mask_input(value: @otp_phone, mask: "(999) 999-9999", on_change: :otp_phone)}
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
        code: ~S"""
        {mask_input(value: @date, mask: "99/99/9999", on_change: :date)}
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            {mask_input(value: @otp_date, mask: "99/99/9999", placeholder: "DD/MM/YYYY",
                        on_change: :otp_date)}
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
        type: ":numeric · :alpha · :alphanumeric · :none",
        default: ":numeric",
        description: "What sanitize/2 keeps."
      },
      %{
        name: "mask",
        type: "boolean",
        default: "false",
        description: "Render • instead of the character."
      },
      %{
        name: "sanitize/2 · complete?/2",
        type: "helpers",
        default: "—",
        description: "Filter and truncate a paste; say when the code is full."
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
