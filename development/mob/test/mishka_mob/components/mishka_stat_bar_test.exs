defmodule MishkaMob.Components.MishkaStatBarTest do
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.{MishkaNotificationPreview, MishkaStatBar}

  doctest MishkaMob.Components.MishkaStatBar
  doctest MishkaMob.Components.MishkaNotificationPreview

  describe "the fraction" do
    test "clamps both ends and reads a missing value as empty" do
      assert MishkaStatBar.fraction(0.4) == 0.4
      assert MishkaStatBar.fraction(1.4) == 1.0
      assert MishkaStatBar.fraction(-2) == 0.0
      assert MishkaStatBar.fraction(nil) == 0.0
    end
  end

  describe "the row" do
    test "is a text row over a drawn bar, with the bar tagged" do
      node = MishkaStatBar.stat_bar(label: "Action", value: 0.6, value_text: "6h", id: "hours")

      assert node.type == :column
      assert node.props.id == "hours"

      bar = Enum.find(Mob.ScreenCase.flatten(node), &(&1.type == :box and &1.props[:id] == "hours-bar"))
      assert bar, "the bar did not take the id"
      assert bar.props.height == 6
    end

    test "both texts are optional" do
      texts =
        MishkaStatBar.stat_bar(value: 0.2)
        |> Mob.ScreenCase.flatten()
        |> Enum.filter(&(&1.type == :text))

      assert texts == []
    end

    test "colours, sizes, family and weight are passed through" do
      node =
        MishkaStatBar.stat_bar(
          label: "Storage",
          value_text: "90%",
          label_size: 15,
          label_color: 0xFF112233,
          value_color: 0xFF445566,
          value_weight: "semibold",
          font_family: "mono",
          height: 10,
          corner_radius: 5,
          color: 0xFF16A34A,
          track_color: 0xFFEEEEEE
        )

      flat = Mob.ScreenCase.flatten(node)
      label = Enum.find(flat, &(&1.type == :text and &1.props.text == "Storage"))
      value = Enum.find(flat, &(&1.type == :text and &1.props.text == "90%"))
      bar = Enum.find(flat, &(&1.type == :box and &1.props.height == 10))

      assert label.props.text_size == 15
      assert label.props.text_color == 0xFF112233
      assert value.props.font_weight == "semibold"
      assert label.props.font_family == "mono"
      assert bar, "the bar's height did not reach it"
    end
  end

  describe "the notification preview" do
    test "joins the app and the clock, and takes all four strings" do
      node =
        MishkaNotificationPreview.notification(
          app: "KATI",
          time: "19:15",
          title: "Dinner",
          body: "Prep the miso.",
          icon: "●",
          id: "preview"
        )

      texts = for %{type: :text, props: %{text: text}} <- Mob.ScreenCase.flatten(node), do: text

      assert "KATI · 19:15" in texts
      assert "Dinner" in texts
      assert "Prep the miso." in texts
      assert node.props.id == "preview"
    end

    test "a missing half of the line does not leave a dangling middot" do
      assert MishkaNotificationPreview.app_line("KATI", nil) == "KATI"
      assert MishkaNotificationPreview.app_line(nil, "08:00") == "08:00"
      assert MishkaNotificationPreview.app_line(nil, nil) == nil
    end

    test "a node icon is used as given" do
      icon = %{type: :box, props: %{width: 20, height: 20}, children: []}
      node = MishkaNotificationPreview.notification(title: "x", icon: icon)

      assert Enum.any?(Mob.ScreenCase.flatten(node), &(&1 == icon))
    end
  end

  test "both render empty" do
    assert_renderable(MishkaStatBar.stat_bar())
    assert_renderable(MishkaNotificationPreview.notification())
  end
end
