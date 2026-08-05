defmodule MishkaMob.Components.MishkaNavLinkTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{
    MishkaAnchor,
    MishkaMenubar,
    MishkaNavigationMenu,
    MishkaNavLink,
    MishkaVisuallyHidden
  }

  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  doctest MishkaMob.Components.MishkaAnchor
  doctest MishkaMob.Components.MishkaMenubar
  doctest MishkaMob.Components.MishkaNavigationMenu
  doctest MishkaMob.Components.MishkaVisuallyHidden

  defp glyphs(tree), do: tree |> find_all(:text) |> Enum.map(& &1.props.text)

  defp taps(tree),
    do: tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

  # Every test tag in the tree — what a device test can actually address.
  defp tags(tree),
    do: tree |> flatten() |> Enum.map(&get_in(&1, [:props, :id])) |> Enum.reject(&is_nil/1)

  defp tagged(tree, tag), do: tree |> flatten() |> Enum.find(&(get_in(&1, [:props, :id]) == tag))

  describe "nav link" do
    test "a leaf is a row; a parent gets a chevron" do
      leaf = MishkaNavLink.nav_link(%{label: "Inbox"}, [])
      parent = MishkaNavLink.nav_link(%{label: "Mail"}, [leaf])

      refute "▸" in glyphs(leaf)
      assert "▸" in glyphs(parent)
    end

    test "children show only when opened" do
      child = MishkaNavLink.nav_link(%{label: "Inbox"}, [])

      refute text(MishkaNavLink.nav_link(%{label: "Mail"}, [child])) =~ "Inbox"
      assert text(MishkaNavLink.nav_link(%{label: "Mail", opened: true}, [child])) =~ "Inbox"
    end

    test "opened is a prop, so it cannot be lost on re-render" do
      child = MishkaNavLink.nav_link(%{label: "Inbox"}, [])
      open = MishkaNavLink.nav_link(%{label: "Mail", opened: true}, [child])

      assert "▾" in glyphs(open)
      # Rendering the same props twice gives the same tree — no hidden state.
      assert MishkaNavLink.nav_link(%{label: "Mail", opened: true}, [child]) == open
    end

    test "a childless link ignores opened rather than drawing an empty group" do
      tree = MishkaNavLink.nav_link(%{label: "Solo", opened: true}, [])

      refute "▾" in glyphs(tree)
    end

    test "active styling marks the current page" do
      tree = MishkaNavLink.nav_link(%{label: "Inbox", active: true}, [])
      label = tree |> find_all(:text) |> Enum.find(&(&1.props.text == "Inbox"))

      assert label.props.text_color == :primary
      # `font_weight`, not `weight` — the bridges read the former for typography,
      # and the latter is a parent Row/Column layout weight that styles nothing.
      assert label.props.font_weight == :semibold
      refute Map.has_key?(label.props, :weight)
      assert find(tree, :box).props.background == :surface_raised
    end

    test "icon, description and trailing all render" do
      tree =
        MishkaNavLink.nav_link(
          %{label: "Drafts", icon: "✉", description: "3 unsent", trailing: "›"},
          []
        )

      assert "✉" in glyphs(tree)
      assert "3 unsent" in glyphs(tree)
      assert "›" in glyphs(tree)
    end

    test "a parent's chevron wins over a custom trailing glyph" do
      child = MishkaNavLink.nav_link(%{label: "x"}, [])
      tree = MishkaNavLink.nav_link(%{label: "Mail", trailing: "›"}, [child])

      refute "›" in glyphs(tree)
      assert "▸" in glyphs(tree)
    end

    test "a leaf taps, a parent toggles, and on_toggle falls back to on_tap" do
      child = MishkaNavLink.nav_link(%{label: "x"}, [])

      leaf = MishkaNavLink.nav_link(%{label: "Inbox", on_tap: :go}, [])
      parent = MishkaNavLink.nav_link(%{label: "Mail", on_tap: :go, on_toggle: :toggle}, [child])
      fallback = MishkaNavLink.nav_link(%{label: "Mail", on_tap: :go}, [child])

      assert {self(), :go} in taps(leaf)
      assert {self(), :toggle} in taps(parent)
      assert {self(), :go} in taps(fallback)
    end

    test "an href rides along with the tag" do
      tree = MishkaNavLink.nav_link(%{label: "Docs", href: "/docs", on_tap: :go}, [])

      assert {self(), {:go, "/docs"}} in taps(tree)
    end

    test "disabled mutes and wires nothing" do
      tree = MishkaNavLink.nav_link(%{label: "Archive", disabled: true, on_tap: :go}, [])

      assert taps(tree) == []
      assert find(tree, :text).props.text_color == :muted
    end

    test "children are indented" do
      child = MishkaNavLink.nav_link(%{label: "x"}, [])
      tree = MishkaNavLink.nav_link(%{label: "Mail", opened: true, indent: 24}, [child])
      sizes = tree |> find_all(:spacer) |> Enum.map(& &1.props[:size])

      assert 24 in sizes
    end

    test "the label takes the row's slack, so a long one cannot starve the chevron" do
      child = MishkaNavLink.nav_link(%{label: "x"}, [])
      tree = MishkaNavLink.nav_link(%{label: "Mail", icon: "✉"}, [child])
      row = find(tree, :row)

      # Compose measures a Row's UNWEIGHTED children first and in order, so an
      # unweighted label column takes the whole width and the chevron is laid
      # out in nothing at all. The weighted Box is what leaves it room.
      assert Enum.any?(row.children, &(&1.props[:weight] == 1))
      # And the label is capped at a line: a Text squeezed narrower than its
      # content wraps character by character rather than eliding.
      assert find(tree, :text, text: "Mail").props[:max_lines] == 1
    end
  end

  describe "nav link test tags" do
    test "id fans out to the nodes whose state is otherwise only a colour" do
      tree =
        MishkaNavLink.nav_link(
          %{id: "nav-docs", label: "Docs", icon: "▤", trailing: "↗", active: true},
          []
        )

      assert tags(tree) == ["nav-docs", "nav-docs-icon", "nav-docs-active", "nav-docs-trailing"]
      # The tag sits on the row itself, which is what carries the tap.
      assert tagged(tree, "nav-docs").props[:background] == :surface_raised
    end

    test "the label's tag names its ink, and disabled outranks active" do
      label_tag = fn props ->
        props |> Map.merge(%{id: "nav-x", label: "X"}) |> MishkaNavLink.nav_link([]) |> tags()
      end

      assert label_tag.(%{}) == ["nav-x", "nav-x-inactive"]
      assert label_tag.(%{active: true}) == ["nav-x", "nav-x-active"]
      assert label_tag.(%{disabled: true}) == ["nav-x", "nav-x-disabled"]
      assert label_tag.(%{active: true, disabled: true}) == ["nav-x", "nav-x-disabled"]
    end

    test "a group's chevron carries the open state, which is otherwise just a glyph" do
      child = MishkaNavLink.nav_link(%{label: "x"}, [])
      closed = MishkaNavLink.nav_link(%{id: "nav-mail", label: "Mail"}, [child])
      open = MishkaNavLink.nav_link(%{id: "nav-mail", label: "Mail", opened: true}, [child])

      assert "nav-mail-closed" in tags(closed)
      assert "nav-mail-open" in tags(open)
      # ▸ and ▾ read identically to a device test, so the tag is the only signal.
      refute "nav-mail-open" in tags(closed)
    end

    test "the row's own tag never moves, so a test can always tap the same node" do
      child = MishkaNavLink.nav_link(%{label: "x"}, [])

      for props <- [
            %{id: "nav-mail", label: "Mail"},
            %{id: "nav-mail", label: "Mail", opened: true, active: true},
            %{id: "nav-mail", label: "Mail", disabled: true}
          ] do
        assert "nav-mail" in tags(MishkaNavLink.nav_link(props, [child]))
      end
    end

    test "no id, no tags — the tree stays exactly as untagged as it was" do
      child = MishkaNavLink.nav_link(%{label: "x"}, [])

      assert tags(MishkaNavLink.nav_link(%{label: "Mail", icon: "✉", opened: true}, [child])) ==
               []
    end

    test "an atom id still tags, because both bridges read the tag as a string" do
      # Android does `props["id"] as? String` and iOS sets an
      # accessibilityIdentifier: an atom would tag nothing and say nothing.
      tree = MishkaNavLink.nav_link(%{id: :nav_mail, label: "Mail"}, [])

      assert tags(tree) == ["nav_mail", "nav_mail-inactive"]
    end
  end

  describe "nav link slots" do
    test "icon and trailing take a node, and it is tagged as a glyph would be" do
      badge = %{type: :box, props: %{width: 24}, children: []}
      avatar = %{type: :box, props: %{width: 20}, children: []}

      tree =
        MishkaNavLink.nav_link(
          %{id: "nav-mail", label: "Mail", icon: avatar, trailing: badge},
          []
        )

      assert tagged(tree, "nav-mail-icon").props[:width] == 20
      assert tagged(tree, "nav-mail-trailing").props[:width] == 24
    end

    test "a node that already names itself keeps its own tag" do
      badge = %{type: :box, props: %{id: "unread-count"}, children: []}
      tree = MishkaNavLink.nav_link(%{id: "nav-mail", label: "Mail", trailing: badge}, [])

      assert "unread-count" in tags(tree)
      refute "nav-mail-trailing" in tags(tree)
    end

    test "a slot holding several nodes arrives in a row that hugs them" do
      pair = [
        %{type: :text, props: %{text: "3"}, children: []},
        %{type: :text, props: %{text: "★"}, children: []}
      ]

      tree = MishkaNavLink.nav_link(%{id: "nav-mail", label: "Mail", trailing: pair}, [])
      row = tagged(tree, "nav-mail-trailing")

      # Not fill_width: a filling row would take the label's width with it.
      assert row.type == :row
      refute row.props[:fill_width]
      assert text(row) =~ "3"
    end

    test "an empty slot is no slot, exactly as the web's :if={@icon != []} has it" do
      tree = MishkaNavLink.nav_link(%{id: "nav-mail", label: "Mail", icon: [], trailing: []}, [])

      assert tags(tree) == ["nav-mail", "nav-mail-inactive"]
    end

    test "a number in a slot reads as its own text rather than raising" do
      tree = MishkaNavLink.nav_link(%{id: "nav-mail", label: "Mail", trailing: 3}, [])

      assert "3" in glyphs(tree)
      assert tagged(tree, "nav-mail-trailing").props.text == "3"
    end

    test "a parent's chevron still wins over a trailing node" do
      badge = %{type: :box, props: %{id: "unread-count"}, children: []}
      child = MishkaNavLink.nav_link(%{label: "x"}, [])
      tree = MishkaNavLink.nav_link(%{id: "nav-mail", label: "Mail", trailing: badge}, [child])

      refute "unread-count" in tags(tree)
      assert "nav-mail-closed" in tags(tree)
    end
  end

  describe "nav link open state" do
    setup do
      %{child: MishkaNavLink.nav_link(%{label: "Inbox"}, [])}
    end

    test "default_opened opens a group nobody controls", %{child: child} do
      tree = MishkaNavLink.nav_link(%{label: "Mail", default_opened: true}, [child])

      assert text(tree) =~ "Inbox"
      assert "▾" in glyphs(tree)
    end

    test "opened wins over default_opened, whichever way it points", %{child: child} do
      shut =
        MishkaNavLink.nav_link(%{label: "Mail", default_opened: true, opened: false}, [child])

      open =
        MishkaNavLink.nav_link(%{label: "Mail", default_opened: false, opened: true}, [child])

      refute text(shut) =~ "Inbox"
      assert text(open) =~ "Inbox"
    end

    test "default_opened cannot open a childless link", %{child: _child} do
      tree = MishkaNavLink.nav_link(%{label: "Solo", default_opened: true}, [])

      refute "▾" in glyphs(tree)
    end
  end

  describe "anchor" do
    test "renders its label with a rule under it" do
      tree = MishkaAnchor.anchor(label: "mishka.tools")

      assert text(tree) =~ "mishka.tools"
      assert find(tree, :box).props.height == 1
    end

    test "the underline can be turned off" do
      refute MishkaAnchor.anchor(label: "x", underline: false) |> find(:box)
    end

    test "children replace the label" do
      icon = [%{type: :text, props: %{text: "★"}, children: []}]
      tree = MishkaAnchor.anchor(%{label: "ignored"}, icon)

      assert text(tree) =~ "★"
      refute text(tree) =~ "ignored"
    end

    test "the tap carries the href, so one handler serves a page of links" do
      with_href = MishkaAnchor.anchor(label: "x", href: "https://a.example", on_tap: :open)
      without = MishkaAnchor.anchor(label: "x", on_tap: :open)

      assert with_href.props.on_tap == {self(), {:open, "https://a.example"}}
      assert without.props.on_tap == {self(), :open}
    end

    test "disabled mutes and unwires" do
      tree = MishkaAnchor.anchor(label: "x", href: "https://a.example", on_tap: :open)

      dead =
        MishkaAnchor.anchor(label: "x", href: "https://a.example", on_tap: :open, disabled: true)

      assert Map.has_key?(tree.props, :on_tap)
      refute Map.has_key?(dead.props, :on_tap)
      assert find(dead, :text).props.text_color == :muted
    end

    test "open/1 refuses anything that is not an http(s) URL" do
      # A component must never hand an arbitrary string to the platform opener.
      for bad <- ["ftp://x.example", "javascript:alert(1)", "/relative", "", nil, 42] do
        assert MishkaAnchor.open(bad) == :error
      end
    end
  end

  describe "menubar" do
    @menus [
      %{
        label: "File",
        value: :file,
        items: [
          %{label: "New", value: :new, shortcut: "⌘N"},
          :separator,
          %{label: "Quit", value: :quit, disabled: true}
        ]
      },
      %{label: "Edit", value: :edit, items: [%{label: "Undo", value: :undo}]},
      %{label: "View", value: :view, items: [], disabled: true}
    ]

    test "renders a trigger per menu and no panel while closed" do
      tree = MishkaMenubar.menubar(menus: @menus)

      assert text(tree) =~ "File"
      assert text(tree) =~ "Edit"
      refute text(tree) =~ "New"
    end

    test "exactly one panel opens, and it is the open one" do
      tree = MishkaMenubar.menubar(menus: @menus, open: :file)

      assert text(tree) =~ "New"
      refute text(tree) =~ "Undo"
    end

    test "open_menu/2 switches without ever leaving two open" do
      assert MishkaMenubar.open_menu(:file, nil) == :file
      assert MishkaMenubar.open_menu(:file, :file) == nil
      assert MishkaMenubar.open_menu(:edit, :file) == :edit
    end

    test "separators render as dividers, not as items" do
      tree = MishkaMenubar.menubar(menus: @menus, open: :file)

      assert find(tree, :divider)
    end

    test "shortcuts render beside their item" do
      assert text(MishkaMenubar.menubar(menus: @menus, open: :file)) =~ "⌘N"
    end

    test "triggers and items report with their value" do
      tree = MishkaMenubar.menubar(menus: @menus, open: :file, on_open: :open, on_select: :pick)

      assert {self(), {:open, :file}} in taps(tree)
      assert {self(), {:pick, :new}} in taps(tree)
    end

    test "a disabled item is muted and inert, while its siblings still work" do
      tree = MishkaMenubar.menubar(menus: @menus, open: :file, on_select: :pick)

      refute {self(), {:pick, :quit}} in taps(tree)
      assert {self(), {:pick, :new}} in taps(tree)
    end

    test "a disabled menu cannot be opened" do
      tree = MishkaMenubar.menubar(menus: @menus, on_open: :open)

      refute {self(), {:open, :view}} in taps(tree)
    end

    test "disabling the bar disables everything on it" do
      tree =
        MishkaMenubar.menubar(
          menus: @menus,
          open: :file,
          disabled: true,
          on_open: :o,
          on_select: :s
        )

      assert taps(tree) == []
    end

    test "an empty bar renders rather than failing" do
      assert_renderable(MishkaMenubar.menubar(menus: []))
    end
  end

  describe "navigation menu" do
    @items [
      %{
        label: "Products",
        value: :products,
        content: [%{type: :text, props: %{text: "panel"}, children: []}]
      },
      %{label: "Blog", value: :blog}
    ]

    test "an item with content is a trigger; without, a plain link" do
      assert MishkaNavigationMenu.trigger?(Enum.at(@items, 0))
      refute MishkaNavigationMenu.trigger?(Enum.at(@items, 1))
    end

    test "only a trigger gets a chevron" do
      tree = MishkaNavigationMenu.navigation_menu(items: @items)
      chevrons = Enum.count(glyphs(tree), &(&1 in ["▸", "▾"]))

      assert chevrons == 1
    end

    test "one shared viewport shows the active content" do
      closed = MishkaNavigationMenu.navigation_menu(items: @items)
      open = MishkaNavigationMenu.navigation_menu(items: @items, value: :products)

      refute text(closed) =~ "panel"
      assert text(open) =~ "panel"
    end

    test "a plain link never opens a viewport, even when it is the value" do
      tree = MishkaNavigationMenu.navigation_menu(items: @items, value: :blog)

      refute text(tree) =~ "panel"
    end

    test "triggers and links report on different tags" do
      tree = MishkaNavigationMenu.navigation_menu(items: @items, on_open: :open, on_link: :go)

      assert {self(), {:open, :products}} in taps(tree)
      assert {self(), {:go, :blog}} in taps(tree)
    end

    test "toggle/2 keeps the viewport to one item" do
      assert MishkaNavigationMenu.toggle(:docs, :docs) == nil
      assert MishkaNavigationMenu.toggle(:docs, :blog) == :docs
    end

    test "orientation switches the bar between a row and a stack" do
      row = MishkaNavigationMenu.navigation_menu(items: @items)
      stack = MishkaNavigationMenu.navigation_menu(items: @items, orientation: :vertical)

      assert row.children |> List.first() |> Map.get(:type) == :row
      assert stack.children |> List.first() |> Map.get(:type) == :column
      assert MishkaNavigationMenu.navigation_menu(items: @items, orientation: "vertical") == stack
    end

    test "disabling the nav disables every item" do
      tree =
        MishkaNavigationMenu.navigation_menu(
          items: @items,
          disabled: true,
          on_open: :o,
          on_link: :l
        )

      assert taps(tree) == []
    end
  end

  describe "visually hidden" do
    test "renders nothing, because nothing it rendered could be announced" do
      node =
        MishkaVisuallyHidden.visually_hidden(%{}, [
          %{type: :text, props: %{text: "screen reader only"}, children: []}
        ])

      assert node.type == :spacer
      refute text(node) =~ "screen reader"
    end

    test "announce?/0 reports the platform truth so callers can branch" do
      refute MishkaVisuallyHidden.announce?()
    end
  end

  test "expand/3 delegates for all five" do
    ctx = %{screen: self()}

    assert MishkaNavLink.expand(%{label: "a"}, [], ctx) ==
             MishkaNavLink.nav_link(%{label: "a"}, [])

    assert MishkaAnchor.expand(%{label: "a"}, [], ctx) == MishkaAnchor.anchor(%{label: "a"}, [])
    assert MishkaMenubar.expand(%{menus: @menus}, [], ctx) == MishkaMenubar.menubar(menus: @menus)

    assert MishkaNavigationMenu.expand(%{items: @items}, [], ctx) ==
             MishkaNavigationMenu.navigation_menu(items: @items)

    assert MishkaVisuallyHidden.expand(%{}, [], ctx) == MishkaVisuallyHidden.visually_hidden()
  end

  test "every variant renders" do
    child = MishkaNavLink.nav_link(%{label: "x"}, [])

    for tree <- [
          MishkaNavLink.nav_link(%{}, []),
          MishkaNavLink.nav_link(%{label: "Mail", opened: true, icon: "✉"}, [child]),
          MishkaAnchor.anchor(),
          MishkaAnchor.anchor(label: "x", disabled: true, underline: false),
          MishkaMenubar.menubar(),
          MishkaMenubar.menubar(menus: @menus, open: :file),
          MishkaNavigationMenu.navigation_menu(),
          MishkaNavigationMenu.navigation_menu(
            items: @items,
            value: :products,
            orientation: :vertical
          ),
          MishkaVisuallyHidden.visually_hidden()
        ] do
      assert_renderable(tree)
    end
  end

  # The gallery page is what the device test drives, so the tags it addresses
  # are pinned here: renaming one on the page breaks this instead of failing on
  # a device twenty minutes later.
  describe "the gallery page" do
    setup do
      Showcase.reset()
      Showcase.register_all()

      %{view: mount_screen(ComponentScreen, %{slug: :nav_link})}
    end

    test "nested links can be written as tags, not only built as functions" do
      # A composite's children reach expand/3 UNEXPANDED, which is what lets a
      # nav link hold nav links: the parent sees one child and becomes a group,
      # and the child expands on the pass after.
      tree = %{
        type: :mishka_nav_link,
        props: %{id: "nav-mail", label: "Mail", opened: true},
        children: [
          %{type: :mishka_nav_link, props: %{id: "nav-inbox", label: "Inbox"}, children: []}
        ]
      }

      expanded = Mob.Composite.expand(tree, self())

      assert "nav-mail-open" in tags(expanded)
      assert "nav-inbox" in tags(expanded)
      assert text(expanded) =~ "Inbox"
    end

    test "every row NavLinkTest addresses is tagged", %{view: view} do
      tags = view |> page() |> tags()

      for tag <- [
            "nav-dash",
            "nav-dash-active",
            "nav-docs",
            "nav-docs-inactive",
            "nav-docs-trailing",
            "nav-settings",
            "nav-mail",
            "nav-mail-closed",
            "nav-team",
            "nav-team-open",
            "nav-alice",
            "nav-reports",
            "nav-reports-trailing",
            "nav-archive",
            "nav-archive-disabled"
          ] do
        assert tag in tags
      end
    end

    test "one handler serves the sidebar, and the active tag follows it", %{view: view} do
      after_tap = view |> render_info({:tap, {:nl_pick, "/docs"}}) |> page() |> tags()

      assert "nav-docs-active" in after_tap
      assert "nav-dash-inactive" in after_tap
      refute "nav-dash-active" in after_tap
    end

    test "toggling the group reveals its children and flips the chevron tag", %{view: view} do
      before = view |> page() |> tags()
      opened = view |> render_info({:tap, :nl_mail}) |> page() |> tags()

      refute "nav-inbox" in before
      assert "nav-inbox" in opened
      assert "nav-mail-open" in opened
      refute "nav-mail-closed" in opened
    end

    test "the disabled row is wired to nothing at all", %{view: view} do
      tree = page(view)

      refute Map.has_key?(tagged(tree, "nav-archive").props, :on_tap)
      assert Map.has_key?(tagged(tree, "nav-reports").props, :on_tap)
      # NavLinkTest reads the mark off the Reports row's own tag rather than a
      # counter: the BEAM outlives the Activity, so a count from an earlier test
      # would still be there, while a flip is true whatever it started as.
      marked = view |> render_info({:tap, :nl_mark}) |> page() |> tags()
      assert "nav-reports-active" in marked
    end

    test "no two examples share an assign, so a tap names the one it moved", %{view: view} do
      moved = view |> render_info({:tap, :nl_mail}) |> assigns()

      assert moved.nl_mail_open
      assert moved.nl_current == "/dashboard"
      assert moved.nl_marked == false
    end

    test "the whole page is renderable once its composites expand", %{view: view} do
      assert_renderable(page(view))
    end
  end

  # The page is written with composite tags; expand them the way the device does.
  defp page(view), do: Mob.Composite.expand(tree(view), self())
end
