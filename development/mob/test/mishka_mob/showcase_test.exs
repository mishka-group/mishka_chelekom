defmodule MishkaMob.ShowcaseTest do
  # async: false — the registry and composite registry are global (persistent_term).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaDrawer
  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.{ComponentScreen, GalleryScreen}

  setup do
    Mob.Composite.register(:mishka_drawer, {MishkaDrawer, :expand})
    Showcase.reset()
    Showcase.register(MishkaMob.Showcase.Components.Drawer)
    :ok
  end

  defp expanded(view), do: Mob.Composite.expand(tree(view), self())
  defp drawer_node(view), do: find(view, :mishka_drawer)

  describe "registry" do
    test "register + lookup augments the entry with its module" do
      entry = Showcase.get(:drawer)
      assert entry.slug == :drawer
      assert entry.name == "Drawer"
      assert entry.category == "Overlays"
      assert entry.module == MishkaMob.Showcase.Components.Drawer
    end

    test "by_category groups and sorts" do
      assert [{"Overlays", [%{slug: :drawer}]}] = Showcase.by_category()
    end

    test "unknown slug returns nil" do
      assert Showcase.get(:nope) == nil
    end
  end

  describe "GalleryScreen" do
    test "lists registered components and is renderable" do
      view = mount_screen(GalleryScreen)

      assert_renderable(view)
      assert text(view) =~ "Components"
      # a tappable row per component, labelled by name
      assert find(view, :button, text: "Drawer")
    end
  end

  describe "ComponentScreen" do
    test "loads the entry from the slug param and renders its examples + code" do
      view = mount_screen(ComponentScreen, %{slug: :drawer})

      assert assigns(view).entry.slug == :drawer
      assert assigns(view).drawer_open? == false
      assert_renderable(expanded(view))
      assert text(view) =~ "Open from any side"
      assert text(view) =~ "Rounded bottom sheet"
      # the example code is shown verbatim as text
      assert text(view) =~ "MishkaDrawer"
    end

    test "opening delegates to the component and stacks the overlay" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :drawer})
        |> render_info({:tap, {:open, :right, :default}})

      assert assigns(view).drawer_open? == true
      assert assigns(view).drawer_side == :right

      labels = expanded(view) |> find_all(:button) |> Enum.map(& &1.props[:text])
      assert Enum.any?(labels, &(&1 =~ "Profile"))
      assert_renderable(expanded(view))
    end

    test "every example opens a distinct, visible drawer variant" do
      base = mount_screen(ComponentScreen, %{slug: :drawer})

      sides = base |> render_info({:tap, {:open, :right, :default}}) |> drawer_node()
      assert sides.props.open == true
      assert sides.props.side == :right
      refute Map.has_key?(sides.props, :corner_radius)

      sheet = base |> render_info({:tap, {:open, :bottom, :sheet}}) |> drawer_node()
      assert sheet.props.open == true
      assert sheet.props.side == :bottom
      assert sheet.props.corner_radius == :radius_lg

      custom = base |> render_info({:tap, {:open, :left, :custom}}) |> drawer_node()
      assert custom.props.open == true
      assert custom.props.side == :left
      assert custom.props.header == false

      colors = base |> render_info({:tap, {:open, :left, :colors}}) |> drawer_node()
      assert colors.props.open == true
      assert colors.props.background == 0xFF7C3AED
      assert colors.props.scrim_color == 0x992E1065
    end

    test "the custom-chrome variant supplies its own account header (header: false)" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :drawer})
        |> render_info({:tap, {:open, :left, :custom}})

      # the built-in title/✕ is off; a bespoke account header is rendered instead
      assert drawer_node(view).props.header == false
      assert text(expanded(view)) =~ "Shahryar"
    end

    test "declares a props reference that the ComponentScreen renders" do
      props = MishkaMob.Showcase.Components.Drawer.props()
      assert length(props) >= 8
      assert Enum.all?(props, &is_binary(&1.name))
      assert Enum.any?(props, &(&1.name == "side"))

      view = mount_screen(ComponentScreen, %{slug: :drawer})
      assert text(view) =~ "Props"
      assert text(view) =~ "scrim_color"
      assert text(view) =~ "on_close"
    end

    test "standalone example triggers are full-width, not weight (so they don't collapse)" do
      view = mount_screen(ComponentScreen, %{slug: :drawer})
      open_sheet = find(view, :button, text: "Open bottom sheet")

      assert open_sheet.props.fill_width == true
      refute Map.has_key?(open_sheet.props, :weight)
    end

    test "the drawer ships a bespoke card face (not the generic skeleton)" do
      preview = MishkaMob.Showcase.Components.Drawer.card_preview()
      assert preview.type == :column
      # the mini drawer's side panel is a fixed-width box
      assert find(preview, :box, width: 66)
    end

    test "closing hides the overlay again" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :drawer})
        |> render_info({:tap, {:open, :bottom, :sheet}})
        |> render_info({:tap, :close_drawer})

      assert assigns(view).drawer_open? == false
      labels = expanded(view) |> find_all(:button) |> Enum.map(& &1.props[:text])
      refute Enum.any?(labels, &(&1 =~ "Profile"))
    end

    test "unknown slug renders a not-found page (still renderable)" do
      view = mount_screen(ComponentScreen, %{slug: :ghost})

      assert assigns(view).entry == nil
      assert_renderable(expanded(view))
      assert text(view) =~ "Not found"
    end
  end
end
