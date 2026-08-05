defmodule MishkaMob.Components.MishkaDialogTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaDialog

  @scrim 0x99_00_00_00
  @clear 0x00_00_00_00

  defp body, do: [%{type: :text, props: %{text: "body text"}, children: []}]
  defp actions, do: [%{type: :button, props: %{text: "OK"}, children: []}]

  defp p(extra \\ %{}), do: Map.merge(%{open: true, on_close: :close}, extra)
  defp open(extra \\ %{}), do: MishkaDialog.dialog(p(extra), body(), actions())

  defp scrim(tree), do: find(tree, :box, background: @scrim)
  defp tagged(tree, id), do: Enum.find(flatten(tree), &(Map.get(&1.props, :id) == id))
  defp ids(tree), do: tree |> flatten() |> Enum.map(& &1.props[:id]) |> Enum.reject(&is_nil/1)

  describe "closed" do
    test "renders nothing when open is false or absent" do
      empty = %{type: :column, props: %{}, children: []}

      assert MishkaDialog.dialog(%{open: false}) == empty
      assert MishkaDialog.dialog(%{}) == empty
    end

    test "the body is not in the tree when closed" do
      refute text(MishkaDialog.dialog(%{open: false}, body())) =~ "body text"
    end

    test "a closed dialog emits no tags at all — presence IS the open state" do
      tree = MishkaDialog.dialog(%{id: "d", open: false}, body())

      assert Enum.all?(flatten(tree), &is_nil(Map.get(&1.props, :id)))
    end
  end

  describe "open" do
    test "stacks scrim then a centred viewport" do
      tree = open()

      assert %{type: :box, props: %{fill_width: true, fill_height: true}} = tree
      assert [%{type: :box}, %{type: :box, props: %{align: :center}}] = tree.children
    end

    test "renders title, description, body and actions" do
      tree = open(%{title: "Delete file?", description: "Cannot be undone."})

      assert text(tree) =~ "Delete file?"
      assert text(tree) =~ "Cannot be undone."
      assert text(tree) =~ "body text"
      # button labels are a prop, not a text node, so text/1 does not see them
      assert find(tree, :button, text: "OK")
    end

    test "title and description are omitted when not given" do
      tree = MishkaDialog.dialog(p(), body(), [])

      assert text(tree) =~ "body text"
      assert find_all(tree, :text) |> Enum.map(& &1.props.text) == ["body text"]
    end

    test "the viewport inset is overridable" do
      assert find(open(), :box, align: :center).props.padding == :space_lg
      assert find(open(%{inset: 4}), :box, align: :center).props.padding == 4
    end
  end

  describe "the panel" do
    test "is a width-locked Box so corners clip on both platforms" do
      panel = find(open(), :box, width: 320)

      assert panel.props.corner_radius == :radius_lg
      assert panel.props.background == :surface
    end

    test "width, background, corner_radius and padding are overridable" do
      tree = open(%{width: 280, background: 0xFF1E1B4B, corner_radius: 4, padding: :space_xl})
      panel = find(tree, :box, width: 280)

      assert panel.props.background == 0xFF1E1B4B
      assert panel.props.corner_radius == 4
      assert find(panel, :column, padding: :space_xl)
    end

    test "absorbs taps so they cannot fall through and dismiss the dialog" do
      panel = find(open(), :box, width: 320)

      assert {pid, :__mishka_dialog_ignore} = panel.props.on_tap
      assert pid == self()
    end
  end

  describe "the backdrop" do
    test "dismisses by default, with a widened handler" do
      assert scrim(open()).props.on_tap == {self(), :close}
    end

    test "dismissible: false leaves it inert — the user must choose" do
      refute Map.has_key?(scrim(open(%{dismissible: false})).props, :on_tap)
    end

    test "no on_close also leaves it inert" do
      tree = MishkaDialog.dialog(%{open: true}, body(), [])

      refute Map.has_key?(scrim(tree).props, :on_tap)
    end

    test "scrim_color is overridable" do
      tree = open(%{scrim_color: 0x66000000})

      assert find(tree, :box, background: 0x66000000)
    end
  end

  describe "modal" do
    test "dims by default" do
      assert scrim(open())
    end

    test "false and \"trap-focus\" render the same transparent backdrop" do
      for value <- [false, "trap-focus", :trap_focus, "false"] do
        tree = open(%{modal: value})

        refute scrim(tree)
        assert find(tree, :box, background: @clear)
      end
    end

    test "the string \"true\" dims, because the web serialises modal with to_string/1" do
      assert scrim(open(%{modal: "true"}))
    end

    test "an explicit scrim_color still wins over the modal default" do
      tree = open(%{modal: false, scrim_color: 0x33FF0000})

      assert find(tree, :box, background: 0x33FF0000)
    end

    test "a non-modal backdrop still dismisses — one hit test cannot both pass through and close" do
      assert find(open(%{modal: false}), :box, background: @clear).props.on_tap ==
               {self(), :close}
    end
  end

  describe "on_open_change" do
    test "carries the new state, mirroring the web's {open} payload" do
      tree = MishkaDialog.dialog(%{open: true, on_open_change: :changed}, body(), [])

      assert scrim(tree).props.on_tap == {self(), {:changed, false}}
    end

    test "on_close wins when both are given" do
      tree = open(%{on_open_change: :changed})

      assert scrim(tree).props.on_tap == {self(), :close}
    end

    test "an already-wired tuple is composed, not re-wrapped" do
      tree = MishkaDialog.dialog(%{open: true, on_open_change: {self(), :changed}}, body(), [])

      assert scrim(tree).props.on_tap == {self(), {:changed, false}}
    end
  end

  describe "test tags" do
    test "id names every part of the anatomy" do
      tree =
        MishkaDialog.dialog(
          %{id: "dlg", open: true, title: "T", description: "D", on_close: :close},
          body(),
          actions()
        )

      for suffix <- ~w(open backdrop-modal panel title description content footer) do
        assert tagged(tree, "dlg-" <> suffix), "no node tagged dlg-#{suffix}"
      end
    end

    test "the root tag exists only while open, so its presence is the state" do
      assert tagged(open(%{id: "dlg"}), "dlg-open")
      refute tagged(MishkaDialog.dialog(%{id: "dlg", open: false}, body()), "dlg-open")
    end

    test "the backdrop names whether it dims, because modal is otherwise pure colour" do
      assert tagged(open(%{id: "dlg"}), "dlg-backdrop-modal")
      assert tagged(open(%{id: "dlg", modal: false}), "dlg-backdrop-plain")
      refute tagged(open(%{id: "dlg", modal: false}), "dlg-backdrop-modal")
    end

    test "parts with nothing in them are not tagged" do
      tree = MishkaDialog.dialog(%{id: "dlg", open: true}, [], [])

      refute tagged(tree, "dlg-title")
      refute tagged(tree, "dlg-description")
      refute tagged(tree, "dlg-content")
      refute tagged(tree, "dlg-footer")
      assert tagged(tree, "dlg-panel")
    end

    test "an atom id is stringified — the native side reads a String or nothing" do
      assert tagged(open(%{id: :dlg}), "dlg-open")
    end

    test "without an id nothing is tagged" do
      assert Enum.all?(flatten(open()), &is_nil(Map.get(&1.props, :id)))
    end
  end

  describe "slots" do
    test "title/1, description/1 and footer/1 take a string and style it like the props" do
      slots = [MishkaDialog.title("T"), MishkaDialog.description("D")]
      tree = MishkaDialog.dialog(p(), slots ++ body(), [])

      assert find(tree, :text, text: "T").props.text_size == :xl
      assert find(tree, :text, text: "D").props.text_color == :muted
      assert text(tree) =~ "body text"
    end

    test "a slot takes arbitrary nodes, which is the whole point of a slot" do
      heading = %{type: :text, props: %{text: "custom heading"}, children: []}
      tree = MishkaDialog.dialog(p(%{id: "dlg"}), [MishkaDialog.title([heading])], [])

      assert find(tagged(tree, "dlg-title"), :text, text: "custom heading")
    end

    test "a single node needs no list" do
      heading = %{type: :text, props: %{text: "solo"}, children: []}

      assert text(MishkaDialog.dialog(p(), [MishkaDialog.title(heading)], [])) =~ "solo"
    end

    test "a slot child wins over its shorthand prop" do
      tree =
        MishkaDialog.dialog(
          p(%{title: "shorthand", description: "shorthand desc"}),
          [MishkaDialog.title("slot"), MishkaDialog.description("slot desc")],
          []
        )

      assert text(tree) =~ "slot"
      refute text(tree) =~ "shorthand"
    end

    test "footer/1 wins over the actions argument and lands in the same row" do
      slot = %{type: :button, props: %{text: "From slot"}, children: []}
      tree = MishkaDialog.dialog(p(), [MishkaDialog.footer([slot])], actions())

      assert find(tree, :button, text: "From slot")
      refute find(tree, :button, text: "OK")
      assert [%{type: :spacer, props: %{weight: 1}}, %{type: :button}] = find(tree, :row).children
    end

    test "slot children are consumed, never drawn" do
      slots = [MishkaDialog.title("T"), MishkaDialog.description("D"), MishkaDialog.footer([])]
      tree = MishkaDialog.dialog(p(), slots ++ body(), [])
      types = tree |> flatten() |> Enum.map(& &1.type) |> Enum.uniq()

      assert Enum.all?(MishkaDialog.slot_types(), &(&1 not in types))
      assert_renderable(tree)
    end

    test "an empty footer slot renders no footer row" do
      tree = MishkaDialog.dialog(p(), [MishkaDialog.footer([])], [])

      assert find_all(tree, :row) == []
    end
  end

  describe "trigger/3" do
    test "is a button tagged <id>-trigger" do
      node = MishkaDialog.trigger("dlg", "Open")

      assert node.type == :button
      assert node.props.id == "dlg-trigger"
      assert node.props.text == "Open"
      assert node.props.fill_width == true
    end

    test "on_tap is widened to the shape the renderer registers" do
      assert MishkaDialog.trigger("dlg", "Open", on_tap: :open).props.on_tap == {self(), :open}
    end

    test "on_open_change carries true, so one clause can serve both edges" do
      node = MishkaDialog.trigger("dlg", "Open", on_open_change: :changed)

      assert node.props.on_tap == {self(), {:changed, true}}
    end

    test "on_tap wins over on_open_change" do
      node = MishkaDialog.trigger("dlg", "Open", on_tap: :open, on_open_change: :changed)

      assert node.props.on_tap == {self(), :open}
    end

    test "disabled wires no handler and says so in the tag" do
      node = MishkaDialog.trigger("dlg", "Open", on_tap: :open, disabled: true)

      refute Map.has_key?(node.props, :on_tap)
      assert node.props.id == "dlg-trigger-disabled"
      assert node.props.background == :surface_raised
      assert node.props.text_color == :muted
    end

    test "chrome is overridable, and no id means no tag" do
      node =
        MishkaDialog.trigger(nil, "Open",
          background: :secondary,
          text_color: :on_secondary,
          padding: 4,
          fill_width: false
        )

      refute Map.has_key?(node.props, :id)
      assert node.props.background == :secondary
      assert node.props.text_color == :on_secondary
      assert node.props.padding == 4
      assert node.props.fill_width == false
    end

    test "renders natively" do
      assert_renderable(MishkaDialog.trigger("dlg", "Open", on_tap: :open))
    end
  end

  describe "footer" do
    test "actions sit in a trailing-aligned row" do
      row = find(open(), :row)

      assert [%{type: :spacer, props: %{weight: 1}} | rest] = row.children
      assert Enum.any?(rest, &(&1.type == :button))
    end

    test "no actions means no footer row" do
      tree = MishkaDialog.dialog(p(), body(), [])

      assert find_all(tree, :row) == []
    end
  end

  describe "composite tag" do
    test "expand/3 uses the tag's children as the body and the ctx screen pid" do
      tree = MishkaDialog.expand(p(), body(), %{screen: self()})

      assert text(tree) =~ "body text"
      assert find(tree, :box, width: 320).props.on_tap == {self(), :__mishka_dialog_ignore}
    end

    test "expand/3 pops actions out of the props and consumes slot children" do
      children = [MishkaDialog.title("T") | body()]
      tree = MishkaDialog.expand(p(%{actions: actions()}), children, %{screen: self()})

      assert find(tree, :button, text: "OK")
      assert text(tree) =~ "T"
      refute find(tree, :box, width: 320).props[:actions]
    end
  end

  # The gallery page is what DialogTest.kt drives, and it is written in slot
  # tags — panels, footers and triggers alike. This is where the tag form is
  # proved through the real composite pass rather than a hand-built child list.
  describe "the showcase page" do
    alias MishkaMob.Showcase.Components.Dialog, as: Page

    # The page is markup now, so nothing renders until the expanders behind
    # <MishkaDialog> and its slot tags are registered.
    setup do
      MishkaMob.Showcase.reset()
      MishkaMob.Showcase.register_all()

      :ok
    end

    defp mounted, do: Page.mount(Mob.Socket.new(MishkaMob.Showcase.ComponentScreen))

    defp expand(nil), do: nil
    defp expand(node), do: Mob.Composite.expand(node, self())

    defp opened(tag), do: expand(Page.overlay(Page.handle(tag, mounted()).assigns))

    test "each card renders its trigger through the trigger slot" do
      assigns = mounted().assigns
      tags = Enum.flat_map(Page.examples(), &ids(expand(&1.render.(assigns))))

      for id <- ~w(dlg-basic dlg-slots dlg-dismiss dlg-forced dlg-plain dlg-tinted) do
        assert "#{id}-trigger" in tags, "the #{id} card has no trigger"
      end

      # The one that wires no handler says so in its tag, because the muted
      # colour that says so is invisible to a device test.
      assert "dlg-disabled-trigger-disabled" in tags
      refute "dlg-disabled-trigger" in tags
    end

    test "a closed dialog on a card draws its trigger and nothing else" do
      card = expand(Enum.at(Page.examples(), 0).render.(mounted().assigns))

      refute "dlg-basic-open" in ids(card)
      refute "dlg-basic-panel" in ids(card)
    end

    test "every opened dialog carries the parts its device test names" do
      for id <- ~w(dlg-basic dlg-slots dlg-forced dlg-plain dlg-tinted) do
        key = String.to_existing_atom(String.replace(id, "-", "_"))
        overlay = opened({:dlg_open, key})

        for part <- ~w(open panel title description footer) do
          assert "#{id}-#{part}" in ids(overlay), "#{id} opened without its #{part}"
        end
      end
    end

    test "no slot marker survives the page" do
      assigns = mounted().assigns

      trees =
        Enum.map(Page.examples(), &expand(&1.render.(assigns))) ++
          Enum.map(
            ~w(dlg_basic dlg_slots dlg_dismiss dlg_forced dlg_plain dlg_tinted dlg_disabled)a,
            &opened({:dlg_open, &1})
          )

      # assert_renderable is blind to this: mix.exs whitelists every slot tag's
      # name, so it counts them renderable while MobBridge has no branch for
      # them and silently draws nothing. Only naming the markers catches it.
      for tree <- trees, type <- MishkaDialog.slot_types() do
        assert find_all(tree, type) == [], "a #{type} marker reached the renderer"
      end
    end
  end

  test "every variant renders" do
    for extra <- [
          %{},
          %{title: "T"},
          %{dismissible: false},
          %{width: 280},
          %{id: "dlg"},
          %{modal: false},
          %{on_open_change: :changed},
          %{inset: 0}
        ] do
      assert_renderable(open(extra))
    end
  end
end
