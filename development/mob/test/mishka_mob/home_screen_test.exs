defmodule MishkaMob.HomeScreenTest do
  # Tier-1 screen test: drives the screen in the BEAM, no device or emulator
  # needed. `use Mob.ScreenCase` gives mount_screen/3, render_event/3,
  # render_info/2, assigns/1, the tree queries (find / text / flatten), and
  # assert_renderable/2. See the `Mob.ScreenCase` docs for the full surface and
  # the testing-pyramid guidance: this is the fast tier you want most tests in.
  #
  # async: false because the home screen reads and writes the shared theme in
  # Mob.State. A screen that keeps all its state in assigns can use async: true.
  use Mob.ScreenCase, async: false

  alias MishkaMob.HomeScreen

  test "mounts and renders a tree the native layer can draw" do
    view = mount_screen(HomeScreen)
    # Asserts every node the screen emits is a type Compose / SwiftUI renders.
    assert_renderable(view)
  end

  test "switching to the light theme updates the assign" do
    view = HomeScreen |> mount_screen() |> render_info({:tap, :theme_light})
    assert assigns(view).theme == :light
  end

  test "switching to the material3 theme updates the assign" do
    view = HomeScreen |> mount_screen() |> render_info({:tap, :theme_material3})
    assert assigns(view).theme == :material3
  end

  test "switching to the liquid glass theme updates the assign" do
    view = HomeScreen |> mount_screen() |> render_info({:tap, :theme_glass})
    assert assigns(view).theme == :glass
  end
end
