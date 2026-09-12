defmodule DevelopmentWeb.HeadlessCountdownTest do
  @moduledoc """
  The countdown's server-rendered state and its unit arithmetic.

  The ticking is the hook's job and is verified in a browser; what has to hold here is that the
  *first* paint is already correct — the whole reason the remaining time is computed on the server
  — and that `split/2` never loses time when a unit is left out.
  """
  use DevelopmentWeb.ConnCase, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.Headless.Countdown

  defp clock(assigns) do
    doc(render_component(&Countdown.countdown/1, Map.merge(%{id: "c"}, assigns)))
  end

  defp digits(doc), do: doc |> LazyHTML.query("[data-part=digit]") |> Enum.map(&LazyHTML.text/1)

  describe "split/2" do
    test "the whole duration is accounted for, whichever units are shown" do
      total = 2 * 86_400 + 5 * 3_600 + 42 * 60 + 17
      sizes = %{"days" => 86_400, "hours" => 3_600, "minutes" => 60, "seconds" => 1}

      for units <- [
            ~w(days hours minutes seconds),
            ~w(hours minutes seconds),
            ~w(minutes seconds),
            ~w(seconds)
          ] do
        parts = Countdown.split(total, units)
        summed = Enum.reduce(parts, 0, fn {unit, value}, acc -> acc + value * sizes[unit] end)

        assert summed == total, "#{inspect(units)} lost time: #{summed} of #{total}"
        assert Enum.map(parts, &elem(&1, 0)) == units
      end
    end

    test "the largest unit shown absorbs everything above it rather than dropping it" do
      two_days = 2 * 86_400
      assert Countdown.split(two_days, ~w(hours minutes)) == [{"hours", 48}, {"minutes", 0}]
      assert Countdown.split(two_days, ~w(seconds)) == [{"seconds", two_days}]
    end

    test "smaller units never overflow their own base" do
      for seconds <- [0, 1, 59, 60, 3599, 3600, 86_399, 86_400, 1_000_000] do
        parts = Map.new(Countdown.split(seconds, ~w(days hours minutes seconds)))

        assert parts["seconds"] < 60
        assert parts["minutes"] < 60
        assert parts["hours"] < 24
      end
    end

    test "a passed deadline reads zero rather than going negative" do
      assert Countdown.split(-500, ~w(minutes seconds)) == [{"minutes", 0}, {"seconds", 0}]
    end
  end

  describe "rendering" do
    test "the first paint already carries the remaining time" do
      doc = clock(%{seconds: 2 * 86_400 + 5 * 3_600 + 42 * 60 + 17})
      assert digits(doc) == ~w(2 5 42 17)
    end

    test "a target renders the same as the equivalent duration" do
      target = DateTime.add(DateTime.utc_now(), 3 * 3_600 + 30 * 60)
      doc = clock(%{target: target, units: ~w(hours minutes)})

      # A second may elapse mid-render, so allow the minute to have just ticked over.
      assert digits(doc) in [~w(3 30), ~w(3 29)]
    end

    test "an ISO8601 string is accepted as readily as a DateTime" do
      target = DateTime.utc_now() |> DateTime.add(120) |> DateTime.to_iso8601()
      doc = clock(%{target: target, units: ~w(minutes seconds)})

      assert [minutes, _seconds] = digits(doc)
      assert minutes in ~w(1 2)
    end

    test "the hook is handed an absolute deadline, not a duration" do
      doc = clock(%{seconds: 60})
      deadline = doc |> attr("[data-part=root]", "data-deadline") |> String.to_integer()

      # Milliseconds since the epoch, roughly a minute out.
      assert_in_delta deadline, System.system_time(:millisecond) + 60_000, 2_000
    end

    test "a past target renders zeroes and says it is complete" do
      doc = clock(%{target: DateTime.add(DateTime.utc_now(), -60)})

      assert digits(doc) == ~w(0 0 0 0)
      assert has_attr?(doc, "[data-part=root]", "data-complete")
    end

    test "a ticking timer does not announce every second by default" do
      quiet = clock(%{seconds: 90})
      assert attr(quiet, "[data-part=root]", "role") == "timer"
      assert attr(quiet, "[data-part=root]", "aria-live") == "off"

      loud = clock(%{seconds: 90, announce: true})
      assert attr(loud, "[data-part=root]", "aria-live") == "polite"
    end

    test "each digit carries --value for the skin and a label for a screen reader" do
      doc = clock(%{seconds: 3_723, units: ~w(hours minutes seconds)})

      styles = doc |> LazyHTML.query("[data-part=digit]") |> LazyHTML.attribute("style")
      assert styles == ["--value:1;", "--value:2;", "--value:3;"]

      labels = doc |> LazyHTML.query("[data-part=digit]") |> LazyHTML.attribute("aria-label")
      assert labels == ["1 hours", "2 minutes", "3 seconds"]
    end

    test "labels are opt-in, overridable, and hidden from the reader that already has them" do
      plain = clock(%{seconds: 60})
      assert LazyHTML.query(plain, "[data-part=label]") |> LazyHTML.to_tree() == []

      doc = clock(%{seconds: 60, show_labels: true, labels: %{"seconds" => "sec"}})
      texts = doc |> LazyHTML.query("[data-part=label]") |> Enum.map(&LazyHTML.text/1)

      assert "sec" in texts
      assert attr(doc, "[data-part=label]", "aria-hidden") == "true"
    end

    test "separators sit between units, never before the first" do
      doc = clock(%{seconds: 60, units: ~w(hours minutes seconds), separator: ":"})
      seps = LazyHTML.query(doc, "[data-part=separator]")

      assert length(LazyHTML.to_tree(seps)) == 2
      assert attr(doc, "[data-part=separator]", "aria-hidden") == "true"
    end

    test "only the requested units are rendered" do
      doc = clock(%{seconds: 90, units: ~w(minutes seconds)})
      units = doc |> LazyHTML.query("[data-part=unit]") |> LazyHTML.attribute("data-unit")

      assert units == ~w(minutes seconds)
      assert attr(doc, "[data-part=root]", "data-units") == "minutes seconds"
    end
  end

  test "the showcase page renders every countdown with a live deadline", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/showcase/headless-daisyui/countdown")

    doc = LazyHTML.from_document(html)

    deadlines =
      doc
      |> LazyHTML.query("[data-part=root][data-deadline]")
      |> LazyHTML.attribute("data-deadline")

    assert length(deadlines) >= 8
    assert Enum.all?(deadlines, &(String.to_integer(&1) > System.system_time(:millisecond)))
  end
end
