defmodule Mix.Tasks.Mishka.Ui.ExportTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  @moduletag :igniter

  describe "template creation" do
    test "creates default JSON template when --template flag is used" do
      test_dir = Path.join(System.tmp_dir!(), "test_template_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--template", "--test"])

      # Find the template file - it might have a relative path key
      template_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "template.json"), do: key
        end)

      assert template_file_key
      source = igniter.rewrite.sources[template_file_key]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)

      assert json["name"] == "something-new"
      assert json["type"] == "preset"
      assert is_list(json["files"])
      assert length(json["files"]) == 1

      file = List.first(json["files"])
      assert file["type"] == "component"
      assert file["name"] == "last_message"
      assert Map.has_key?(file, "args")
      assert is_list(file["optional"])
      assert is_list(file["necessary"])
    end

    test "creates template with custom name" do
      test_dir = Path.join(System.tmp_dir!(), "test_custom_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [
          test_dir,
          "--template",
          "--name",
          "custom",
          "--test"
        ])

      # Find the custom file
      custom_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "custom.json"), do: key
        end)

      assert custom_file_key
      source = igniter.rewrite.sources[custom_file_key]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)

      assert json["name"] == "something-new"
    end
  end

  describe "directory validation" do
    test "reports error when directory doesn't exist" do
      non_existent_dir = "/path/that/does/not/exist"

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [non_existent_dir, "--test"])

      # Issues in igniter are strings
      assert Enum.any?(igniter.issues, fn issue ->
               is_binary(issue) && issue == "The entered directory does not exist."
             end)
    end
  end

  describe "JavaScript file export" do
    test "exports JavaScript files with component files" do
      test_dir = Path.join(System.tmp_dir!(), "test_js_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      # Create a valid component first to avoid validation error
      File.write!(Path.join(test_dir, "component_test.eex"), "<div>Test</div>")

      File.write!(
        Path.join(test_dir, "component_test.exs"),
        ~s([component_test: [name: "test", args: []]])
      )

      # Add JavaScript file
      js_content = "console.log('Hello from component');"
      File.write!(Path.join(test_dir, "button_script.js"), js_content)

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--test"])

      template_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "template.json"), do: key
        end)

      assert template_file_key
      source = igniter.rewrite.sources[template_file_key]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)

      # Should have both component and JavaScript files
      assert length(json["files"]) == 2

      js_file = Enum.find(json["files"], &(&1["type"] == "javascript"))
      assert js_file["name"] == "button_script"
      assert js_file["content"] == js_content
    end

    test "exports JavaScript with Base64 encoding" do
      test_dir = Path.join(System.tmp_dir!(), "test_js_base64_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      # Create a valid component first
      File.write!(Path.join(test_dir, "component_test.eex"), "<div>Test</div>")

      File.write!(
        Path.join(test_dir, "component_test.exs"),
        ~s([component_test: [name: "test", args: []]])
      )

      # Add JavaScript file
      js_content = "console.log('Special: éñüçh');"
      File.write!(Path.join(test_dir, "special.js"), js_content)

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--base64", "--test"])

      template_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "template.json"), do: key
        end)

      assert template_file_key
      source = igniter.rewrite.sources[template_file_key]
      json_content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(json_content)

      js_file = Enum.find(json["files"], &(&1["type"] == "javascript"))
      encoded_content = js_file["content"]

      # Verify it's Base64 encoded
      refute encoded_content == js_content
      assert Base.decode64!(encoded_content) == js_content
    end
  end

  describe "component validation" do
    test "requires matching .exs and .eex files" do
      test_dir = Path.join(System.tmp_dir!(), "validation_test_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      # Create only .eex file without corresponding .exs
      File.write!(Path.join(test_dir, "component_test.eex"), "<div>Test</div>")

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--test"])

      # Should have validation error about missing .exs file
      assert Enum.any?(igniter.issues, fn issue ->
               is_binary(issue) && String.contains?(issue, "problems with the file list")
             end)
    end

    test "accepts valid component file pairs" do
      test_dir = Path.join(System.tmp_dir!(), "valid_test_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      # Create matching .exs and .eex files
      File.write!(Path.join(test_dir, "component_test.eex"), "<div>Test Component</div>")

      File.write!(
        Path.join(test_dir, "component_test.exs"),
        ~s([
          component_test: [
            name: "test_component",
            args: [variant: ["outline", "solid"]]
          ]
        ])
      )

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--test"])

      # Should create JSON file successfully
      template_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "template.json"), do: key
        end)

      assert template_file_key
      source = igniter.rewrite.sources[template_file_key]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)

      assert length(json["files"]) == 1
      file = List.first(json["files"])
      assert file["type"] == "component"
      assert file["name"] == "test_component"
      assert file["content"] == "<div>Test Component</div>"
    end
  end

  describe "options" do
    test "uses custom name option" do
      test_dir = Path.join(System.tmp_dir!(), "test_name_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      # Add a valid component first
      File.write!(Path.join(test_dir, "component_test.eex"), "<div>Test</div>")

      File.write!(
        Path.join(test_dir, "component_test.exs"),
        ~s([component_test: [name: "test", args: []]])
      )

      File.write!(Path.join(test_dir, "test.js"), "// test content")

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--name", "my_export", "--test"])

      my_export_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "my_export.json"), do: key
        end)

      assert my_export_file_key
      source = igniter.rewrite.sources[my_export_file_key]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)

      assert json["name"] == "my_export"
    end

    test "uses custom org option" do
      test_dir = Path.join(System.tmp_dir!(), "test_org_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      # Add a valid component first
      File.write!(Path.join(test_dir, "component_test.eex"), "<div>Test</div>")

      File.write!(
        Path.join(test_dir, "component_test.exs"),
        ~s([component_test: [name: "test", args: []]])
      )

      File.write!(Path.join(test_dir, "test.js"), "// test content")

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--org", "preset", "--test"])

      template_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "template.json"), do: key
        end)

      assert template_file_key
      source = igniter.rewrite.sources[template_file_key]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)

      assert json["type"] == "preset"
    end

    test "defaults invalid org to component" do
      test_dir = Path.join(System.tmp_dir!(), "test_org_invalid_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      # Add a valid component first
      File.write!(Path.join(test_dir, "component_test.eex"), "<div>Test</div>")

      File.write!(
        Path.join(test_dir, "component_test.exs"),
        ~s([component_test: [name: "test", args: []]])
      )

      File.write!(Path.join(test_dir, "test.js"), "// test content")

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--org", "invalid_type", "--test"])

      template_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "template.json"), do: key
        end)

      assert template_file_key
      source = igniter.rewrite.sources[template_file_key]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)

      assert json["type"] == "component"
    end
  end

  describe "real community component export" do
    test "exports community alert component with Base64 encoding" do
      test_dir = Path.join(System.tmp_dir!(), "test_community_#{:rand.uniform(100_000)}")
      File.mkdir_p!(test_dir)
      on_exit(fn -> File.rm_rf!(test_dir) end)

      # Simpler version of community component content
      component_eex_content = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr(:class, :string, default: nil)

        def community_alert_001(assigns) do
          ~H\"\"\"
          <div class={@class}>
            <p>Attention needed</p>
            <p class="text-xs">Lorem ipsum dolor sit amet.</p>
          </div>
          \"\"\"
        end
      end
      """

      component_exs_content = """
      [
        component_alert_001: [
          name: "component_alert_001",
          args: [
            only: ["community_alert_001"],
            helpers: [],
            module: ""
          ],
          optional: [],
          necessary: ["alert"]
        ]
      ]
      """

      File.write!(Path.join(test_dir, "component_alert_001.eex"), component_eex_content)
      File.write!(Path.join(test_dir, "component_alert_001.exs"), component_exs_content)

      igniter =
        test_project_with_formatter()
        |> Igniter.compose_task("mishka.ui.export", [test_dir, "--base64", "--test"])

      template_file_key =
        Enum.find_value(igniter.rewrite.sources, fn {key, _} ->
          if String.ends_with?(key, "template.json"), do: key
        end)

      assert template_file_key
      source = igniter.rewrite.sources[template_file_key]
      content = Rewrite.Source.get(source, :content)
      json = Jason.decode!(content)

      # Verify the structure
      assert json["name"] == "template"
      assert json["type"] == "component"
      assert length(json["files"]) == 1

      file = List.first(json["files"])
      assert file["type"] == "component"
      assert file["name"] == "component_alert_001"

      # Verify the content is Base64 encoded
      encoded_content = file["content"]
      refute encoded_content == component_eex_content
      decoded_content = Base.decode64!(encoded_content)
      assert decoded_content == component_eex_content

      # Verify args structure
      assert file["args"]["only"] == ["community_alert_001"]
      assert file["args"]["helpers"] == %{}
      assert file["args"]["module"] == ""
      assert file["optional"] == []
      assert file["necessary"] == ["alert"]
    end
  end

  # The JSON the export writes for the kit's own `priv/<layer>/<name>` pair, copied into a directory
  # of its own: its `.exs` as the kit ships it, or the same options without the docs block.
  defp exported(layer, name, docs?, args) do
    dir = Path.join(System.tmp_dir!(), "export_docs_#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)

    exs = File.read!("priv/#{layer}/#{name}.exs")
    assert exs =~ "docs: ["

    File.cp!("priv/#{layer}/#{name}.eex", Path.join(dir, "#{name}.eex"))
    File.write!(Path.join(dir, "#{name}.exs"), if(docs?, do: exs, else: without_docs(exs)))

    igniter =
      test_project_with_formatter()
      |> Igniter.compose_task("mishka.ui.export", [dir, "--test" | args])

    assert igniter.issues == []

    igniter.rewrite.sources
    |> Enum.find_value(fn {path, source} ->
      if String.ends_with?(path, ".json"), do: Rewrite.Source.get(source, :content)
    end)
    |> Jason.decode!()
  end

  defp without_docs(exs) do
    {[{key, config}], _binding} = Code.eval_string(exs)

    inspect([{key, Keyword.delete(config, :docs)}], limit: :infinity, printable_limit: :infinity)
  end

  describe "a catalog's docs block" do
    test "the default export does not carry it" do
      json = exported("components", "alert", true, [])

      assert json == exported("components", "alert", false, [])
      assert [file] = json["files"]
      refute Map.has_key?(file, "docs")
    end

    test "the CMS bundle does not carry it, for a styled or a headless component" do
      cms = ["--cms", "--name", "kit", "--bundle-name", "kit", "--bundle-version", "1.0.0"]

      for {layer, name} <- [{"components", "alert"}, {"headless", "popover"}] do
        bundle = exported(layer, name, true, cms)

        assert bundle == exported(layer, name, false, cms), "#{layer}/#{name}"
        assert [_ | _] = bundle["components"]
      end
    end
  end
end
