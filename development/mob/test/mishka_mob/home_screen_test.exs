defmodule MishkaMob.HomeScreenTest do
  # async: false — the home screen reads/writes the shared theme in Mob.State.
  use Mob.ScreenCase, async: false

  alias MishkaMob.HomeScreen

  test "mounts and renders a tree the native layer can draw" do
    view = mount_screen(HomeScreen)

    # :canvas is missing from mob 0.7.20's priv/tags whitelist, but both bridges
    # render it; the whitelist is stale, not the node. See MishkaMob.ShowcaseTest.
    assert_renderable(view, extra: [:canvas])
  end

  test "shows the Mishka section and the compact demos section" do
    view = mount_screen(HomeScreen)

    # The home screen is one top-level `:list` (see Mob.List) so the native
    # side only inflates the visible rows — `render/1` itself returns
    # `children: []`, with the real content in `props.items`. `Mob.Screen`
    # expands that at runtime before it ever reaches native; do the same
    # expansion here so the assertion sees what the device actually shows.
    list_renderers = view.socket.__mob__[:list_renderers] || %{}
    expanded = Mob.List.expand(tree(view), list_renderers, self())

    text = String.downcase(text(expanded))
    assert text =~ "mishka chelekom"
    assert text =~ "demos & device"
  end

  test "the theme selector switches (and persists) the theme" do
    for key <- [:light, :material3, :glass, :dark] do
      view = HomeScreen |> mount_screen() |> render_info({:tap, {:set_theme, key}})
      assert assigns(view).theme == key
      assert MishkaMob.ThemeBar.current() == key
    end
  end
end
