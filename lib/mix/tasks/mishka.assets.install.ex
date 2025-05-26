defmodule Mix.Tasks.Mishka.Assets.Install do
  @shortdoc "Runs package manager install in assets directory"
  @moduledoc false
  use Mix.Task

  @impl Mix.Task
  def run([package_manager, "mix"]) do
    IO.puts("\n#{IO.ANSI.cyan()}Running mix #{package_manager} install...#{IO.ANSI.reset()}")

    case Mix.Task.run(package_manager, ["install"]) do
      :ok ->
        IO.puts("#{IO.ANSI.green()}✓ Dependencies installed successfully!#{IO.ANSI.reset()}")

      {:error, _} ->
        IO.puts("#{IO.ANSI.red()}✗ Failed to install dependencies#{IO.ANSI.reset()}")

      _ ->
        # For bun, it might not return :ok, so let's assume success if no error
        IO.puts("#{IO.ANSI.green()}✓ Dependencies installed successfully!#{IO.ANSI.reset()}")
    end
  end

  def run([package_manager | _]) do
    File.cd!("assets", fn ->
      IO.puts("\n#{IO.ANSI.cyan()}Running #{package_manager} install...#{IO.ANSI.reset()}")

      case System.cmd(package_manager, ["install"], into: IO.stream(:stdio, :line)) do
        {_, 0} ->
          IO.puts("#{IO.ANSI.green()}✓ Dependencies installed successfully!#{IO.ANSI.reset()}")

        {_, exit_code} ->
          IO.puts(
            "#{IO.ANSI.red()}✗ Failed to install dependencies (exit code: #{exit_code})#{IO.ANSI.reset()}"
          )
      end
    end)
  end
end
