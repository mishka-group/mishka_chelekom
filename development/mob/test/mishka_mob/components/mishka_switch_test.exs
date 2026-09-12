defmodule MishkaMob.Components.MishkaSwitchTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaSwitch

  doctest MishkaMob.Components.MishkaSwitch

  describe "native mapping" do
    test "is Mob's Toggle widget, not a hand-built track and thumb" do
      assert %{type: :toggle, children: []} = MishkaSwitch.switch()
    end

    test "checked becomes the widget's value, defaulting to off" do
      assert MishkaSwitch.switch().props.value == false
      assert MishkaSwitch.switch(checked: true).props.value == true
    end

    test "truthiness is normalised, so a nil assign reads as off" do
      assert MishkaSwitch.switch(checked: nil).props.value == false
      assert MishkaSwitch.switch(checked: "yes").props.value == true
    end

    test "accepts a map as well as a keyword list" do
      assert MishkaSwitch.switch(%{checked: true}) == MishkaSwitch.switch(checked: true)
    end
  end

  describe "optional props are omitted rather than sent as nil" do
    test "no label, colour or handler by default" do
      props = MishkaSwitch.switch().props

      refute Map.has_key?(props, :label)
      refute Map.has_key?(props, :color)
      refute Map.has_key?(props, :on_change)
    end

    test "each is passed through when given" do
      # A labelled switch is a Row: the label is a real Text built here, not a
      # `label` prop on the native Toggle, which iOS never decodes.
      tree = MishkaSwitch.switch(label: "Wi-Fi", color: 0xFF7C3AED, on_change: :wifi)

      assert text(tree) =~ "Wi-Fi"
      assert find(tree, :toggle).props.color == 0xFF7C3AED
      refute Map.has_key?(find(tree, :toggle).props, :label)
    end

    test "a bare tag is widened to {pid, tag} — a bare atom never registers" do
      assert find(MishkaSwitch.switch(on_change: :wifi), :toggle).props.on_change ==
               {self(), :wifi}
    end

    test "an already-wired handler is left alone" do
      assert find(MishkaSwitch.switch(on_change: {self(), :wifi}), :toggle).props.on_change ==
               {self(), :wifi}
    end
  end

  describe "disabled" do
    test "drops the handler, which is what makes a controlled Toggle inert" do
      tree = MishkaSwitch.switch(label: "Locked", checked: true, disabled: true)
      props = find(tree, :toggle).props

      assert text(tree) =~ "Locked"

      refute Map.has_key?(props, :on_change)
      # it still renders its state and label — only interaction is removed
      assert props.value == true
    end

    test "disabled: false keeps the handler" do
      assert MishkaSwitch.switch(on_change: :x, disabled: false).props.on_change == {self(), :x}
    end
  end

  describe "composite tag" do
    test "expand/3 delegates to switch/1 and ignores children" do
      children = [%{type: :text, props: %{text: "ignored"}, children: []}]

      assert MishkaSwitch.expand(%{checked: true}, children, %{screen: self()}) ==
               MishkaSwitch.switch(checked: true)
    end
  end

  test "every variant renders" do
    for props <- [%{}, %{checked: true}, %{label: "L"}, %{disabled: true}, %{color: :primary}] do
      assert_renderable(MishkaSwitch.switch(props))
    end
  end

  describe "colour" do
    test "color and track_color reach the node separately" do
      node = MishkaSwitch.switch(color: 0xFFFDE68A, track_color: 0xFF7C3AED)

      assert node.props.color == 0xFFFDE68A
      assert node.props.track_color == 0xFF7C3AED
    end

    test "an unset colour is omitted rather than sent as nil" do
      # The bridge keeps M3's default for anything Unspecified, so sending a nil
      # would flatten the half the caller did not ask to change.
      node = MishkaSwitch.switch(color: 0xFFFDE68A)

      assert node.props.color == 0xFFFDE68A
      refute Map.has_key?(node.props, :track_color)

      bare = MishkaSwitch.switch(%{})
      refute Map.has_key?(bare.props, :color)
      refute Map.has_key?(bare.props, :track_color)
    end
  end
end
