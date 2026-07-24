defmodule MishkaMob.Components.MishkaSwitchTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaSwitch

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
      props = MishkaSwitch.switch(label: "Wi-Fi", color: 0xFF7C3AED, on_change: :wifi).props

      assert props.label == "Wi-Fi"
      assert props.color == 0xFF7C3AED
    end

    test "a bare tag is widened to {pid, tag} — a bare atom never registers" do
      assert MishkaSwitch.switch(on_change: :wifi).props.on_change == {self(), :wifi}
    end

    test "an already-wired handler is left alone" do
      assert MishkaSwitch.switch(on_change: {self(), :wifi}).props.on_change == {self(), :wifi}
    end
  end

  describe "disabled" do
    test "drops the handler, which is what makes a controlled Toggle inert" do
      props = MishkaSwitch.switch(label: "Locked", checked: true, disabled: true).props

      refute Map.has_key?(props, :on_change)
      # it still renders its state and label — only interaction is removed
      assert props.value == true
      assert props.label == "Locked"
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
end
