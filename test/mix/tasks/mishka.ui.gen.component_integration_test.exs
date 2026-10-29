defmodule Mix.Tasks.Mishka.Ui.Gen.ComponentIntegrationTest do
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper
  alias Mix.Tasks.Mishka.Ui.Gen.Component
  @moduletag :igniter

  # `mishka.ui.gen.component` reads three things from the real disk, relative to the working
  # directory, that Igniter's virtual project does not hold: a host template (`component_*`)
  # under the app's build priv dir (`_build/<env>/lib/<app>/priv/mishka_chelekom/components`,
  # which a real project reaches through its `priv` symlink), the `lib/<app>_web/components`
  # folder, and the Tailwind version in `config/config.exs`. So each test runs in its own
  # temporary project directory that holds them.
  @app :chelekom_it

  setup do
    Application.ensure_all_started(:owl)

    root = File.cwd!()
    tmp = Path.join(System.tmp_dir!(), "chelekom_it_#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join(tmp, "lib/#{@app}_web/components"))
    File.cd!(tmp)
    MishkaChelekom.ComponentTestHelper.setup_config()

    on_exit(fn ->
      File.cd!(root)
      File.rm_rf!(tmp)
    end)

    :ok
  end

  defp project do
    test_project_with_formatter(app_name: @app)
    |> Igniter.Project.Deps.add_dep({:phoenix, "~> 1.8"})
    |> Igniter.Project.Config.configure("config.exs", :tailwind, [:version], "4.0.0")
  end

  defp host_template(igniter, file, content) do
    dir = Igniter.Project.Application.priv_dir(igniter, ["mishka_chelekom", "components"])
    File.mkdir_p!(dir)
    File.write!(Path.join(dir, file), content)
    igniter
  end

  describe "component generation integration" do
    test "generates button component with correct HTML structure" do
      # Create a button component template with specific HTML
      button_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        @doc \"\"\"
        Button component
        \"\"\"
        attr :variant, :string, default: "default", values: <%= inspect(@variant || ["default"]) %>
        attr :color, :string, default: "primary", values: <%= inspect(@color || ["primary"]) %>
        attr :size, :string, default: "md", values: <%= inspect(@size || ["md"]) %>
        attr :class, :any, default: ""
        attr :rest, :global, include: ~w(disabled form type)
        slot :inner_block, required: true

        def button(assigns) do
          ~H\"\"\"
          <button
            class={[
              "btn",
              "btn-\#{@variant}",
              "btn-\#{@color}",
              "btn-\#{@size}",
              @class
            ]}
            {@rest}
          >
            {render_slot(@inner_block)}
          </button>
          \"\"\"
        end
      end
      """

      igniter =
        project()
        |> host_template(
          "component_button.eex",
          button_template
        )
        |> host_template("component_button.exs", """
        [
          component_button: [
            name: "component_button",
            args: [
              variant: ["default", "outline", "ghost", "link"],
              color: ["primary", "secondary", "danger", "warning", "success"],
              size: ["xs", "sm", "md", "lg", "xl"]
            ],
            necessary: [],
            optional: ["component_icon"],
            scripts: []
          ]
        ]
        """)
        |> Igniter.compose_task(Component, [
          "component_button",
          "--variant",
          "default,outline",
          "--color",
          "primary,secondary",
          "--size",
          "md,lg",
          "--yes",
          "--no-deps"
        ])

      # The component file was generated
      component_created =
        igniter.rewrite.sources["lib/chelekom_it_web/components/component_button.ex"]

      assert %Rewrite.Source{} = component_created, "the component was not generated"

      # Get the generated content
      source = igniter.rewrite.sources["lib/chelekom_it_web/components/component_button.ex"]
      content = Rewrite.Source.get(source, :content)

      # Verify the module name is correct
      assert String.contains?(content, "defmodule ChelekomItWeb.Components.ComponentButton do")

      # Verify Phoenix.Component is used
      assert String.contains?(content, "use Phoenix.Component")

      # Verify the button function exists
      assert String.contains?(content, "def button(assigns) do")

      # Verify HTML structure
      assert String.contains?(content, "<button")
      assert String.contains?(content, "render_slot(@inner_block)")

      # Verify the variants were properly injected
      assert String.contains?(content, ~s(values: ["default", "outline"]))

      # Verify the colors were properly injected
      assert String.contains?(content, ~s(values: ["primary", "secondary"]))

      # Verify the sizes were properly injected
      assert String.contains?(content, ~s(values: ["md", "lg"]))

      # Verify CSS classes are applied
      assert String.contains?(content, "btn-\#{@variant}")
      assert String.contains?(content, "btn-\#{@color}")
      assert String.contains?(content, "btn-\#{@size}")
    end

    test "generates alert component with dismiss functionality" do
      alert_template = """
      defmodule <%= @module %> do
        use Phoenix.Component
        alias Phoenix.LiveView.JS

        @doc \"\"\"
        Alert component with dismiss functionality
        \"\"\"
        attr :id, :string, required: true
        attr :variant, :string, default: "info", values: <%= inspect(@variant || ["info"]) %>
        attr :dismissible, :boolean, default: false
        attr :class, :any, default: ""
        slot :inner_block, required: true

        def alert(assigns) do
          ~H\"\"\"
          <div
            id={@id}
            role="alert"
            class={[
              "alert",
              "alert-\#{@variant}",
              @class
            ]}
          >
            <div class="alert-content">
              {render_slot(@inner_block)}
            </div>
            <%%= if @dismissible do %>
              <button
                type="button"
                class="alert-dismiss"
                phx-click={JS.hide(to: "#\#{@id}", transition: "fade-out")}
              >
                <span aria-hidden="true">&times;</span>
              </button>
            <%% end %>
          </div>
          \"\"\"
        end
      end
      """

      igniter =
        project()
        |> host_template(
          "component_alert.eex",
          alert_template
        )
        |> host_template("component_alert.exs", """
        [
          component_alert: [
            name: "component_alert",
            args: [
              variant: ["info", "success", "warning", "danger"]
            ],
            necessary: [],
            optional: [],
            scripts: []
          ]
        ]
        """)
        |> Igniter.compose_task(Component, [
          "component_alert",
          "--variant",
          "success,warning,danger",
          "--yes",
          "--no-deps"
        ])

      # The component file was generated
      component_created =
        igniter.rewrite.sources["lib/chelekom_it_web/components/component_alert.ex"]

      assert %Rewrite.Source{} = component_created, "the component was not generated"

      # Get the generated content
      source = igniter.rewrite.sources["lib/chelekom_it_web/components/component_alert.ex"]
      content = Rewrite.Source.get(source, :content)

      # Verify the module structure
      assert String.contains?(content, "defmodule ChelekomItWeb.Components.ComponentAlert do")
      assert String.contains?(content, "alias Phoenix.LiveView.JS")

      # Verify the alert function
      assert String.contains?(content, "def alert(assigns) do")

      # Verify HTML structure
      assert String.contains?(content, ~s(role="alert"))
      assert String.contains?(content, "alert-\#{@variant}")

      # Verify dismissible functionality
      assert String.contains?(content, "if @dismissible do")
      assert String.contains?(content, "JS.hide")
      assert String.contains?(content, "&times;")

      # Verify the variants were properly injected
      assert String.contains?(content, ~s(values: ["success", "warning", "danger"]))
    end

    test "generates modal component with necessary dependencies" do
      modal_template = """
      defmodule <%= @module %> do
        use Phoenix.Component
        alias Phoenix.LiveView.JS

        @doc \"\"\"
        Modal component
        \"\"\"
        attr :id, :string, required: true
        attr :show, :boolean, default: false
        attr :size, :string, default: "md", values: <%= inspect(@size || ["md"]) %>
        slot :inner_block, required: true

        def modal(assigns) do
          ~H\"\"\"
          <div
            id={@id}
            phx-mounted={@show && show_modal(@id)}
            class="modal-container"
            data-size={@size}
          >
            <div class="modal-backdrop" phx-click={hide_modal(@id)}></div>
            <div class="modal-content modal-\#{@size}">
              {render_slot(@inner_block)}
            </div>
          </div>
          \"\"\"
        end

        def show_modal(id) do
          JS.show(to: "#\#{id}")
          |> JS.add_class("modal-open", to: "body")
        end

        def hide_modal(id) do
          JS.hide(to: "#\#{id}")
          |> JS.remove_class("modal-open", to: "body")
        end
      end
      """

      igniter =
        project()
        |> host_template(
          "component_modal.eex",
          modal_template
        )
        |> host_template("component_modal.exs", """
        [
          component_modal: [
            name: "component_modal",
            args: [
              size: ["sm", "md", "lg", "xl", "full"]
            ],
            necessary: [],
            optional: ["component_button"],
            scripts: []
          ]
        ]
        """)
        |> Igniter.compose_task(Component, [
          "component_modal",
          "--size",
          "sm,md,lg",
          "--yes",
          "--no-deps"
        ])

      # The component file was generated
      component_created =
        igniter.rewrite.sources["lib/chelekom_it_web/components/component_modal.ex"]

      assert %Rewrite.Source{} = component_created, "the component was not generated"

      # Get the generated content
      source = igniter.rewrite.sources["lib/chelekom_it_web/components/component_modal.ex"]
      content = Rewrite.Source.get(source, :content)

      # Verify the module structure
      assert String.contains?(content, "defmodule ChelekomItWeb.Components.ComponentModal do")

      # Verify helper functions
      assert String.contains?(content, "def show_modal(id)")
      assert String.contains?(content, "def hide_modal(id)")

      # Verify JS interactions
      assert String.contains?(content, "JS.show")
      assert String.contains?(content, "JS.hide")
      assert String.contains?(content, "JS.add_class")
      assert String.contains?(content, "JS.remove_class")

      # Verify HTML structure
      assert String.contains?(content, "modal-container")
      assert String.contains?(content, "modal-backdrop")
      assert String.contains?(content, "modal-content")

      # Verify size variants
      assert String.contains?(content, ~s(values: ["sm", "md", "lg"]))
      assert String.contains?(content, "modal-\#{@size}")
    end

    test "generates form input component with validation states" do
      input_template = """
      defmodule <%= @module %> do
        use Phoenix.Component
        import Phoenix.HTML.Form

        @doc \"\"\"
        Form input component
        \"\"\"
        attr :id, :string, default: nil
        attr :name, :string, required: true
        attr :label, :string, default: nil
        attr :type, :string, default: "text", values: <%= inspect(@type || ["text"]) %>
        attr :value, :string, default: nil
        attr :error, :list, default: []
        attr :rest, :global, include: ~w(placeholder required disabled)

        def input(assigns) do
          ~H\"\"\"
          <div class="form-field">
            <%%= if @label do %>
              <label for={@id || @name} class="form-label">
                <%%= @label %>
              </label>
            <%% end %>
            <input
              id={@id || @name}
              name={@name}
              type={@type}
              value={@value}
              class={[
                "form-input",
                @error != [] && "form-input-error"
              ]}
              {@rest}
            />
            <%%= if @error != [] do %>
              <span class="form-error">
                <%%= Enum.join(@error, ", ") %>
              </span>
            <%% end %>
          </div>
          \"\"\"
        end
      end
      """

      igniter =
        project()
        |> host_template(
          "component_input.eex",
          input_template
        )
        |> host_template("component_input.exs", """
        [
          component_input: [
            name: "component_input",
            args: [
              type: ["text", "email", "password", "number", "tel", "url", "search"]
            ],
            necessary: [],
            optional: [],
            scripts: []
          ]
        ]
        """)
        |> Igniter.compose_task(Component, [
          "component_input",
          "--type",
          "text,email,password",
          "--yes",
          "--no-deps"
        ])

      # The component file was generated
      component_created =
        igniter.rewrite.sources["lib/chelekom_it_web/components/component_input.ex"]

      assert %Rewrite.Source{} = component_created, "the component was not generated"

      # Get the generated content
      source = igniter.rewrite.sources["lib/chelekom_it_web/components/component_input.ex"]
      content = Rewrite.Source.get(source, :content)

      # Verify imports
      assert String.contains?(content, "import Phoenix.HTML.Form")

      # Verify the input function
      assert String.contains?(content, "def input(assigns) do")

      # Verify HTML structure
      assert String.contains?(content, "form-field")
      assert String.contains?(content, "form-label")
      assert String.contains?(content, "form-input")

      # Verify error handling
      assert String.contains?(content, "@error != []")
      assert String.contains?(content, "form-input-error")
      assert String.contains?(content, "form-error")
      assert String.contains?(content, "Enum.join(@error")

      # Verify type variants
      assert String.contains?(content, ~s(values: ["text", "email", "password"]))
    end

    test "generates component with filtered colors from config" do
      # Create a config file with specific colors
      config_content = """
      import Config

      config :mishka_chelekom,
        component_colors: ["base", "danger"]
      """

      # Create a button component template
      button_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :color, :string, default: "base", values: <%= inspect(@color || ["base", "primary", "secondary", "danger", "warning", "success"]) %>
        attr :class, :any, default: ""
        attr :rest, :global
        slot :inner_block, required: true

        def button(assigns) do
          ~H\"\"\"
          <button class={["btn", "btn-\#{@color}", @class]} {@rest}>
            {render_slot(@inner_block)}
          </button>
          \"\"\"
        end
      end
      """

      button_config = """
      [
        component_button: [
          name: "component_button",
          args: [
            color: ["base", "primary", "secondary", "danger", "warning", "success"]
          ],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", config_content)
        |> host_template(
          "component_button.eex",
          button_template
        )
        |> host_template(
          "component_button.exs",
          button_config
        )
        |> Igniter.compose_task(Component, ["component_button", "--yes"])

      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/component_button.ex"
             ),
             "the component was not generated"

      # Get the generated content
      source = igniter.rewrite.sources["lib/chelekom_it_web/components/component_button.ex"]
      content = Rewrite.Source.get(source, :content)

      # Verify that only the configured colors are present
      assert String.contains?(content, ~s(values: ["base", "danger"]))

      # Verify that other colors are NOT present in the values list
      refute String.contains?(
               content,
               ~s(values: ["base", "primary", "secondary", "danger", "warning", "success"])
             )

      # Verify the component structure is still correct
      assert String.contains?(content, "defmodule ChelekomItWeb.Components.ComponentButton do")
      assert String.contains?(content, "use Phoenix.Component")
      assert String.contains?(content, "def button(assigns) do")
      assert String.contains?(content, "btn-\#{@color}")
    end

    test "generates component with component_prefix from config" do
      # Create a config file with component_prefix
      config_content = """
      import Config

      config :mishka_chelekom,
        component_prefix: "mishka_"
      """

      # Create a simple button component template
      button_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        attr :rest, :global
        slot :inner_block, required: true

        def <%= @component_prefix %>button(assigns) do
          ~H\"\"\"
          <button class={[@class]} {@rest}>
            {render_slot(@inner_block)}
          </button>
          \"\"\"
        end
      end
      """

      button_config = """
      [
        component_button: [
          name: "component_button",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", config_content)
        |> host_template(
          "component_button.eex",
          button_template
        )
        |> host_template(
          "component_button.exs",
          button_config
        )
        |> Igniter.compose_task(Component, ["component_button", "--yes"])

      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/component_button.ex"
             ),
             "the component was not generated"

      # Get the generated content
      source = igniter.rewrite.sources["lib/chelekom_it_web/components/component_button.ex"]
      content = Rewrite.Source.get(source, :content)

      # Verify that the prefix was applied
      assert String.contains?(content, "def mishka_button(assigns) do")

      # Verify that unprefixed function doesn't exist
      refute String.contains?(content, "def button(assigns) do")
    end

    test "generates component with component_prefix from CLI overriding config" do
      # Create a config file with component_prefix
      config_content = """
      import Config

      config :mishka_chelekom,
        component_prefix: "config_prefix_"
      """

      # Create a simple button component template
      button_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        attr :rest, :global
        slot :inner_block, required: true

        def <%= @component_prefix %>button(assigns) do
          ~H\"\"\"
          <button class={[@class]} {@rest}>
            {render_slot(@inner_block)}
          </button>
          \"\"\"
        end
      end
      """

      button_config = """
      [
        component_button: [
          name: "component_button",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task with CLI prefix (should override config)
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", config_content)
        |> host_template(
          "component_button.eex",
          button_template
        )
        |> host_template(
          "component_button.exs",
          button_config
        )
        |> Igniter.compose_task(Component, [
          "component_button",
          "--component-prefix",
          "cli_prefix_",
          "--yes"
        ])

      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/component_button.ex"
             ),
             "the component was not generated"

      # Get the generated content
      source = igniter.rewrite.sources["lib/chelekom_it_web/components/component_button.ex"]
      content = Rewrite.Source.get(source, :content)

      # Verify that the CLI prefix was applied (not the config prefix)
      assert String.contains?(content, "def cli_prefix_button(assigns) do")

      # Verify that config prefix was NOT applied
      refute String.contains?(content, "def config_prefix_button(assigns) do")

      # Verify that unprefixed function doesn't exist
      refute String.contains?(content, "def button(assigns) do")
    end

    test "updates config.exs when component_prefix provided in CLI (not sub mode)" do
      # Create a simple button component template
      button_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        slot :inner_block, required: true

        def <%= @component_prefix %>button(assigns) do
          ~H\"\"\"
          <button class={[@class]}>
            {render_slot(@inner_block)}
          </button>
          \"\"\"
        end
      end
      """

      button_config = """
      [
        component_button: [
          name: "component_button",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Create existing config with nil prefix
      existing_config = """
      import Config

      config :mishka_chelekom,
        component_prefix: nil
      """

      # Run the task with CLI prefix
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", existing_config)
        |> host_template(
          "component_button.eex",
          button_template
        )
        |> host_template(
          "component_button.exs",
          button_config
        )
        |> Igniter.compose_task(Component, [
          "component_button",
          "--component-prefix",
          "my_prefix_",
          "--yes"
        ])

      # Verify config was updated
      config_source = igniter.rewrite.sources["priv/mishka_chelekom/config.exs"]
      assert %Rewrite.Source{} = config_source
      config_content = Rewrite.Source.get(config_source, :content)

      # Should have the new prefix
      assert String.contains?(config_content, ~s(component_prefix: "my_prefix_"))
      # Should NOT have nil anymore
      refute String.contains?(config_content, "component_prefix: nil")
    end

    test "does NOT update config.exs when in sub mode (batch generation)" do
      # Create a simple button component template
      button_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        slot :inner_block, required: true

        def <%= @component_prefix %>button(assigns) do
          ~H\"\"\"
          <button class={[@class]}>
            {render_slot(@inner_block)}
          </button>
          \"\"\"
        end
      end
      """

      button_config = """
      [
        component_button: [
          name: "component_button",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Create existing config with nil prefix
      existing_config = """
      import Config

      config :mishka_chelekom,
        component_prefix: nil
      """

      # Run the task with --sub flag (simulating batch generation)
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", existing_config)
        |> host_template(
          "component_button.eex",
          button_template
        )
        |> host_template(
          "component_button.exs",
          button_config
        )
        |> Igniter.compose_task(Component, [
          "component_button",
          "--component-prefix",
          "my_prefix_",
          "--sub",
          "--yes"
        ])

      # Verify config was NOT updated (still has nil)
      config_source = igniter.rewrite.sources["priv/mishka_chelekom/config.exs"]
      assert %Rewrite.Source{} = config_source
      config_content = Rewrite.Source.get(config_source, :content)

      # Should still have nil (not updated in sub mode)
      assert String.contains?(config_content, "component_prefix: nil")
      # Should NOT have the new prefix
      refute String.contains?(config_content, ~s(component_prefix: "my_prefix_"))
    end

    test "generates component with module_prefix from config (prefixed file and module name)" do
      # Create a config file with module_prefix
      config_content = """
      import Config

      config :mishka_chelekom,
        module_prefix: "mishka_"
      """

      # Create a simple chat component template
      chat_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        attr :rest, :global
        slot :inner_block, required: true

        def <%= @component_prefix %>chat(assigns) do
          ~H\"\"\"
          <div class={["chat", @class]} {@rest}>
            {render_slot(@inner_block)}
          </div>
          \"\"\"
        end
      end
      """

      chat_config = """
      [
        component_chat: [
          name: "component_chat",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", config_content)
        |> host_template(
          "component_chat.eex",
          chat_template
        )
        |> host_template(
          "component_chat.exs",
          chat_config
        )
        |> Igniter.compose_task(Component, ["component_chat", "--yes"])

      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/mishka_component_chat.ex"
             ),
             "the component was not generated"

      # Get the generated content
      source =
        igniter.rewrite.sources["lib/chelekom_it_web/components/mishka_component_chat.ex"]

      content = Rewrite.Source.get(source, :content)

      # Verify the module name has the prefix (MishkaComponentChat)
      assert String.contains?(
               content,
               "defmodule ChelekomItWeb.Components.MishkaComponentChat do"
             )

      assert String.contains?(content, "use Phoenix.Component")
      assert String.contains?(content, "def chat(assigns) do")
    end

    test "generates component with module_prefix from CLI (prefixed file and module name)" do
      # Create a simple chat component template
      chat_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        attr :rest, :global
        slot :inner_block, required: true

        def <%= @component_prefix %>chat(assigns) do
          ~H\"\"\"
          <div class={["chat", @class]} {@rest}>
            {render_slot(@inner_block)}
          </div>
          \"\"\"
        end
      end
      """

      chat_config = """
      [
        component_chat: [
          name: "component_chat",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task with CLI module_prefix
      igniter =
        project()
        |> host_template(
          "component_chat.eex",
          chat_template
        )
        |> host_template(
          "component_chat.exs",
          chat_config
        )
        |> Igniter.compose_task(Component, [
          "component_chat",
          "--module-prefix",
          "custom_",
          "--yes"
        ])

      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/custom_component_chat.ex"
             ),
             "the component was not generated"

      # Get the generated content
      source =
        igniter.rewrite.sources["lib/chelekom_it_web/components/custom_component_chat.ex"]

      content = Rewrite.Source.get(source, :content)

      # Verify the module name has the prefix (CustomComponentChat)
      assert String.contains?(
               content,
               "defmodule ChelekomItWeb.Components.CustomComponentChat do"
             )
    end

    test "CLI module_prefix overrides config module_prefix" do
      # Create a config file with module_prefix
      config_content = """
      import Config

      config :mishka_chelekom,
        module_prefix: "config_"
      """

      # Create a simple chat component template
      chat_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        slot :inner_block, required: true

        def chat(assigns) do
          ~H\"\"\"
          <div class={["chat", @class]}>
            {render_slot(@inner_block)}
          </div>
          \"\"\"
        end
      end
      """

      chat_config = """
      [
        component_chat: [
          name: "component_chat",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task with CLI module_prefix (should override config)
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", config_content)
        |> host_template(
          "component_chat.eex",
          chat_template
        )
        |> host_template(
          "component_chat.exs",
          chat_config
        )
        |> Igniter.compose_task(Component, [
          "component_chat",
          "--module-prefix",
          "cli_",
          "--yes"
        ])

      # The CLI prefix wins over the config prefix
      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/cli_component_chat.ex"
             ),
             "the component was not generated"

      refute Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/config_component_chat.ex"
             )

      source =
        igniter.rewrite.sources["lib/chelekom_it_web/components/cli_component_chat.ex"]

      content = Rewrite.Source.get(source, :content)

      # Verify the CLI prefix was applied (not the config prefix)
      assert String.contains?(
               content,
               "defmodule ChelekomItWeb.Components.CliComponentChat do"
             )

      refute String.contains?(content, "ConfigComponentChat")
    end

    test "updates config.exs when module_prefix provided in CLI (not sub mode)" do
      # Create a simple chat component template
      chat_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        slot :inner_block, required: true

        def chat(assigns) do
          ~H\"\"\"
          <div class={["chat", @class]}>
            {render_slot(@inner_block)}
          </div>
          \"\"\"
        end
      end
      """

      chat_config = """
      [
        component_chat: [
          name: "component_chat",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Create existing config with nil module_prefix
      existing_config = """
      import Config

      config :mishka_chelekom,
        module_prefix: nil
      """

      # Run the task with CLI module_prefix
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", existing_config)
        |> host_template(
          "component_chat.eex",
          chat_template
        )
        |> host_template(
          "component_chat.exs",
          chat_config
        )
        |> Igniter.compose_task(Component, [
          "component_chat",
          "--module-prefix",
          "my_module_",
          "--yes"
        ])

      # Verify config was updated
      config_source = igniter.rewrite.sources["priv/mishka_chelekom/config.exs"]
      assert %Rewrite.Source{} = config_source
      config_content = Rewrite.Source.get(config_source, :content)

      # Should have the new module_prefix
      assert String.contains?(config_content, ~s(module_prefix: "my_module_"))
      # Should NOT have nil anymore
      refute String.contains?(config_content, "module_prefix: nil")
    end

    test "does NOT update config.exs module_prefix when in sub mode (batch generation)" do
      # Create a simple chat component template
      chat_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        slot :inner_block, required: true

        def chat(assigns) do
          ~H\"\"\"
          <div class={["chat", @class]}>
            {render_slot(@inner_block)}
          </div>
          \"\"\"
        end
      end
      """

      chat_config = """
      [
        component_chat: [
          name: "component_chat",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Create existing config with nil module_prefix
      existing_config = """
      import Config

      config :mishka_chelekom,
        module_prefix: nil
      """

      # Run the task with --sub flag (simulating batch generation)
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", existing_config)
        |> host_template(
          "component_chat.eex",
          chat_template
        )
        |> host_template(
          "component_chat.exs",
          chat_config
        )
        |> Igniter.compose_task(Component, [
          "component_chat",
          "--module-prefix",
          "my_module_",
          "--sub",
          "--yes"
        ])

      # Verify config was NOT updated (still has nil)
      config_source = igniter.rewrite.sources["priv/mishka_chelekom/config.exs"]
      assert %Rewrite.Source{} = config_source
      config_content = Rewrite.Source.get(config_source, :content)

      # Should still have nil (not updated in sub mode)
      assert String.contains?(config_content, "module_prefix: nil")
      # Should NOT have the new module_prefix
      refute String.contains?(config_content, ~s(module_prefix: "my_module_"))
    end

    test "generates component with both module_prefix and component_prefix" do
      # Create a config file with both prefixes
      config_content = """
      import Config

      config :mishka_chelekom,
        module_prefix: "mishka_",
        component_prefix: "mc_"
      """

      # Create a simple chat component template that uses component_prefix for function name
      chat_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        attr :rest, :global
        slot :inner_block, required: true

        def <%= @component_prefix %>chat(assigns) do
          ~H\"\"\"
          <div class={["chat", @class]} {@rest}>
            {render_slot(@inner_block)}
          </div>
          \"\"\"
        end
      end
      """

      chat_config = """
      [
        component_chat: [
          name: "component_chat",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", config_content)
        |> host_template(
          "component_chat.eex",
          chat_template
        )
        |> host_template(
          "component_chat.exs",
          chat_config
        )
        |> Igniter.compose_task(Component, ["component_chat", "--yes"])

      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/mishka_component_chat.ex"
             ),
             "the component was not generated"

      # Get the generated content
      source =
        igniter.rewrite.sources["lib/chelekom_it_web/components/mishka_component_chat.ex"]

      content = Rewrite.Source.get(source, :content)

      # Verify the module name has the module_prefix (MishkaComponentChat)
      assert String.contains?(
               content,
               "defmodule ChelekomItWeb.Components.MishkaComponentChat do"
             )

      # Verify the function name has the component_prefix (mc_chat)
      assert String.contains?(content, "def mc_chat(assigns) do")

      # Verify unprefixed function doesn't exist
      refute String.contains?(content, "def chat(assigns) do")
    end

    test "generates component with module_prefix_camel in import statements" do
      # Create a config file with module_prefix
      config_content = """
      import Config

      config :mishka_chelekom,
        module_prefix: "mishka_"
      """

      # Create a button component template that imports Icon
      button_template = """
      defmodule <%= @module %> do
        use Phoenix.Component
        import <%= inspect(@web_module) %>.Components.<%= @module_prefix_camel %>Icon, only: [icon: 1]

        attr :class, :any, default: ""
        attr :rest, :global
        slot :inner_block, required: true

        def button(assigns) do
          ~H\"\"\"
          <button class={["btn", @class]} {@rest}>
            {render_slot(@inner_block)}
          </button>
          \"\"\"
        end
      end
      """

      button_config = """
      [
        component_button: [
          name: "component_button",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", config_content)
        |> host_template(
          "component_button.eex",
          button_template
        )
        |> host_template(
          "component_button.exs",
          button_config
        )
        |> Igniter.compose_task(Component, ["component_button", "--yes"])

      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/mishka_component_button.ex"
             ),
             "the component was not generated"

      # Get the generated content
      source =
        igniter.rewrite.sources["lib/chelekom_it_web/components/mishka_component_button.ex"]

      content = Rewrite.Source.get(source, :content)

      # Verify the module name has the prefix (MishkaComponentButton)
      assert String.contains?(
               content,
               "defmodule ChelekomItWeb.Components.MishkaComponentButton do"
             )

      # Verify the import statement has the camelized prefix (MishkaIcon)
      assert String.contains?(
               content,
               "import ChelekomItWeb.Components.MishkaIcon"
             )

      # Verify it does NOT have unprefixed import
      refute String.contains?(
               content,
               "import ChelekomItWeb.Components.Icon,"
             )
    end

    test "generates component with empty module_prefix_camel when no prefix" do
      # Create a button component template that imports Icon (no prefix)
      button_template = """
      defmodule <%= @module %> do
        use Phoenix.Component
        import <%= inspect(@web_module) %>.Components.<%= @module_prefix_camel %>Icon, only: [icon: 1]

        attr :class, :any, default: ""
        slot :inner_block, required: true

        def button(assigns) do
          ~H\"\"\"
          <button class={["btn", @class]}>
            {render_slot(@inner_block)}
          </button>
          \"\"\"
        end
      end
      """

      button_config = """
      [
        component_button: [
          name: "component_button",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Run the task without module_prefix
      igniter =
        project()
        |> host_template(
          "component_button.eex",
          button_template
        )
        |> host_template(
          "component_button.exs",
          button_config
        )
        |> Igniter.compose_task(Component, ["component_button", "--yes"])

      assert Map.has_key?(
               igniter.rewrite.sources,
               "lib/chelekom_it_web/components/component_button.ex"
             ),
             "the component was not generated"

      # Get the generated content
      source =
        igniter.rewrite.sources["lib/chelekom_it_web/components/component_button.ex"]

      content = Rewrite.Source.get(source, :content)

      # Verify the module name has no prefix
      assert String.contains?(
               content,
               "defmodule ChelekomItWeb.Components.ComponentButton do"
             )

      # Verify the import statement has no prefix (just Icon)
      assert String.contains?(
               content,
               "import ChelekomItWeb.Components.Icon"
             )

      # Verify it does NOT have prefixed import
      refute String.contains?(content, "MishkaIcon")
    end

    test "does NOT save prefix to config when --no-save is used" do
      # Create a simple chat component template
      chat_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        slot :inner_block, required: true

        def chat(assigns) do
          ~H\"\"\"
          <div class={["chat", @class]}>
            {render_slot(@inner_block)}
          </div>
          \"\"\"
        end
      end
      """

      chat_config = """
      [
        component_chat: [
          name: "component_chat",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Create existing config with nil prefixes
      existing_config = """
      import Config

      config :mishka_chelekom,
        component_prefix: nil,
        module_prefix: nil
      """

      # Run the task with --no-save flag
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", existing_config)
        |> host_template(
          "component_chat.eex",
          chat_template
        )
        |> host_template(
          "component_chat.exs",
          chat_config
        )
        |> Igniter.compose_task(Component, [
          "component_chat",
          "--module-prefix",
          "mishka_",
          "--component-prefix",
          "mc_",
          "--no-save",
          "--yes"
        ])

      # Verify config was NOT updated (still has nil)
      config_source = igniter.rewrite.sources["priv/mishka_chelekom/config.exs"]
      assert %Rewrite.Source{} = config_source
      config_content = Rewrite.Source.get(config_source, :content)

      # Should still have nil (not updated due to --no-save)
      assert String.contains?(config_content, "component_prefix: nil")
      assert String.contains?(config_content, "module_prefix: nil")

      # Should NOT have the new prefixes saved
      refute String.contains?(config_content, ~s(component_prefix: "mc_"))
      refute String.contains?(config_content, ~s(module_prefix: "mishka_"))
    end

    test "saves prefix to config when --no-save is NOT used" do
      # Create a simple chat component template
      chat_template = """
      defmodule <%= @module %> do
        use Phoenix.Component

        attr :class, :any, default: ""
        slot :inner_block, required: true

        def chat(assigns) do
          ~H\"\"\"
          <div class={["chat", @class]}>
            {render_slot(@inner_block)}
          </div>
          \"\"\"
        end
      end
      """

      chat_config = """
      [
        component_chat: [
          name: "component_chat",
          args: [],
          optional: [],
          necessary: []
        ]
      ]
      """

      # Create existing config with nil prefixes
      existing_config = """
      import Config

      config :mishka_chelekom,
        component_prefix: nil,
        module_prefix: nil
      """

      # Run the task WITHOUT --no-save flag
      igniter =
        project()
        |> Igniter.create_new_file("priv/mishka_chelekom/config.exs", existing_config)
        |> host_template(
          "component_chat.eex",
          chat_template
        )
        |> host_template(
          "component_chat.exs",
          chat_config
        )
        |> Igniter.compose_task(Component, [
          "component_chat",
          "--module-prefix",
          "mishka_",
          "--component-prefix",
          "mc_",
          "--yes"
        ])

      # Verify config WAS updated
      config_source = igniter.rewrite.sources["priv/mishka_chelekom/config.exs"]
      assert %Rewrite.Source{} = config_source
      config_content = Rewrite.Source.get(config_source, :content)

      # Should have the new prefixes saved
      assert String.contains?(config_content, ~s(component_prefix: "mc_"))
      assert String.contains?(config_content, ~s(module_prefix: "mishka_"))

      # Should NOT have nil anymore
      refute String.contains?(config_content, "component_prefix: nil")
      refute String.contains?(config_content, "module_prefix: nil")
    end
  end
end
