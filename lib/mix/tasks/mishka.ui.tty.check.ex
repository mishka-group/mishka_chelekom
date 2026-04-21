defmodule Mix.Tasks.Mishka.Ui.Tty.Check do
  use Mix.Task
  @moduledoc false

  # With TTY (spinner should run)
  # mix mishka.ui.tty.check
  # Without TTY (spinner should be skipped)
  # mix mishka.ui.tty.check | cat

  @shortdoc "Test TTY detection for Owl.Spinner guards"

  def run(_args) do
    Application.ensure_all_started(:owl)

    tty? = IO.ANSI.enabled?()

    IO.puts("IO.ANSI.enabled?()        -> #{inspect(tty?)}")
    IO.puts(":prim_tty.isatty(:stdout) -> #{inspect(:prim_tty.isatty(:stdout))}")
    IO.puts(":io.columns()             -> #{inspect(:io.columns())}")

    IO.puts("\nSpinner test: #{if tty?, do: "STARTING", else: "SKIPPED (no TTY)"}")

    if tty? do
      Owl.Spinner.start(id: :test_spinner, labels: [processing: "Running..."])
      Process.sleep(500)
      Owl.Spinner.stop(id: :test_spinner, resolution: :ok, label: "Done")
    end

    IO.puts("Finished without crash.")
  end
end
