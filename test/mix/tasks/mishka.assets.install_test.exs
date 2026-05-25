defmodule Mix.Tasks.Mishka.Assets.InstallTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

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

  describe "npm commands" do
    test "installs and removes lodash package", %{assets_dir: assets_dir} do
      # First, let's modify package.json to have lodash as a dependency
      package_json_path = Path.join(assets_dir, "package.json")

      File.write!(
        package_json_path,
        ~s({"name": "test", "version": "1.0.0", "dependencies": {"lodash": "^4.17.21"}})
      )

      # Change to test directory to avoid affecting real assets
      original_dir = File.cwd!()
      File.cd!(Path.dirname(assets_dir))

      # Test install
      install_output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["npm", "pkg", "install"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      assert install_output =~ "Running npm install..."

      # Check if node_modules was created (if npm succeeded)
      node_modules = Path.join(assets_dir, "node_modules")
      assert File.exists?(Path.join(node_modules, "lodash"))
      assert File.ls!(Path.join(node_modules, "lodash")) > 0
      assert install_output =~ "✓ Dependencies installed successfully!"

      # Now test removing lodash
      remove_output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["npm", "pkg", "remove", "lodash"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      assert remove_output =~ "Running npm uninstall lodash..."

      # Check if lodash was removed from package.json
      updated_package_json = File.read!(package_json_path)

      assert {:error, :enoent} = File.ls(Path.join(node_modules, "lodash"))

      if remove_output =~ "✓ Dependencies removed successfully!" do
        refute updated_package_json =~ ~s("lodash")
      end

      File.cd!(original_dir)
    end

    test "runs npm uninstall for remove command with packages", %{assets_dir: assets_dir} do
      original_dir = File.cwd!()
      File.cd!(Path.dirname(assets_dir))

      output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["npm", "pkg", "remove", "lodash", "axios"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      File.cd!(original_dir)

      assert output =~ "Running npm uninstall lodash axios..."

      assert output =~ "✓ Dependencies removed successfully!"
    end

    test "defaults to install when only npm specified", %{assets_dir: assets_dir} do
      original_dir = File.cwd!()
      File.cd!(Path.dirname(assets_dir))

      output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["npm"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      File.cd!(original_dir)

      assert output =~ "Running npm install..."
    end

    test "defaults to install when npm pkg specified", %{assets_dir: assets_dir} do
      original_dir = File.cwd!()
      File.cd!(Path.dirname(assets_dir))

      output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["npm", "pkg"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      File.cd!(original_dir)

      assert output =~ "Running npm install..."
    end
  end

  describe "bun commands" do
    test "installs dependencies with bun", %{assets_dir: assets_dir} do
      # Add a dependency to package.json
      package_json_path = Path.join(assets_dir, "package.json")

      File.write!(
        package_json_path,
        ~s({"name": "test", "version": "1.0.0", "dependencies": {"lodash": "^4.17.21"}})
      )

      original_dir = File.cwd!()
      File.cd!(Path.dirname(assets_dir))

      output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["bun", "pkg", "install"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      File.cd!(original_dir)

      assert output =~ "Running bun install..."

      assert output =~ "✓ Dependencies installed successfully!"
      assert File.exists?(Path.join(assets_dir, "bun.lock"))
      assert File.exists?(Path.join(assets_dir, "node_modules"))
    end

    test "runs bun remove for remove command", %{assets_dir: assets_dir} do
      # First, add lodash to package.json and install it
      package_json_path = Path.join(assets_dir, "package.json")

      File.write!(
        package_json_path,
        ~s({"name": "test", "version": "1.0.0", "dependencies": {"lodash": "^4.17.21"}})
      )

      original_dir = File.cwd!()
      File.cd!(Path.dirname(assets_dir))

      # Install lodash first
      capture_io(fn ->
        File.rename!(assets_dir, "assets")

        try do
          Mix.Tasks.Mishka.Assets.Install.run(["bun", "pkg", "install"])
        catch
          :error, _ -> :ok
        end

        File.rename!("assets", assets_dir)
      end)

      # Verify lodash was installed
      node_modules = Path.join(assets_dir, "node_modules")
      assert File.exists?(Path.join(node_modules, "lodash"))

      # Now test removing lodash
      output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["bun", "pkg", "remove", "lodash"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      File.cd!(original_dir)

      assert output =~ "Running bun remove lodash..."
      assert output =~ "✓ Dependencies removed successfully!"

      # Verify lodash was removed
      refute File.exists?(Path.join(node_modules, "lodash"))
    end

    test "defaults to install when only bun specified", %{assets_dir: assets_dir} do
      original_dir = File.cwd!()
      File.cd!(Path.dirname(assets_dir))

      output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["bun"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      File.cd!(original_dir)

      assert output =~ "Running bun install..."
    end
  end

  describe "output messages" do
    test "shows colored output messages", %{assets_dir: assets_dir} do
      original_dir = File.cwd!()
      File.cd!(Path.dirname(assets_dir))

      output =
        capture_io(fn ->
          File.rename!(assets_dir, "assets")

          try do
            Mix.Tasks.Mishka.Assets.Install.run(["npm", "pkg", "install"])
          catch
            :error, _ -> :ok
          end

          File.rename!("assets", assets_dir)
        end)

      File.cd!(original_dir)

      # Check for the colored output (ANSI codes will be in the output)
      assert output =~ "Running npm install..."
      # Will contain either "installed" or "failed"
      assert String.contains?(output, "Dependencies")
    end
  end
end
