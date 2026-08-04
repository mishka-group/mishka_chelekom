defmodule MishkaMob.Components.MishkaPopoverTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  # The slot tests write the tags as real markup rather than hand-building the
  # node: the point of a slot tag is that a caller writes it, so the assertion
  # has to start where the caller does.
  import Mob.Sigil

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

  describe "slot tags" do
    setup do
      Mob.Composite.register(:mishka_popover, {MishkaPopover, :expand})
      :ok
    end

    defp shut(children), do: expanded(%{id: "p", open: false}, children)
    defp up(children), do: expanded(%{id: "p", open: true}, children)

    test "<MishkaPopoverTrigger> builds what trigger/1 builds" do
      assert ~MOB(<MishkaPopoverTrigger text="Go" />) == MishkaPopover.trigger("Go")

      assert shut([~MOB(<MishkaPopoverTrigger text="Go" />)]) ==
               shut([MishkaPopover.trigger("Go")])

      assert text(node_with_id(shut([MishkaPopover.trigger("Go")]), "p-trigger-closed")) =~ "Go"
    end

    test "no <MishkaPopoverTrigger> marker survives expansion" do
      # A leaked marker is SILENT: the tag is whitelisted, so the sigil accepts
      # it and assert_renderable/1 is satisfied — the renderer simply has no
      # case for the type and draws nothing where the trigger should be.
      assert find_all(shut([~MOB(<MishkaPopoverTrigger text="Go" />)]), :mishka_popover_trigger) ==
               []
    end

    test "<MishkaPopoverTitle> builds what title/1 builds" do
      assert ~MOB(<MishkaPopoverTitle text="Shipped" />) == MishkaPopover.title("Shipped")

      tree = up([~MOB(<MishkaPopoverTitle text="Shipped" />)])

      assert tree == up([MishkaPopover.title("Shipped")])
      assert node_with_id(tree, "p-title").props.text == "Shipped"
    end

    test "no <MishkaPopoverTitle> marker survives expansion" do
      assert find_all(up([~MOB(<MishkaPopoverTitle text="Shipped" />)]), :mishka_popover_title) ==
               []
    end

    test "<MishkaPopoverDescription> builds what description/1 builds" do
      assert ~MOB(<MishkaPopoverDescription text="By email." />) ==
               MishkaPopover.description("By email.")

      tree = up([~MOB(<MishkaPopoverDescription text="By email." />)])

      assert tree == up([MishkaPopover.description("By email.")])
      assert node_with_id(tree, "p-desc").props.text == "By email."
    end

    test "no <MishkaPopoverDescription> marker survives expansion" do
      tree = up([~MOB(<MishkaPopoverDescription text="By email." />)])

      assert find_all(tree, :mishka_popover_description) == []
    end

    test "<MishkaPopoverClose> builds what close/1 builds" do
      assert ~MOB(<MishkaPopoverClose text="Got it" />) == MishkaPopover.close("Got it")

      tree = up([~MOB(<MishkaPopoverClose text="Got it" />)])

      assert tree == up([MishkaPopover.close("Got it")])
      assert text(node_with_id(tree, "p-close")) =~ "Got it"
    end

    test "no <MishkaPopoverClose> marker survives expansion" do
      assert find_all(up([~MOB(<MishkaPopoverClose text="Got it" />)]), :mishka_popover_close) ==
               []
    end

    test "<MishkaPopoverArrow> builds what arrow/0 builds" do
      assert ~MOB(<MishkaPopoverArrow />) == MishkaPopover.arrow()

      tree = up([~MOB(<MishkaPopoverArrow />)])

      assert tree == up([MishkaPopover.arrow()])
      # Written bare, the tag says exactly what `arrow={true}` says.
      assert node_with_id(tree, "p-arrow").props.text == "▲"
    end

    test "no <MishkaPopoverArrow> marker survives expansion" do
      assert find_all(up([~MOB(<MishkaPopoverArrow />)]), :mishka_popover_arrow) == []
    end

    test "a slot wins over its shorthand prop" do
      tree =
        expanded(%{id: "p", open: true, title: "From the prop"}, [
          ~MOB(<MishkaPopoverTitle text="From the slot" />)
        ])

      assert node_with_id(tree, "p-title").props.text == "From the slot"
    end

    test "the shorthand props still build the identical tree" do
      slots = [
        MishkaPopover.trigger("Go"),
        MishkaPopover.title("T"),
        MishkaPopover.description("D"),
        MishkaPopover.close("C"),
        MishkaPopover.arrow()
      ]

      props = %{id: "p", open: true, trigger: "Go", title: "T", description: "D", close: "C"}

      assert expanded(Map.put(props, :arrow, true), []) ==
               expanded(%{id: "p", open: true}, slots)
    end

    test "order does not matter — each part is placed by the anatomy, not by where it was written" do
      written_backwards = [
        ~MOB(<MishkaPopoverClose text="C" />),
        ~MOB(<MishkaPopoverDescription text="D" />),
        ~MOB(<MishkaPopoverTitle text="T" />),
        ~MOB(<MishkaPopoverTrigger text="Go" />)
      ]

      in_order = [
        MishkaPopover.trigger("Go"),
        MishkaPopover.title("T"),
        MishkaPopover.description("D"),
        MishkaPopover.close("C")
      ]

      assert up(written_backwards) == up(in_order)
    end

    test "bare children are the body, and keep their place between title and footer" do
      tree =
        up([
          ~MOB(<MishkaPopoverTitle text="T" />),
          %{type: :text, props: %{text: "panel body"}, children: []},
          ~MOB(<MishkaPopoverClose text="C" />)
        ])

      assert text(tree) =~ "panel body"
      assert_renderable(tree)
    end

    test "a slot written as markup is styled by the caller and still carries the part's tag" do
      tree =
        up([MishkaPopover.title([%{type: :text, props: %{text: "★ Shipped"}, children: []}])])

      title = node_with_id(tree, "p-title")

      # A Text would have worn the tag itself; markup gets its own Column, so
      # the part stays addressable whatever the caller put in it.
      assert title.type == :column
      assert text(title) =~ "★ Shipped"
    end

    test "the arrow slot may carry a glyph of its own, tinted like the panel" do
      tree = expanded(%{id: "p", open: true, background: 0xFF1E1B4B}, [MishkaPopover.arrow("◆")])
      arrow = node_with_id(tree, "p-arrow")

      assert arrow.props.text == "◆"
      assert arrow.props.text_color == 0xFF1E1B4B
    end

    test "a close slot of your own controls is not wired for you" do
      button = %{type: :button, props: %{text: "Later"}, children: []}
      tree = up([MishkaPopover.close([button])])
      footer = node_with_id(tree, "p-close")

      # The tag goes on the row rather than on a control this module did not
      # build — and nothing in it is wired, because those handlers are yours.
      assert footer.type == :row
      refute Map.has_key?(footer.props, :on_tap)
      assert find(footer, :button, text: "Later")
    end

    test "the wired close is the labelled one, and it reports the popover shut" do
      tree =
        expanded(%{id: "p", open: true, on_open_change: :chg}, [MishkaPopover.close("Got it")])

      assert node_with_id(tree, "p-close").props.on_tap == {self(), {:chg, false}}
    end

    test "every slot type is consumed, so none of them ever reaches the renderer" do
      tree =
        up([
          MishkaPopover.trigger("Go"),
          MishkaPopover.title("T"),
          MishkaPopover.description("D"),
          MishkaPopover.close("C"),
          MishkaPopover.arrow()
        ])

      for type <- MishkaPopover.slot_types(), do: assert(find_all(tree, type) == [])
      assert_renderable(tree)
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
