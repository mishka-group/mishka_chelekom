defmodule MishkaChelekom.Test.Runtime.KitModuleStubs do
  @moduledoc """
  Stub modules for kit-source helper modules that demo invocations
  reference via short-aliased calls (`Drawer.show_drawer`,
  `Modal.show_modal`, etc.).

  In a real Phoenix app that consumes chelekom, these modules are
  generated from `priv/components/<comp>.{exs,eex}` by `mix
  mishka.ui.gen.component`. Chelekom's repo doesn't carry compiled
  copies of them — they're code generators. The bundle JSON references
  these helpers in `phx-click={Drawer.show_drawer(…)}` style attrs,
  and the harness needs the module name to resolve at compile/eval time.

  These stubs exist only at test compile time. Each function returns a
  bare `Phoenix.LiveView.JS{}` so demos can splice them into HEEx attr
  values without crashing. The runtime CMS resolves these correctly
  because user-app installations DO have the generated modules; the
  vendored harness simulates the same surface area.
  """

  @doc false
  def make_modules! do
    for short <- [:Drawer, :Modal, :Sidebar, :Tabs] do
      module_name = Module.concat([short])
      define_stub_module(module_name)
    end
  end

  defp define_stub_module(mod) do
    if not :erlang.module_loaded(mod) do
      ast =
        quote do
          defmodule unquote(mod) do
            def show_drawer(_id, _position \\ "left"), do: %Phoenix.LiveView.JS{}
            def hide_drawer(_id, _position \\ "left"), do: %Phoenix.LiveView.JS{}
            def show_modal(_id), do: %Phoenix.LiveView.JS{}
            def hide_modal(_id), do: %Phoenix.LiveView.JS{}
            def show_sidebar(_id, _position \\ "left"), do: %Phoenix.LiveView.JS{}
            def hide_sidebar(_id, _position \\ "left"), do: %Phoenix.LiveView.JS{}
            def show_tab(_tab_id, _container_id), do: %Phoenix.LiveView.JS{}
            def hide_tab(_tab_id), do: %Phoenix.LiveView.JS{}
          end
        end

      # Ensure JS is loaded before stub modules try to embed `%JS{}`.
      Code.ensure_loaded!(Phoenix.LiveView.JS)
      Code.compile_quoted(ast)
    end

    :ok
  end
end
