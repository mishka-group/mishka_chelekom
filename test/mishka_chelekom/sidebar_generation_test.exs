defmodule MishkaChelekom.SidebarGenerationTest do
  @moduledoc """
  What the generator writes for the sidebar: the colours of the variants it is asked for.

  The template is generated the way `mix mishka.ui.gen.component sidebar` writes it, with the
  options the generator passes, compiled, and rendered. A variant whose clause the template leaves
  out still renders: the catch-all clause of `color_variant/2` returns the variant's name as a
  class, so the sidebar loses its colours and nothing fails.
  """
  use ExUnit.Case, async: true

  @template Application.app_dir(:mishka_chelekom, "priv/components/sidebar.eex")

  defmodule Web.Components.Icon do
    @moduledoc false
    use Phoenix.Component

    def icon(assigns), do: ~H|<span class={@name}></span>|
  end

  # The template as the generator writes it with `options` (an option it is not given is nil,
  # every value). The host's Gettext backend is not here, so the passthrough the runtime harness
  # uses stands in for it.
  defp generated_source(module, options) do
    assigns =
      Map.merge(
        %{
          module: inspect(module),
          web_module: __MODULE__.Web,
          module_prefix_camel: "",
          component_prefix: ""
        },
        options
      )

    tag = ~r/<%(?!%).*?%>/s

    tag
    |> Regex.replace(File.read!(@template), &Regex.replace(~r/@(\w+)/, &1, "assigns[:\\1]"))
    |> EEx.eval_string(assigns: assigns)
    |> String.replace(
      ~r/^\s*use Gettext, backend: .*$/m,
      "  import MishkaChelekom.Test.Runtime.GettextStub"
    )
  end

  # The classes of a sidebar with every default, from the module generated with `options`.
  defp default_classes(name, options) do
    module = Module.concat(__MODULE__, name)
    [{sidebar, _bytecode}] = Code.compile_string(generated_source(module, options))

    [{page, _bytecode}] =
      Code.compile_string("""
      defmodule #{inspect(Module.concat(module, Page))} do
        use Phoenix.Component
        import #{inspect(sidebar)}

        def page(assigns), do: ~H|<.sidebar id="probe">Content</.sidebar>|
      end
      """)

    html = %{} |> page.page() |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
    [_match, classes] = Regex.run(~r/<aside\s[^>]*\sclass="([^"]*)"/, html)
    String.split(classes)
  end

  test "generated for the base variant alone, the default sidebar has the base colours" do
    classes = default_classes(BaseOnly, %{variant: ["base"]})

    assert "bg-white" in classes
    refute "base" in classes
  end
end
