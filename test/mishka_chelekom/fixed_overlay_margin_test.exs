defmodule MishkaChelekom.FixedOverlayMarginTest do
  @moduledoc """
  A styled component whose root is `position: fixed` resets its margin with `m-0`.

  Tailwind v4 writes `space-y-4` as `:where(.space-y-4 > :not(:last-child))`, a `margin-block-end`
  with no specificity. A fixed root inside such a wrapper takes that margin: a drawer closed at the
  bottom of the screen (`fixed bottom-0 translate-y-full`) is lifted 16px and shows its top edge.
  A plain `.m-0` outranks the `:where()` rule, and v4 writes `m-0` before `mx-*`, `ml-*` and
  `mr-*`, so a root that sets one side keeps it.

  Each template is generated the way `mix mishka.ui.gen.component` writes it, with every option on,
  compiled, and rendered; the classes of the root it renders are what the test reads. An in-flow
  root (a static or sticky dock, a toast inside a toast group) keeps the margin its wrapper gives
  it.
  """
  use ExUnit.Case, async: true

  @components Application.app_dir(:mishka_chelekom, "priv/components")

  defmodule Web.Components.Icon do
    @moduledoc false
    use Phoenix.Component

    def icon(assigns), do: ~H|<span class={@name}></span>|
  end

  # `{component, label, markup, classes the root has, classes it does not have}`.
  @cases [
    for position <- ~w(left right top bottom) do
      {"drawer", "a #{position} drawer",
       ~s|<.drawer id="d" position="#{position}">Body</.drawer>|, ~w(fixed m-0), []}
    end,
    for hide <- ["left", "right", nil] do
      {"sidebar", "a sidebar that hides #{inspect(hide)}",
       ~s|<.sidebar id="s" hide_position={#{inspect(hide)}}>Body</.sidebar>|, ~w(fixed m-0), []}
    end,
    for {position, margin} <-
          [
            {"top_left", ["ml-2"]},
            {"top_right", []},
            {"bottom_left", ["ml-2"]},
            {"bottom_right", []},
            {"center", ["mx-auto"]},
            {"full", []}
          ],
        vertical <- ~w(top bottom) do
      {"banner", "a #{vertical} banner at #{position}",
       ~s|<.banner id="b" position="#{position}" position_size="small" vertical_position="#{vertical}">Body</.banner>|,
       ~w(fixed m-0) ++ margin, []}
    end,
    for position <- ~w(fixed_bottom fixed_top fixed_bottom_center fixed_top_center) do
      {"dock", "a #{position} dock",
       ~s|<.dock id="k" position="#{position}"><:item label="Home" navigate="/" /></.dock>|,
       ~w(fixed m-0), []}
    end,
    for position <- ~w(static sticky_bottom sticky_top) do
      {"dock", "a #{position} dock",
       ~s|<.dock id="k" position="#{position}"><:item label="Home" navigate="/" /></.dock>|, [],
       ~w(fixed m-0)}
    end,
    for action <- ~w(top-start top-end bottom-start bottom-end) do
      {"speed_dial", "a speed dial at #{action}",
       ~s|<.speed_dial id="sd" icon="hero-plus" action_position="#{action}"><:item label="Add" href="/">Add</:item></.speed_dial>|,
       ~w(fixed m-0), []}
    end,
    for {horizontal, margin} <- [{"left", "ml-1"}, {"right", "mr-1"}, {"center", nil}],
        vertical <- ~w(top bottom) do
      {"toast", "a #{vertical} #{horizontal} toast",
       ~s|<.toast id="t" horizontal="#{horizontal}" vertical="#{vertical}">Saved</.toast>|,
       ~w(fixed m-0) ++ List.wrap(margin), []}
    end,
    [
      {"toast", "a toast that sits in its group", ~s|<.toast id="t" fixed={false}>Saved</.toast>|,
       [], ~w(fixed m-0)}
    ],
    for horizontal <- ~w(left right center), vertical <- ~w(top bottom) do
      {"toast", "a #{vertical} #{horizontal} toast group",
       ~s|<.toast_group id="g" horizontal="#{horizontal}" vertical="#{vertical}">Saved</.toast_group>|,
       ~w(fixed m-0), []}
    end,
    for {position, margin} <- [
          {"top_left", "ml-2"},
          {"top_right", "mr-2"},
          {"bottom_left", "ml-2"},
          {"bottom_right", "mr-2"}
        ] do
      {"alert", "a flash group at #{position}",
       ~s|<.flash_group flash={%{}} position="#{position}" />|, ~w(fixed m-0 #{margin}), []}
    end
  ]

  # The template as the generator writes it, every catalog option on (an option it is not given is
  # nil). The host's Gettext backend is not here, so the passthrough the runtime harness uses
  # stands in for it.
  defp generated_source(name, module) do
    assigns = %{
      module: inspect(module),
      web_module: __MODULE__.Web,
      module_prefix_camel: "",
      component_prefix: ""
    }

    tag = ~r/<%(?!%).*?%>/s

    tag
    |> Regex.replace(
      File.read!(Path.join(@components, "#{name}.eex")),
      &Regex.replace(~r/@(\w+)/, &1, "assigns[:\\1]")
    )
    |> EEx.eval_string(assigns: assigns)
    |> String.replace(
      ~r/^\s*use Gettext, backend: .*$/m,
      "  import MishkaChelekom.Test.Runtime.GettextStub"
    )
  end

  defp compiled(name) do
    module = Module.concat(__MODULE__, Macro.camelize(name))
    [{component, _bytecode}] = Code.compile_string(generated_source(name, module))
    component
  end

  # The classes of the first element `markup` renders, which is the root of every case.
  defp root_classes(component, markup) do
    page = Module.concat(component, "Page#{System.unique_integer([:positive])}")

    [{page, _bytecode}] =
      Code.compile_string("""
      defmodule #{inspect(page)} do
        use Phoenix.Component
        import #{inspect(component)}

        def page(assigns), do: ~H\"\"\"
        #{markup}
        \"\"\"
      end
      """)

    html = %{} |> page.page() |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
    [root] = Regex.run(~r/\A\s*<[a-z]+\s[^>]*>/, html)
    [_match, classes] = Regex.run(~r/\sclass="([^"]*)"/, root)
    String.split(classes)
  end

  setup_all do
    names = @cases |> List.flatten() |> Enum.map(&elem(&1, 0)) |> Enum.uniq()
    %{components: Map.new(names, &{&1, compiled(&1)})}
  end

  for {name, label, markup, has, lacks} <- List.flatten(@cases) do
    test "#{label} #{if lacks == [], do: "resets its margin", else: "keeps its margin"}",
         %{components: components} do
      classes = root_classes(components[unquote(name)], unquote(markup))

      for class <- unquote(has) do
        assert class in classes, "#{unquote(label)} has no #{class}: #{Enum.join(classes, " ")}"
      end

      for class <- unquote(lacks) do
        refute class in classes, "#{unquote(label)} has #{class}: #{Enum.join(classes, " ")}"
      end
    end
  end

  # Components whose `fixed` is on an inner element, not on their root: the modal's backdrop and
  # its scroll wrapper are children of a `relative` root that `space-y-*` reaches, not of the page.
  @inner_only ~w(modal)

  test "no other styled template draws a fixed element" do
    fixed = ~r/"[^"\n]*(?<![\w-])fixed(?![\w-])[^"\n]*"/

    templates =
      for path <- Path.wildcard(Path.join(@components, "*.eex")),
          text = File.read!(path),
          text
          |> String.split("\n")
          |> Enum.any?(&(Regex.match?(fixed, &1) and not String.match?(&1, ~r/doc:|==/))),
          do: Path.basename(path, ".eex")

    covered = @cases |> List.flatten() |> Enum.map(&elem(&1, 0)) |> Enum.uniq()

    assert Enum.sort(templates) == Enum.sort(covered ++ @inner_only),
           "a styled template with a fixed element needs a case above, or a reason to be inner only"
  end
end
