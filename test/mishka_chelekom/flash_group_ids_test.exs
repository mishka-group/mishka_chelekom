defmodule MishkaChelekom.FlashGroupIdsTest do
  @moduledoc """
  Two flash groups on one page have no id in common.

  `flash_group/1` draws four flashes: the page's info and error messages, and two for the LiveView
  connection, "We can't find the internet" and "Something went wrong!". The connection flashes were
  `id="client-error"` and `id="server-error"` whatever the group was called, the ids Phoenix's own
  layout gives its flash group, and the message flashes took an id from their variant and kind. So a
  group placed inside a page whose layout has one, as a page builder places it, or two groups on one
  page, put those ids in the document twice, and LiveView logged "Multiple IDs detected". Each
  flash now takes the group's own id as its prefix, and the commands that show and hide the
  connection flashes name the same ids.

  The template is generated the way `mix mishka.ui.gen.component alert` writes it, every option on,
  compiled, and rendered.
  """
  use ExUnit.Case, async: true

  @template Application.app_dir(:mishka_chelekom, "priv/components/alert.eex")

  defmodule Web.Components.Icon do
    @moduledoc false
    use Phoenix.Component

    def icon(assigns), do: ~H|<span class={[@name, @class]}></span>|
  end

  # The template as the generator writes it, every catalog option on (an option it is not given is
  # nil). The host's Gettext backend is not here, so the passthrough the runtime harness uses
  # stands in for it.
  defp generated_source do
    assigns = %{
      module: inspect(__MODULE__.Alert),
      web_module: __MODULE__.Web,
      module_prefix_camel: "",
      component_prefix: ""
    }

    tag = ~r/<%(?!%).*?%>/s

    tag
    |> Regex.replace(File.read!(@template), &Regex.replace(~r/@(\w+)/, &1, "assigns[:\\1]"))
    |> EEx.eval_string(assigns: assigns)
    |> String.replace(
      ~r/^\s*use Gettext, backend: .*$/m,
      "  import MishkaChelekom.Test.Runtime.GettextStub"
    )
  end

  # A layout's group under its default id, and a second group placed in the page.
  defp page_source(alert) do
    """
    defmodule #{inspect(__MODULE__.Page)} do
      use Phoenix.Component
      import #{inspect(alert)}

      def page(assigns) do
        ~H\"\"\"
        <div id="layout"><.flash_group flash={@flash} /></div>
        <main><.flash_group id="card" flash={@flash} /></main>
        \"\"\"
      end
    end
    """
  end

  setup_all do
    [{alert, _bytecode}] = Code.compile_string(generated_source())
    [{page, _bytecode}] = Code.compile_string(page_source(alert))

    html =
      %{flash: %{"info" => "Saved.", "error" => "Not saved."}}
      |> page.page()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    %{html: html}
  end

  defp ids(html), do: for([_match, id] <- Regex.scan(~r/\sid="([^"]+)"/, html), do: id)

  defp unescape(html) do
    Enum.reduce(
      [{"&quot;", "\""}, {"&#39;", "'"}, {"&lt;", "<"}, {"&gt;", ">"}, {"&amp;", "&"}],
      html,
      fn {entity, char}, acc -> String.replace(acc, entity, char) end
    )
  end

  # Every `#id` the connection flashes' `phx-connected` and `phx-disconnected` commands name.
  defp targets(html) do
    for [_match, value] <- Regex.scan(~r/\sphx-(?:dis)?connected="([^"]*)"/, html),
        [_hash, id] <- Regex.scan(~r/#([\w-]+)/, unescape(value)),
        do: id
  end

  test "the two groups draw every flash, so there is something to compare", %{html: html} do
    assert length(Regex.scan(~r/role="alert"/, html)) == 8
  end

  test "no id is in the page twice", %{html: html} do
    ids = ids(html)

    assert ids -- Enum.uniq(ids) == []
  end

  test "each flash is named after its own group", %{html: html} do
    ids = ids(html)

    for group <- ["flash-group", "card"],
        flash <- ["info", "error", "client-error", "server-error"] do
      assert "#{group}-#{flash}" in ids
    end

    refute "client-error" in ids
    refute "server-error" in ids
  end

  test "the connection commands show and hide their own group's flash", %{html: html} do
    targets = targets(html)

    assert "card-client-error" in targets
    assert "card-server-error" in targets

    assert Enum.uniq(targets) -- ids(html) == [],
           "a command names an element the page does not have"
  end
end
