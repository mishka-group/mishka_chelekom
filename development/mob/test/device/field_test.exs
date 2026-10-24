defmodule MishkaMob.Device.FieldTest do
  @moduledoc """
  Device tests for the Field page: a port of `FieldTest.kt`, one test per `@Test`, on
  the host-driven suite instead of Compose instrumentation.

  A field is mostly wiring, and the wiring only shows up when a real user types into
  it, which is why this suite drives the keyboard rather than inspecting the tree.

  `errors stay hidden until you touch a field` is the behaviour the web calls
  `used_input?`. A form that scolds you about six fields before you have typed anything
  is the default outcome of "just render the changeset errors", and nothing in a unit
  test notices the difference.

  `an error replaces the hint` is the component's one real rule: showing "we'll never
  share this" directly above "email is invalid" buries the thing the user has to act on.

  What is on screen is read from the rendered tree (`showing?/1`): the error lines are
  plain Text with no tag, and a negative check is only worth something because the same
  string is shown, by a keystroke, a moment later.

  Run with `mix test --only device test/device/field_test.exs`.
  """
  use MishkaMob.DeviceCase, page: :field

  test "errors stay hidden until you touch a field" do
    # Freshly mounted: every field is empty and therefore invalid, but the user has typed
    # nothing, so the form must be silent.
    refute showing?("At least 2 characters"), "an untouched field is already complaining"

    refute showing?("That does not look like an email"),
           "an untouched email field is already complaining"

    # Touching ONE field reveals its error and only its error.
    replace_text("fld-name", "A")

    assert_eventually(fn -> showing?("At least 2 characters") end,
      message: "the name error never showed"
    )

    refute showing?("That does not look like an email"),
           "touching the name field revealed the email field's error"
  end

  test "submitting reveals every error at once" do
    refute showing?("Pick a role"), "the role error showed before submit"

    tap("fld-submit")

    assert_eventually(fn -> showing?("Pick a role") end,
      message: "submit did not reveal the role error"
    )

    # Submit touches everything, so the fields the user never reached speak up.
    assert showing?("Required."), "submit did not reveal the untouched name/email errors"
  end

  test "an error replaces the hint" do
    # The hint is visible while the field is clean.
    assert showing?("only use this to send account notifications"),
           "the email hint is not showing"

    replace_text("fld-email", "nope")

    assert_eventually(fn -> showing?("That does not look like an email") end,
      message: "the email error never showed"
    )

    # And the hint is GONE, not merely pushed below the error.
    refute showing?("only use this to send account notifications"),
           "the hint survived alongside the error"
  end

  test "a valid form reports itself valid" do
    # Assert field by field rather than only at the end: a single "it never said valid"
    # failure cannot tell you WHICH field refused the input.
    replace_text("fld-name", "Ada Lovelace")
    refute showing?("At least 2 characters"), "the name field rejected a valid name"

    replace_text("fld-email", "ada@example.com")

    refute showing?("That does not look like an email"),
           "the email field rejected a valid address"

    replace_text("fld-age", "36")
    refute showing?("Must be 18 or older"), "the age field rejected 36"
    refute showing?("Digits only"), "the age field did not receive digits"

    # The role strip always shows Owner as chosen, but the form counts the role as
    # unanswered until a segment is tapped, so the tap is what answers it.
    tap("fld-role-owner-selected")

    assert_eventually(fn -> Map.fetch!(assigns(), :form).role == :owner end,
      message: "the Owner tap did not record a role"
    )

    # No submit tap here on purpose. The summary tracks validity live, so filling the
    # form is enough to prove the rules accept it. The submit PATH is covered by
    # `submitting reveals every error at once`, which starts from a clean form.
    #
    # "Ready to submit", not "Valid": the props table contains "Validation messages", so
    # a substring check on "Valid" is true on a page nobody has touched.
    #
    # Every entry below has to name an error and nothing else the page renders. The bio
    # error reads "At most 160 characters." so it is not verbatim the bio field's
    # permanently visible hint, "Up to 160 characters."
    assert_eventually(fn -> showing?("Ready to submit") end,
      message: fn ->
        "a fully filled form still reports errors: " <>
          inspect(
            Enum.filter(
              [
                "Required.",
                "At least 2 characters",
                "does not look like an email",
                "Must be 18 or older",
                "Digits only",
                "Pick a role.",
                "At most 160 characters"
              ],
              &showing?/1
            )
          )
      end
    )

    # Optional fields stay optional: bio and age were left alone (bio) or filled validly
    # (age), and a form must not invent errors for them.
    refute showing?("Required."), "a valid form still reports required fields"

    # And bio specifically: while its error and its hint were the same sentence, this line
    # could not have been written, because the hint held it false whatever the validator did.
    refute showing?("At most 160 characters"), "an empty bio was reported as too long"
  end

  test "the age field is optional but validated when filled" do
    replace_text("fld-age", "12")
    assert_eventually(fn -> showing?("Must be 18 or older") end, message: "age 12 was accepted")

    # Blank is fine: an optional field must not complain when cleared.
    replace_text("fld-age", "")

    assert_eventually(fn -> not showing?("Must be 18 or older") end,
      message: "a cleared age still complains"
    )
  end

  test "the role picker records a choice" do
    # A <select> on the web is a segmented control here; its selection is a fill colour,
    # so the state rides in the tag.
    refute shown?("fld-role-admin-selected"), "a role was already chosen"

    tap("fld-role-admin-idle")
    assert_shown("fld-role-admin-selected")
    assert Map.fetch!(assigns(), :form).role == :admin

    refute showing?("Pick a role."), "the role error survived a valid choice"
  end

  test "reset clears the form and re hides the errors" do
    replace_text("fld-name", "A")

    assert_eventually(fn -> showing?("At least 2 characters") end,
      message: "the name error never showed"
    )

    tap("fld-reset")

    # Reset clears the touched set as well as the values, so the form goes quiet again
    # rather than complaining about the fields it just emptied.
    assert_eventually(fn -> not showing?("At least 2 characters") end,
      message: "reset left the name error showing"
    )

    refute showing?("Required."), "reset left the form scolding an untouched user"
  end

  test "the page renders every example and the props table" do
    for heading <- [
          "Label, hint and required",
          "Errors replace the hint",
          "A whole form",
          "Disabled",
          "Fieldset",
          "Props"
        ] do
      assert_text(heading)
    end

    # Every control is laid out, not just described by the tree.
    for tag <-
          ~w(fld-name fld-email fld-age fld-role-owner-selected fld-bio fld-plan fld-submit fld-reset) do
      assert_shown(tag)
    end

    # And the page is one long scroll that reaches its end.
    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), "page")
    assert max_y > 0, "the page does not scroll, so the props table is out of reach"
  end
end
