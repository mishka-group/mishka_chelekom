defmodule MishkaMob.HomeScreenTest do
  # async: false — the home screen reads/writes the shared theme in Mob.State.
  use Mob.ScreenCase, async: false

  alias MishkaMob.HomeScreen

  test "mounts and renders a tree the native layer can draw" do
    view = mount_screen(HomeScreen)
    assert_renderable(view)
  end

  test "shows the Mishka section and the compact demos section" do
    view = mount_screen(HomeScreen)
    text = String.downcase(text(view))
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
