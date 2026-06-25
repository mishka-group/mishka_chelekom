defmodule MishkaChelekom.DemoHarnessTest do
  @moduledoc """
  End-to-end render harness for the chelekom kit.

  Exports the bundle from `priv/components/` (using vendored demos
  under `priv/demos/`), then runs `MishkaChelekom.Test.Runtime.DemoHarness`
  against it: every demo invocation is rendered through a vendored
  copy of the runtime CMS dispatcher (`<.component component_name=…
  site=…/>`), exactly the way it'll render once the bundle is
  installed in MishkaCMS.

  Lives in chelekom (not mishka_cms) because:

    * The kit author should be able to verify their bundle WITHOUT
      a downstream CMS install.
    * When this test passes, the bundle is guaranteed to render in
      any consumer that uses the same dispatcher pattern.

  The CMS-side `installer_test.exs` remains as a thin smoke test that
  the bundle round-trips through `Ash.create!` cleanly.

  Skipped categories (structural, not real bugs) are listed in the
  vendored harness's `classify/1` function.
  """

  use ExUnit.Case, async: false

  alias MishkaChelekom.Test.Runtime.DemoHarness

  @moduletag :demo_harness
  @moduletag timeout: :timer.minutes(5)

  @bundle_path Path.join([
                 :code.priv_dir(:mishka_chelekom),
                 "components",
                 "chelekom.json"
               ])

  setup_all do
    # Re-export the bundle to ensure we render against the latest
    # source. Captures stdout to keep test output clean.
    ExUnit.CaptureIO.capture_io(fn ->
      ExUnit.CaptureIO.capture_io(:stderr, fn ->
        Mix.Task.rerun("mishka.ui.export", [
          "priv/components",
          "--cms",
          "--name",
          "chelekom",
          "--bundle-name",
          "chelekom",
          "--bundle-version",
          "0.0.9-alpha.19",
          "--yes"
        ])
      end)
    end)

    File.exists?(@bundle_path) ||
      raise "Bundle export did not produce #{@bundle_path}. Did the export task fail?"

    :ok
  end

  test "every demo invocation renders cleanly via the vendored runtime dispatcher" do
    # `:infinity` runs every invocation in every demo (~2,719 total).
    # Caps to a small number can be set during local debugging.
    report = DemoHarness.run("chelekom", max_per_component: :infinity)

    summary = """
      components total          : #{report.components_total}
      components with examples  : #{report.components_with_examples}
      components exercised      : #{report.components_exercised}/#{report.components_total} (incl. dispatched-to sub-components)
      passed                    : #{report.passed}
      skipped (structural)      : #{length(report.skipped)}
      failed                    : #{length(report.failed)}
    """

    if report.failed != [] do
      details =
        report.failed
        |> Enum.group_by(& &1.component)
        |> Enum.sort_by(fn {c, fs} -> {-length(fs), c} end)
        |> Enum.map_join("\n\n", fn {component, fails} ->
          fail_lines =
            Enum.map_join(fails, "\n", fn f ->
              "    #{f.file}:#{f.line}\n      #{first_line(f.reason)}"
            end)

          "  ## #{component} (#{length(fails)} failures)\n#{fail_lines}"
        end)

      flunk("Demo harness failed:\n\n#{summary}\n#{details}")
    end

    assert report.components_with_examples > 0,
           "no component had demo examples — did the exporter stop writing `extra.demo_examples`?\n#{summary}"

    assert report.passed > 0, "expected at least one demo to pass:\n#{summary}"

    IO.puts(:stderr, "\n[demo harness · chelekom]\n" <> summary)

    if report.uncovered != [] do
      IO.puts(:stderr, "[demo harness · uncovered] " <> Enum.join(report.uncovered, ", "))
    end
  end

  defp first_line(s), do: s |> String.split("\n") |> hd()
end
