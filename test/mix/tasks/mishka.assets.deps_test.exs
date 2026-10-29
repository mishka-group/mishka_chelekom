defmodule Mix.Tasks.Mishka.Assets.DepsTest do
  use ExUnit.Case
  import Igniter.Test

  alias MishkaChelekom.Generators.Npm

  # The package manager the install task was queued for: the head of its argv.
  defp queued_manager(igniter) do
    assert [{"mishka.assets.install", [manager, _package_type, "install"]}] =
             Enum.filter(igniter.tasks, &match?({"mishka.assets.install", _argv}, &1))

    manager
  end

  describe "ensure_package_json_exists/1" do
    test "creates package.json if it doesn't exist" do
      app_name = :test_app

      igniter =
        test_project(app_name: app_name)
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--yes", "--test"])
        |> assert_creates("assets/package.json")

      assert igniter.rewrite.sources["assets/package.json"]
      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      assert content =~ ~s("name": "test_app")
      assert content =~ ~s("dependencies": {)
      assert content =~ ~s("lodash": "latest")
    end

    test "uses existing package.json if it exists" do
      existing_package_json = ~s({
        "name": "existing-app",
        "version": "2.0.0",
        "dependencies": {}
      })

      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", existing_package_json)
        |> Igniter.compose_task("mishka.assets.deps", ["axios", "--yes", "--test"])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      assert content =~ ~s("name": "existing-app")
      assert content =~ ~s("version": "2.0.0")
      assert content =~ ~s("axios": "latest")
    end
  end

  describe "update_package_json_deps/3" do
    test "adds single dependency to package.json" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--yes", "--test"])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      assert json["dependencies"]["lodash"] == "latest"
    end

    test "adds multiple dependencies to package.json" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash,axios,moment", "--yes", "--test"])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      assert json["dependencies"]["lodash"] == "latest"
      assert json["dependencies"]["axios"] == "latest"
      assert json["dependencies"]["moment"] == "latest"
    end

    test "adds dependency with specific version" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash@4.17.21", "--yes", "--test"])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      assert json["dependencies"]["lodash"] == "4.17.21"
    end

    test "adds scoped packages correctly" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["@babel/core@7.20.0", "--yes", "--test"])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      assert json["dependencies"]["@babel/core"] == "7.20.0"
    end

    test "adds to devDependencies when --dev flag is used" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {},
          "devDependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["eslint", "--dev", "--yes", "--test"])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      assert json["devDependencies"]["eslint"] == "latest"
      refute Map.has_key?(json["dependencies"], "eslint")
    end

    test "preserves existing dependencies when adding new ones" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {
            "react": "18.0.0"
          }
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--yes", "--test"])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      assert json["dependencies"]["react"] == "18.0.0"
      assert json["dependencies"]["lodash"] == "latest"
    end
  end

  describe "remove_package_json_deps/3" do
    test "removes single dependency from package.json" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {
            "lodash": "4.17.21",
            "axios": "1.0.0"
          }
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--remove", "--yes", "--test"])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      refute Map.has_key?(json["dependencies"], "lodash")
      assert json["dependencies"]["axios"] == "1.0.0"
    end

    test "removes multiple dependencies from package.json" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {
            "lodash": "4.17.21",
            "axios": "1.0.0",
            "moment": "2.29.0"
          }
        }))
        |> Igniter.compose_task("mishka.assets.deps", [
          "lodash,moment",
          "--remove",
          "--yes",
          "--test"
        ])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      refute Map.has_key?(json["dependencies"], "lodash")
      refute Map.has_key?(json["dependencies"], "moment")
      assert json["dependencies"]["axios"] == "1.0.0"
    end

    test "removes from devDependencies when --dev flag is used" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {
            "lodash": "4.17.21"
          },
          "devDependencies": {
            "eslint": "8.0.0"
          }
        }))
        |> Igniter.compose_task("mishka.assets.deps", [
          "eslint",
          "--remove",
          "--dev",
          "--yes",
          "--test"
        ])

      source = igniter.rewrite.sources["assets/package.json"]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)
      assert json["dependencies"]["lodash"] == "4.17.21"
      refute Map.has_key?(json["devDependencies"], "eslint")
    end
  end

  describe "package manager selection" do
    test "uses npm when --npm flag is provided" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--npm", "--yes", "--test"])

      assert queued_manager(igniter) == "npm"
    end

    test "uses bun when --bun flag is provided" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--bun", "--yes", "--test"])

      assert queued_manager(igniter) == "bun"
    end

    test "uses yarn when --yarn flag is provided" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--yarn", "--yes", "--test"])

      # If yarn is not installed, it will fallback to bun mix dependency
      expected = if System.find_executable("yarn"), do: "yarn", else: "bun"
      assert queued_manager(igniter) == expected
    end

    test "adds bun as mix dependency when --mix-bun flag is provided" do
      igniter =
        test_project()
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--mix-bun", "--yes", "--test"])

      # Check that bun dependency was added
      assert Enum.any?(
               igniter.rewrite.sources["mix.exs"]
               |> Rewrite.Source.get(:content)
               |> String.split("\n"),
               fn line ->
                 line =~ ":bun"
               end
             )

      # Check config was added
      assert igniter.rewrite.sources["config/config.exs"]
      config_content = Rewrite.Source.get(igniter.rewrite.sources["config/config.exs"], :content)
      assert config_content =~ "config :bun"
    end

    test "auto-detects available package manager" do
      # This test verifies that when no flag is provided,
      # the task will auto-detect an available package manager
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--yes", "--test"])

      # It uses the package manager found on the PATH, or sets up mix bun when there is none
      expected = (Npm.detect() || :bun) |> Atom.to_string()
      assert queued_manager(igniter) == expected
    end
  end

  describe "task integration" do
    test "delegates to mishka.assets.install task for installation" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {}
        }))
        |> Igniter.compose_task("mishka.assets.deps", ["lodash", "--npm", "--yes", "--test"])

      # Check that the install task was added
      assert Enum.any?(igniter.tasks, fn {task_name, argv} ->
               task_name == "mishka.assets.install" and
                 argv == ["npm", "pkg", "install"]
             end)
    end

    test "delegates to mishka.assets.install with remove command" do
      igniter =
        test_project()
        |> Igniter.create_new_file("assets/package.json", ~s({
          "name": "test",
          "dependencies": {
            "lodash": "4.17.21"
          }
        }))
        |> Igniter.compose_task("mishka.assets.deps", [
          "lodash",
          "--remove",
          "--npm",
          "--yes",
          "--test"
        ])

      # Check that the install task was added with remove command
      assert Enum.any?(igniter.tasks, fn {task_name, argv} ->
               task_name == "mishka.assets.install" and
                 argv == ["npm", "pkg", "remove", "lodash"]
             end)
    end
  end
end
