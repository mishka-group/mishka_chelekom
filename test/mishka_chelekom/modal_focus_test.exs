defmodule MishkaChelekom.ModalFocusTest do
  @moduledoc """
  Opening the styled modal moves keyboard focus into its dialog, and closing it gives focus back.

  The template is generated the way `mix mishka.ui.gen.component modal` writes it, every option
  on, compiled, and rendered. `show_modal/2` and `hide_modal/2` are `Phoenix.LiveView.JS` commands,
  and a command whose `to:` names an element the page does not have does nothing and says nothing:
  `show_modal/2` once focused `#<id>-content`, which the modal never rendered, so a keyboard user
  who opened it was left on the page behind it.
  """
  use ExUnit.Case, async: true

  alias Phoenix.LiveView.JS

  @template Application.app_dir(:mishka_chelekom, "priv/components/modal.eex")
  @id "probe"

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
      module: inspect(__MODULE__.Modal),
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

  defp page_source(modal) do
    """
    defmodule #{inspect(__MODULE__.Page)} do
      use Phoenix.Component
      import #{inspect(modal)}

      def page(assigns) do
        ~H\"\"\"
        <.modal id="#{@id}" title="Probe">
          <p>Body</p>
        </.modal>
        \"\"\"
      end
    end
    """
  end

  setup_all do
    [{modal, _bytecode}] = Code.compile_string(generated_source())
    [{page, _bytecode}] = Code.compile_string(page_source(modal))

    html =
      %{}
      |> page.page()
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    %{modal: modal, html: html}
  end

  defp ops(%JS{ops: ops}), do: for([kind, args] <- ops, do: {kind, args[:to]})

  defp position(list, kind), do: Enum.find_index(list, &match?({^kind, _to}, &1))

  test "every element the open and close commands name is in the rendered modal", context do
    %{modal: modal, html: html} = context

    missing =
      for {kind, "#" <> id} <- ops(modal.show_modal(@id)) ++ ops(modal.hide_modal(@id)),
          not String.contains?(html, ~s|id="#{id}"|),
          do: {kind, "#" <> id}

    assert missing == []
  end

  test "opening focuses the first focusable element inside the dialog", context do
    %{modal: modal, html: html} = context

    assert [to] = for({"focus_first", to} <- ops(modal.show_modal(@id)), do: to)
    "#" <> target = to

    [_before, dialog] = String.split(html, ~s|role="dialog"|, parts: 2)
    assert [_before, inside] = String.split(dialog, ~s|id="#{target}"|, parts: 2)
    assert inside =~ ~r/<button[^>]*aria-label="close"/
  end

  test "opening remembers the focused element and closing returns focus to it", %{modal: modal} do
    show = ops(modal.show_modal(@id))

    assert {"push_focus", ":focus"} in show
    assert position(show, "push_focus") < position(show, "focus_first")
    assert {"pop_focus", nil} in ops(modal.hide_modal(@id))
  end
end
