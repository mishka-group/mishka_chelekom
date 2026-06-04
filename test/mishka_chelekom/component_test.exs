defmodule MishkaChelekom.ComponentTest.Comps do
  @moduledoc false
  use MishkaChelekom.Component

  component :tbtn,
    tag: :button,
    base: "px-2",
    variants: [
      color: [primary: "bg-primary", ghost: "bg-transparent"],
      size: [sm: "h-8", md: "h-9"]
    ],
    defaults: [color: :primary, size: :md]

  component :tdialog,
    headless: true,
    hook: "FocusTrap",
    parts: [
      trigger: [tag: :button, slot: true, aria: [haspopup: "dialog"]],
      popup: [
        tag: :div,
        role: "dialog",
        state: true,
        aria: [modal: "true", labelledby: {:ref, :title}],
        children: [
          title: [tag: :h2, id: true, slot: true],
          content: [tag: :div, slot: :inner_block]
        ]
      ]
    ]
end

defmodule MishkaChelekom.ComponentTest.Overrides do
  @moduledoc false
  use MishkaChelekom.Overrides
  override :tbtn, :root, "rounded-full"
end

defmodule MishkaChelekom.ComponentTest.Page do
  @moduledoc false
  use Phoenix.Component
  import MishkaChelekom.ComponentTest.Comps

  def btn(assigns), do: ~H"<.tbtn color={@color} size={@size} class={@class}>X</.tbtn>"

  def dialog(assigns) do
    ~H"""
    <.tdialog id="d" open={@open}>
      <:trigger>T</:trigger>
      <:title>Ti</:title>
      Body
    </.tdialog>
    """
  end
end

defmodule MishkaChelekom.ComponentTest do
  use ExUnit.Case, async: false

  alias MishkaChelekom.ComponentTest.Page

  defp render(fun, assigns) do
    Page
    |> apply(fun, [Map.put(assigns, :__changed__, nil)])
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  describe "styled" do
    test "variants resolve to their classes" do
      html = render(:btn, %{color: :ghost, size: :sm, class: nil})
      assert html =~ "<button"
      assert html =~ "bg-transparent"
      assert html =~ "h-8"
      refute html =~ "bg-primary"
    end

    test "overrides apply app-wide and the caller's class still wins" do
      Application.put_env(:mishka_chelekom, :overrides, [MishkaChelekom.ComponentTest.Overrides])
      on_exit(fn -> Application.delete_env(:mishka_chelekom, :overrides) end)

      html = render(:btn, %{color: :primary, size: :md, class: "px-6"})
      assert html =~ "rounded-full"
      assert html =~ "px-6"
    end

    test "a bad default variant fails at compile time" do
      code = """
      defmodule MishkaChelekom.ComponentTest.Bad do
        use MishkaChelekom.Component
        component :x, variants: [c: [a: "y"]], defaults: [c: :nope]
      end
      """

      assert_raise CompileError, ~r/default c=:nope/, fn -> Code.compile_string(code) end
    end
  end

  describe "headless" do
    test "emits hook, ARIA, data-part, state and resolves slots" do
      html = render(:dialog, %{open: true})

      assert html =~ ~s|phx-hook="FocusTrap"|
      assert html =~ ~s|role="dialog"|
      assert html =~ ~s|aria-modal="true"|
      assert html =~ ~s|aria-haspopup="dialog"|
      assert html =~ ~s|data-part="trigger"|
      assert html =~ ~s|data-part="popup"|
      assert html =~ ~s|class="chelekom-tdialog__title"|
      # id wiring: popup aria-labelledby points at the title id
      assert html =~ ~s|id="d-title"|
      assert html =~ ~s|aria-labelledby="d-title"|
      assert html =~ "data-open"
      assert html =~ "Body"
      assert html =~ "T</button>"
    end

    test "closed state uses data-closed, not data-open" do
      html = render(:dialog, %{open: false})
      assert html =~ "data-closed"
      refute html =~ "data-open"
    end
  end
end
