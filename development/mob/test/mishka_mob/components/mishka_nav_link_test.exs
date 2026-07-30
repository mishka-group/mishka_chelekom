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

  doctest MishkaMob.Components.MishkaAnchor
  doctest MishkaMob.Components.MishkaMenubar
  doctest MishkaMob.Components.MishkaNavigationMenu
  doctest MishkaMob.Components.MishkaVisuallyHidden

  defp glyphs(tree), do: tree |> find_all(:text) |> Enum.map(& &1.props.text)

  defp taps(tree),
    do: tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

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
end
