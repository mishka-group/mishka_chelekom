defmodule Mix.Tasks.Mishka.Assets.Install do
  @shortdoc "Runs package manager install or remove in assets directory"
  @moduledoc false
  use Mix.Task

  @impl Mix.Task
  def run([package_manager, "mix", command | packages]) when command in ["install", "remove"] do
    task = if command == "remove", do: "uninstall", else: command
    IO.puts("\n#{IO.ANSI.cyan()}Running mix #{package_manager} #{task}...#{IO.ANSI.reset()}")

    args =
      if command == "remove" and packages != [] do
        [task | packages]
      else
        [task]
      end

    case Mix.Task.run(package_manager, args) do
      :ok ->
        success_message(command)

      {:error, _} ->
        failure_message(command)

      _ ->
        success_message(command)
    end
  end

  def run([package_manager, "mix"]) do
    run([package_manager, "mix", "install"])
  end

  def run([package_manager, _pkg_type, command | packages])
      when command in ["install", "remove"] do
    File.cd!("assets", fn ->
      pm_command = get_package_manager_command(package_manager, command)

      args =
        if command == "remove" and packages != [] do
          [pm_command | packages]
        else
          [pm_command]
        end

      IO.puts(
        "\n#{IO.ANSI.cyan()}Running #{package_manager} #{Enum.join(args, " ")}...#{IO.ANSI.reset()}"
      )

      case System.cmd(package_manager, args, into: IO.stream(:stdio, :line)) do
        {_, 0} ->
          success_message(command)

        {_, exit_code} ->
          failure_message(command, exit_code)
      end
    end)
  end

  def run([package_manager | rest]) when rest == [] or rest == ["pkg"] do
    run([package_manager, "pkg", "install"])
  end

  defp get_package_manager_command(package_manager, command) do
    case {package_manager, command} do
      {"yarn", "install"} -> "add"
      {_, "install"} -> "install"
      {"npm", "remove"} -> "uninstall"
      {"yarn", "remove"} -> "remove"
      {"bun", "remove"} -> "remove"
      {_, "remove"} -> "uninstall"
    end
  end

  defp success_message("install") do
    IO.puts("#{IO.ANSI.green()}✓ Dependencies installed successfully!#{IO.ANSI.reset()}")
  end

  defp success_message("remove") do
    IO.puts("#{IO.ANSI.green()}✓ Dependencies removed successfully!#{IO.ANSI.reset()}")
  end

  defp failure_message("install") do
    IO.puts("#{IO.ANSI.red()}✗ Failed to install dependencies#{IO.ANSI.reset()}")
  end

  defp failure_message("remove") do
    IO.puts("#{IO.ANSI.red()}✗ Failed to remove dependencies#{IO.ANSI.reset()}")
  end

  defp failure_message("install", exit_code) do
    IO.puts(
      "#{IO.ANSI.red()}✗ Failed to install dependencies (exit code: #{exit_code})#{IO.ANSI.reset()}"
    )
  end

  defp failure_message("remove", exit_code) do
    IO.puts(
      "#{IO.ANSI.red()}✗ Failed to remove dependencies (exit code: #{exit_code})#{IO.ANSI.reset()}"
    )
  end
end
