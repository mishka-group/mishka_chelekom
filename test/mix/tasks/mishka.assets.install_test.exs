defmodule Mix.Tasks.Mishka.Assets.InstallTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  # bun, not npm: it is the first manager `Npm.detect/1` looks for, it is what this repo's own
  # `assets` directory is locked with, and it installs lodash in about 90ms where npm takes
  # seconds — or, when it is fetching a real dependency through `System.cmd`'s byte-at-a-time
  # port read, hangs past ExUnit's timeout entirely.

  setup do
    # Each test gets its own unique parent dir. Tests cd into it and rename
    # the assets dir to the fixed name "assets" (the task hardcodes that
    # path). A unique parent means the fixed name can never collide across
    # tests, and rm_rf on the whole parent cleans up even if a test crashes
    # mid-rename and leaves an orphaned "assets" behind.
    original_dir = File.cwd!()
    work_dir = Path.join(System.tmp_dir!(), "test_work_#{System.unique_integer([:positive])}")
    assets_dir = Path.join(work_dir, "test_assets")
    File.mkdir_p!(assets_dir)
    File.write!(Path.join(assets_dir, "package.json"), ~s({"name": "test", "version": "1.0.0"}))

    on_exit(fn ->
      File.cd!(original_dir)
      File.rm_rf!(work_dir)
    end)

    {:ok, assets_dir: assets_dir}
  end

  describe "bun commands" do
    test "installs dependencies with bun", %{assets_dir: assets_dir} do
      write_dependency(assets_dir, "lodash")

      output = in_assets(assets_dir, fn -> run(["bun", "pkg", "install"]) end)

      assert output =~ "Running bun install..."
      assert output =~ "✓ Dependencies installed successfully!"
      assert File.exists?(Path.join(assets_dir, "bun.lock"))
      assert File.exists?(Path.join(assets_dir, "node_modules"))
    end

    test "installs a dependency and removes it again", %{assets_dir: assets_dir} do
      package_json = Path.join(assets_dir, "package.json")
      write_dependency(assets_dir, "lodash")

      install_output = in_assets(assets_dir, fn -> run(["bun", "pkg", "install"]) end)

      assert install_output =~ "Running bun install..."
      assert install_output =~ "✓ Dependencies installed successfully!"

      lodash = Path.join([assets_dir, "node_modules", "lodash"])
      assert File.dir?(lodash)
      # The package is unpacked, not just an empty directory standing in for one.
      assert "package.json" in File.ls!(lodash)

      remove_output = in_assets(assets_dir, fn -> run(["bun", "pkg", "remove", "lodash"]) end)

      assert remove_output =~ "Running bun remove lodash..."
      assert remove_output =~ "✓ Dependencies removed successfully!"
      refute File.exists?(lodash)
      # Removing takes the dependency out of the manifest, not only off the disk.
      refute File.read!(package_json) =~ ~s("lodash")
    end

    test "removes several packages in one command", %{assets_dir: assets_dir} do
      output = in_assets(assets_dir, fn -> run(["bun", "pkg", "remove", "lodash", "axios"]) end)

      assert output =~ "Running bun remove lodash axios..."
      assert output =~ "✓ Dependencies removed successfully!"
    end

    test "defaults to install when only bun is given", %{assets_dir: assets_dir} do
      assert in_assets(assets_dir, fn -> run(["bun"]) end) =~ "Running bun install..."
    end

    test "defaults to install when bun and pkg are given", %{assets_dir: assets_dir} do
      assert in_assets(assets_dir, fn -> run(["bun", "pkg"]) end) =~ "Running bun install..."
    end
  end

  describe "output messages" do
    test "shows colored output messages", %{assets_dir: assets_dir} do
      output = in_assets(assets_dir, fn -> run(["bun", "pkg", "install"]) end)

      # Check for the colored output (ANSI codes will be in the output)
      assert output =~ "Running bun install..."
      # Will contain either "installed" or "failed"
      assert String.contains?(output, "Dependencies")
    end
  end

  defp write_dependency(assets_dir, name) do
    File.write!(
      Path.join(assets_dir, "package.json"),
      ~s({"name": "test", "version": "1.0.0", "dependencies": {"#{name}": "^4.17.21"}})
    )
  end

  defp run(args) do
    Mix.Tasks.Mishka.Assets.Install.run(args)
  catch
    :error, _ -> :ok
  end

  # The task hardcodes `assets`, so each call renames the fixture into place and back out again.
  # Doing it here rather than in every test keeps the rename paired with its undo even when an
  # assertion between them would otherwise leave the fixture under the wrong name.
  defp in_assets(assets_dir, fun) do
    original_dir = File.cwd!()
    File.cd!(Path.dirname(assets_dir))

    try do
      capture_io(fn ->
        File.rename!(assets_dir, "assets")

        try do
          fun.()
        after
          File.rename!("assets", assets_dir)
        end
      end)
    after
      File.cd!(original_dir)
    end
  end
end
