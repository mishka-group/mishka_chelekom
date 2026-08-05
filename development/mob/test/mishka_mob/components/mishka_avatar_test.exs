defmodule MishkaMob.Components.MishkaAvatarTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaAvatar

  doctest MishkaMob.Components.MishkaAvatar

  describe "shape radius" do
    test "a circle is exactly half the size, at any size" do
      assert MishkaAvatar.radius(:circle, 44) == 22.0
      assert MishkaAvatar.radius(:circle, 100) == 50.0
    end

    test "square is flat and rounded is a fixed radius" do
      assert MishkaAvatar.radius(:square, 44) == 0
      assert MishkaAvatar.radius(:rounded, 44) == 10
      assert MishkaAvatar.radius(:rounded, 100) == 10
    end

    test "the rendered avatar carries the resolved radius" do
      assert MishkaAvatar.avatar(initials: "SH", size: 60).props.corner_radius == 30.0
      assert MishkaAvatar.avatar(initials: "SH", shape: :square).props.corner_radius == 0
    end
  end

  describe "fallback only (no src)" do
    test "is a single square box holding the initials, centred" do
      node = MishkaAvatar.avatar(initials: "SH")

      assert node.type == :box
      assert node.props.width == 44
      assert node.props.height == 44
      assert node.props.align == :center
      assert text(node) =~ "SH"
    end

    test "no image is rendered" do
      assert find_all(MishkaAvatar.avatar(initials: "SH"), :image) == []
    end

    test "colours and text size are overridable" do
      node =
        MishkaAvatar.avatar(
          initials: "SH",
          background: 0xFF7C3AED,
          color: 0xFFFFFFFF,
          text_size: :xl
        )

      assert node.props.background == 0xFF7C3AED
      assert find(node, :text).props.text_color == 0xFFFFFFFF
      assert find(node, :text).props.text_size == :xl
    end

    test "missing initials render an empty label rather than nil" do
      assert find(MishkaAvatar.avatar(%{}), :text).props.text == ""
    end
  end

  describe "with a src" do
    test "stacks the fallback UNDER the image, so initials show until it paints" do
      node = MishkaAvatar.avatar(src: "https://example.com/me.png", initials: "SH")

      assert node.type == :box
      assert [%{type: :box}, %{type: :image}] = node.children
      # the fallback is still there, underneath
      assert text(node) =~ "SH"
    end

    test "the image fills the square and shares the avatar's radius" do
      image = find(MishkaAvatar.avatar(src: "u", initials: "SH", size: 64), :image)

      assert image.props.src == "u"
      assert image.props.width == 64
      assert image.props.height == 64
      assert image.props.corner_radius == 32.0
      # "fill" crops to the square instead of letterboxing a non-square photo
      assert image.props.content_mode == "fill"
    end
  end

  describe "custom fallback content" do
    test "children replace the initials" do
      icon = [%{type: :text, props: %{text: "★"}, children: []}]
      node = MishkaAvatar.avatar(%{initials: "SH"}, icon)

      assert text(node) =~ "★"
      refute text(node) =~ "SH"
    end

    test "expand/3 uses the tag's children as the fallback" do
      icon = [%{type: :text, props: %{text: "★"}, children: []}]

      assert MishkaAvatar.expand(%{size: 40}, icon, %{screen: self()}) ==
               MishkaAvatar.avatar(%{size: 40}, icon)
    end
  end

  test "every variant renders" do
    for {props, fallback} <- [
          {%{}, []},
          {%{initials: "SH"}, []},
          {%{src: "u", initials: "SH"}, []},
          {%{shape: :square, size: 80}, []},
          {%{initials: "SH"}, [%{type: :text, props: %{text: "★"}, children: []}]}
        ] do
      assert_renderable(MishkaAvatar.avatar(props, fallback))
    end
  end

  test "an id becomes a testTag, with or without an image" do
    # An avatar showing an IMAGE renders no text at all, so this is the only
    # handle a device test has on it.
    assert MishkaAvatar.avatar(initials: "SH", id: "me").props.id == "me"
    assert MishkaAvatar.avatar(src: "u", initials: "SH", id: "me").props.id == "me"
    refute Map.has_key?(MishkaAvatar.avatar(initials: "SH").props, :id)
  end
end
