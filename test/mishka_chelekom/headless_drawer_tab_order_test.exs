defmodule MishkaChelekom.HeadlessDrawerTabOrderTest do
  @moduledoc """
  A headless drawer rendered closed is out of the Tab order before its hook has mounted.

  The closed popup is only translated off-screen, so it stays rendered and its controls stay
  focusable unless the popup is inert. The `Drawer` hook toggles `inert` as it opens and closes
  (`priv/assets/js/drawer.test.mjs`); the template has to render the same state, for the page
  before the hook mounts and for every patch after it.
  """
  use ExUnit.Case, async: true

  @template Application.app_dir(:mishka_chelekom, "priv/headless/drawer.eex")

  defp generated_source do
    assigns = %{module: inspect(__MODULE__.Drawer), component_prefix: ""}
    tag = ~r/<%(?!%).*?%>/s

    tag
    |> Regex.replace(File.read!(@template), &Regex.replace(~r/@(\w+)/, &1, "assigns[:\\1]"))
    |> EEx.eval_string(assigns: assigns)
  end

  defp page_source(drawer) do
    """
    defmodule #{inspect(__MODULE__.Page)} do
      use Phoenix.Component
      import #{inspect(drawer)}

      def page(assigns) do
        ~H\"\"\"
        <.drawer id="hd" open={@open}>
          <:trigger>Open</:trigger>
          <input name="probe" />
        </.drawer>
        \"\"\"
      end
    end
    """
  end

  setup_all do
    [{drawer, _bytecode}] = Code.compile_string(generated_source())
    [{page, _bytecode}] = Code.compile_string(page_source(drawer))

    popup = fn open ->
      html =
        %{open: open}
        |> page.page()
        |> Phoenix.HTML.Safe.to_iodata()
        |> IO.iodata_to_binary()

      [tag] = Regex.run(~r/<div\s[^>]*data-part="popup"[^>]*>/, html)
      tag
    end

    %{popup: popup}
  end

  test "a closed popup is inert", %{popup: popup} do
    assert popup.(false) =~ ~r/\sinert[\s>]/
  end

  test "an open popup is not", %{popup: popup} do
    refute popup.(true) =~ ~r/\sinert[\s>=]/
  end
end
