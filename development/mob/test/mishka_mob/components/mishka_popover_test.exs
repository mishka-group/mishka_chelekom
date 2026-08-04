defmodule MishkaMob.Components.MishkaPopoverTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaPopover

  defp content, do: [%{type: :text, props: %{text: "panel body"}, children: []}]

  defp open(props), do: MishkaPopover.popover(Map.put(props, :open, true), content())

  defp closed(props), do: MishkaPopover.popover(Map.put(props, :open, false), content())

  defp node_with_id(tree, id), do: Enum.find(flatten(tree), &(&1.props[:id] == id))

  describe "open gate" do
    test "with no trigger a closed popover renders nothing at all" do
      assert MishkaPopover.popover(%{}, content()) == %{
               type: :column,
               props: %{fill_width: true},
               children: []
             }

      assert MishkaPopover.popover(%{open: false}, content()).children == []
    end

    test "a trigger survives the panel being closed — it is what reopens it" do
      tree = closed(%{id: "p", trigger: "Details"})

      assert node_with_id(tree, "p-trigger-closed")
      refute node_with_id(tree, "p-panel")
      refute text(tree) =~ "panel body"
    end

    test "renders the panel when open" do
      tree = open(%{id: "p"})

      assert node_with_id(tree, "p-panel")
      assert text(tree) =~ "panel body"
    end
  end

  describe "the trigger" do
    test "its tag carries its own open state, because its fill is the only other clue" do
      shut = closed(%{id: "p", trigger: "Go"})
      up = open(%{id: "p", trigger: "Go"})

      assert node_with_id(shut, "p-trigger-closed")
      assert node_with_id(up, "p-trigger-open")

      # …and never both, or a test could not tell the two states apart.
      refute node_with_id(shut, "p-trigger-open")
      refute node_with_id(up, "p-trigger-closed")
    end

    test "reads as pressed while its panel is up" do
      shut = node_with_id(closed(%{id: "p", trigger: "Go"}), "p-trigger-closed")
      up = node_with_id(open(%{id: "p", trigger: "Go"}), "p-trigger-open")

      assert shut.props.background == :surface_raised
      assert up.props.background == :primary
      assert text(up) =~ "▴"
      assert text(shut) =~ "▾"
    end

    test "a tap asks for the opposite of now" do
      shut =
        node_with_id(closed(%{id: "p", trigger: "Go", on_open_change: :chg}), "p-trigger-closed")

      up = node_with_id(open(%{id: "p", trigger: "Go", on_open_change: :chg}), "p-trigger-open")

      assert {pid, {:chg, true}} = shut.props.on_tap
      assert pid == self()
      assert {_pid, {:chg, false}} = up.props.on_tap
    end

    test "a hold only ever opens, and only when asked for" do
      plain =
        node_with_id(closed(%{id: "p", trigger: "Go", on_open_change: :chg}), "p-trigger-closed")

      held =
        node_with_id(
          closed(%{id: "p", trigger: "Go", on_open_change: :chg, open_on_hold: true}),
          "p-trigger-closed"
        )

      refute Map.has_key?(plain.props, :on_long_press)
      assert {_pid, {:chg, true}} = held.props.on_long_press

      # Open already, and the hold still says true — a hover never toggled.
      up =
        node_with_id(
          open(%{id: "p", trigger: "Go", on_open_change: :chg, open_on_hold: true}),
          "p-trigger-open"
        )

      assert {_pid, {:chg, true}} = up.props.on_long_press
      assert {_pid, {:chg, false}} = up.props.on_tap
    end

    test "disabled wires no handler at all, so it cannot fire" do
      trigger =
        node_with_id(
          closed(%{
            id: "p",
            trigger: "Go",
            on_open_change: :chg,
            open_on_hold: true,
            disabled: true
          }),
          "p-trigger-closed"
        )

      refute Map.has_key?(trigger.props, :on_tap)
      refute Map.has_key?(trigger.props, :on_long_press)
      assert find(trigger, :text).props.text_color == :muted
    end

    test "an already-wired {pid, tag} is composed with the state, not re-wrapped" do
      # The tag form goes through Mob.Composite, which widens on_open_change
      # before expand/3 ever runs; composing that again would produce a message
      # no handle_info clause matches.
      trigger =
        node_with_id(
          closed(%{id: "p", trigger: "Go", on_open_change: {self(), :chg}}),
          "p-trigger-closed"
        )

      assert trigger.props.on_tap == {self(), {:chg, true}}
    end

    test "takes a node, or a list of them, when a label is not enough" do
      icon = %{type: :text, props: %{text: "⧉"}, children: []}

      one = closed(%{id: "p", trigger: icon})
      many = closed(%{id: "p", trigger: [icon, icon]})

      assert text(node_with_id(one, "p-trigger-closed")) =~ "⧉"
      # two glyphs plus the chevron
      assert length(find_all(node_with_id(many, "p-trigger-closed"), :text)) == 3
    end

    test "the chevron is droppable" do
      bare = node_with_id(closed(%{id: "p", trigger: "Go", chevron: false}), "p-trigger-closed")

      refute text(bare) =~ "▾"
      assert text(bare) =~ "Go"
    end

    test "the label never wraps character by character" do
      trigger = node_with_id(closed(%{id: "p", trigger: "Go"}), "p-trigger-closed")

      assert find(trigger, :text, text: "Go").props.max_lines == 1
    end
  end

  describe "the panel's parts" do
    test "title, description and close each carry their own tag" do
      tree = open(%{id: "p", title: "Shipped", description: "By email.", close: "Got it"})

      assert node_with_id(tree, "p-title").props.text == "Shipped"
      assert node_with_id(tree, "p-desc").props.text == "By email."
      assert text(node_with_id(tree, "p-close")) =~ "Got it"
    end

    test "closing from the footer reports the same event the trigger does" do
      close = node_with_id(open(%{id: "p", close: "Got it", on_open_change: :chg}), "p-close")

      assert {_pid, {:chg, false}} = close.props.on_tap
    end

    test "the close action hugs its label instead of becoming a bar" do
      close = node_with_id(open(%{id: "p", close: "Got it"}), "p-close")

      assert close.props.fill_width == false
    end

    test "the ink follows the fill, so a custom panel keeps a readable title" do
      tree =
        open(%{
          id: "p",
          title: "T",
          description: "D",
          background: 0xFF1E1B4B,
          color: 0xFFFFFFFF,
          muted_color: 0xFFC7D2FE
        })

      assert node_with_id(tree, "p-title").props.text_color == 0xFFFFFFFF
      assert node_with_id(tree, "p-desc").props.text_color == 0xFFC7D2FE
    end

    test "the beak is opt-in, tinted like the panel, and points back at the trigger" do
      refute node_with_id(open(%{id: "p"}), "p-arrow")

      for {side, glyph} <- [bottom: "▲", top: "▼", right: "◀", left: "▶"] do
        arrow = node_with_id(open(%{id: "p", arrow: true, side: side}), "p-arrow")

        assert arrow.props.text == glyph
        assert arrow.props.text_color == :surface
      end

      tinted = node_with_id(open(%{id: "p", arrow: true, background: 0xFF1E1B4B}), "p-arrow")
      assert tinted.props.text_color == 0xFF1E1B4B
    end

    test "parts appear only when asked for" do
      tree = open(%{id: "p"})

      for part <- ["p-title", "p-desc", "p-close", "p-arrow"],
          do: refute(node_with_id(tree, part))
    end

    test "without an id nothing is tagged, and nothing carries a nil tag" do
      tree = open(%{title: "T", description: "D", close: "C", arrow: true, trigger: "Go"})

      refute Enum.any?(flatten(tree), &Map.has_key?(&1.props, :id))
    end
  end

  describe "side puts the panel where anchoring used to" do
    test "bottom is the default: trigger, gap, panel" do
      tree = open(%{id: "p", trigger: "Go"})

      assert tree.type == :column
      assert Enum.map(tree.children, & &1.type) == [:box, :spacer, :box]
      assert hd(tree.children).props.id == "p-trigger-open"
      assert List.last(tree.children).props.id == "p-panel"
    end

    test "top runs the same sequence backwards" do
      tree = open(%{id: "p", trigger: "Go", side: :top})

      assert tree.type == :column
      assert hd(tree.children).props.id == "p-panel"
      assert List.last(tree.children).props.id == "p-trigger-open"
    end

    test "left and right sit abreast, in a Row" do
      right = open(%{id: "p", trigger: "Go", side: :right})
      left = open(%{id: "p", trigger: "Go", side: :left})

      assert right.type == :row
      assert left.type == :row
      assert hd(right.children).props.id == "p-trigger-open"
      assert List.last(left.children).props.id == "p-trigger-open"
    end

    test "beside a trigger the panel is weighted and the trigger hugs" do
      # Compose measures a Row's unweighted children first, so an unweighted
      # panel next to a filling trigger would be starved to nothing.
      tree = open(%{id: "p", trigger: "Go", side: :right})

      assert node_with_id(tree, "p-trigger-open").props.fill_width == false
      assert List.last(tree.children).props == %{weight: 1}
    end

    test "stacked, the trigger fills instead" do
      trigger = node_with_id(open(%{id: "p", trigger: "Go"}), "p-trigger-open")

      assert trigger.props.fill_width == true
    end

    test "an unknown side falls back to bottom rather than rendering sideways" do
      assert open(%{id: "p", trigger: "Go", side: :sideways}).type == :column
      assert open(%{id: "p", trigger: "Go", side: "right"}).type == :row
    end

    test "side_offset is the gap, and defaults to the web's 8" do
      gap = fn props -> Enum.find(open(props).children, &(&1.type == :spacer)).props.size end

      assert gap.(%{trigger: "Go"}) == 8
      assert gap.(%{trigger: "Go", side_offset: 16}) == 16
    end
  end

  describe "align places a panel narrow enough to have somewhere to go" do
    test "start needs no wrapper — a Box already begins at the leading edge" do
      tree = open(%{id: "p", width: 200})

      assert List.last(tree.children).props.id == "p-panel"
    end

    test "centre and end wrap the panel in an aligned Box" do
      for {align, expected} <- [center: :top_center, end: :top_trailing] do
        wrapper = List.last(open(%{id: "p", width: 200, align: align}).children)

        assert wrapper.props.align == expected
        assert hd(wrapper.children).props.id == "p-panel"
      end
    end

    test "abreast, the same three names land on the Row's vertical alignment" do
      for {align, expected} <- [start: :top, end: :bottom] do
        assert open(%{trigger: "Go", side: :right, align: align}).props.align == expected
      end

      # Centre is a Row's own default, so it says nothing.
      refute Map.has_key?(open(%{trigger: "Go", side: :right, align: :center}).props, :align)
    end

    test "align_offset nudges along whichever axis the alignment runs on" do
      down = node_with_id(open(%{id: "p", align_offset: 12}), "p-panel")
      across = node_with_id(open(%{id: "p", side: :right, align_offset: 12}), "p-panel")

      assert down.props.offset_x == 12
      assert across.props.offset_y == 12
    end

    test "an explicit offset wins — it is the raw escape hatch" do
      panel = node_with_id(open(%{id: "p", align_offset: 12, offset_x: -4}), "p-panel")

      assert panel.props.offset_x == -4
    end
  end

  describe "the panel shell" do
    test "carries a border, so it reads as separate from the content beneath" do
      tree = MishkaPopover.panel(%{}, content())

      assert tree.props.border_color == :border
      assert tree.props.border_width == 1
    end

    test "defaults: surface fill, rounded, padded, filling its parent" do
      tree = MishkaPopover.panel(%{}, content())

      assert tree.props.background == :surface
      assert tree.props.corner_radius == :radius_md
      assert tree.props.padding == :space_md
      assert tree.props.fill_width == true
    end

    test "a width replaces fill_width rather than fighting it" do
      tree = MishkaPopover.panel(%{width: 240}, content())

      assert tree.props.width == 240
      refute Map.has_key?(tree.props, :fill_width)
    end

    test "chrome is overridable, border included" do
      tree =
        MishkaPopover.panel(
          %{background: 0xFF1E1B4B, corner_radius: 4, padding: 2, border_width: 0},
          content()
        )

      assert tree.props.background == 0xFF1E1B4B
      assert tree.props.corner_radius == 4
      assert tree.props.padding == 2
      assert tree.props.border_width == 0
    end

    test "takes its :id verbatim, so a caller with its own scheme keeps it" do
      assert MishkaPopover.panel(%{id: "menu"}, content()).props.id == "menu"
      refute Map.has_key?(MishkaPopover.panel(%{}, content()).props, :id)
    end

    test "is the shell only — the popover's own parts do not leak into Menu" do
      # MishkaMenu forwards its whole prop map here, so anything panel/2 read
      # would start appearing inside menus.
      tree = MishkaPopover.panel(%{title: "T", description: "D", close: "C"}, content())

      assert text(tree) == "panel body"
    end
  end

  describe "offsets are a nudge, not anchoring" do
    test "are omitted unless asked for" do
      props = MishkaPopover.panel(%{}, content()).props

      refute Map.has_key?(props, :offset_x)
      refute Map.has_key?(props, :offset_y)
    end

    test "are passed through when given" do
      props = MishkaPopover.panel(%{offset_x: 8, offset_y: -4}, content()).props

      assert props.offset_x == 8
      assert props.offset_y == -4
    end
  end

  describe "part ids" do
    test "each derives from the root's" do
      assert MishkaPopover.trigger_id("p", true) == "p-trigger-open"
      assert MishkaPopover.trigger_id("p", false) == "p-trigger-closed"
      assert MishkaPopover.panel_id("p") == "p-panel"
      assert MishkaPopover.title_id("p") == "p-title"
      # -desc, not -description: it matches the web's aria-describedby target.
      assert MishkaPopover.description_id("p") == "p-desc"
      assert MishkaPopover.close_id("p") == "p-close"
      assert MishkaPopover.arrow_id("p") == "p-arrow"
    end

    test "no id, no tag" do
      assert MishkaPopover.trigger_id(nil, true) == nil
      assert MishkaPopover.panel_id(nil) == nil
      assert MishkaPopover.title_id(nil) == nil
      assert MishkaPopover.description_id(nil) == nil
      assert MishkaPopover.close_id(nil) == nil
      assert MishkaPopover.arrow_id(nil) == nil
    end

    test "the root wears the id it was given" do
      assert open(%{id: "p"}).props.id == "p"
    end
  end

  test "expand/3 uses the tag's children as the content" do
    assert MishkaPopover.expand(%{open: true}, content(), %{screen: self()}) ==
             MishkaPopover.popover(%{open: true}, content())
  end

  describe "through the composite pipeline (registration + event injection)" do
    setup do
      Mob.Composite.register(:mishka_popover, {MishkaPopover, :expand})
      :ok
    end

    defp expanded(props, children \\ []) do
      Mob.Composite.expand(
        %{type: :mishka_popover, props: props, children: children},
        self()
      )
    end

    test "a <MishkaPopover> node expands to a fully renderable native tree" do
      tree = expanded(%{id: "p", open: true, trigger: "Go", title: "T", close: "C"}, content())

      refute Enum.any?(flatten(tree), &(&1.type == :mishka_popover))
      assert_renderable(tree)
    end

    test "the tag form reaches a handle_info clause the screen can actually match" do
      # Mob.Composite widens on_open_change to {screen_pid, tag} BEFORE expand/3
      # runs. Composing that with the state by hand would give
      # {self(), {{pid, :chg}, true}} — a handler that fires, a message that
      # arrives, and no clause that matches it. Only the tag form shows it.
      tree = expanded(%{id: "p", open: false, trigger: "Go", on_open_change: :chg})
      trigger = Enum.find(flatten(tree), &(&1.props[:id] == "p-trigger-closed"))

      assert trigger.props.on_tap == {self(), {:chg, true}}
    end
  end

  test "every variant renders" do
    variants = [
      %{open: true},
      %{open: true, width: 200},
      %{open: true, border_width: 0},
      %{open: false, trigger: "Go", id: "p", on_open_change: :chg},
      %{
        open: true,
        trigger: "Go",
        id: "p",
        title: "T",
        description: "D",
        close: "C",
        arrow: true
      },
      %{open: true, trigger: "Go", side: :top, align: :center, arrow: true},
      %{open: true, trigger: "Go", side: :left, align: :end, width: 160},
      %{open: true, trigger: "Go", side: :right, disabled: true, chevron: false}
    ]

    for props <- variants, do: assert_renderable(MishkaPopover.popover(props, content()))
  end
end
