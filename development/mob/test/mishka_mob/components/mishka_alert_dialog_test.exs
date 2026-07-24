defmodule MishkaMob.Components.MishkaAlertDialogTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  import ExUnit.CaptureLog

  alias MishkaMob.Components.{MishkaAlertDialog, MishkaDialog}

  @scrim 0x99_00_00_00

  defp actions, do: [%{type: :button, props: %{text: "Cancel"}, children: []}]
  defp body, do: [%{type: :text, props: %{text: "body text"}, children: []}]

  defp open(extra \\ %{}) do
    props = Map.merge(%{open: true, title: "Discard?", on_close: :cancel}, extra)
    MishkaAlertDialog.alert_dialog(props, body(), actions())
  end

  describe "the one rule that makes it an alert dialog" do
    test "the backdrop is inert — no handler at all" do
      refute Map.has_key?(find(open(), :box, background: @scrim).props, :on_tap)
    end

    test "dismissible: true is ignored, because that would just be a Dialog" do
      refute Map.has_key?(
               find(open(%{dismissible: true}), :box, background: @scrim).props,
               :on_tap
             )
    end

    test "an equivalent Dialog DOES dismiss — the difference is real, not cosmetic" do
      dialog = MishkaDialog.dialog(%{open: true, on_close: :cancel}, body(), actions())

      assert find(dialog, :box, background: @scrim).props.on_tap == {self(), :cancel}
    end
  end

  describe "delegation to Dialog" do
    test "renders the same tree as a non-dismissible Dialog" do
      props = %{open: true, title: "Discard?", on_close: :cancel}

      assert MishkaAlertDialog.alert_dialog(props, body(), actions()) ==
               MishkaDialog.dialog(Map.put(props, :dismissible, false), body(), actions())
    end

    test "title, description, body and actions all render" do
      tree = open(%{description: "Your edits will be lost."})

      assert text(tree) =~ "Discard?"
      assert text(tree) =~ "Your edits will be lost."
      assert text(tree) =~ "body text"
      assert find(tree, :button, text: "Cancel")
    end

    test "chrome props pass straight through" do
      tree = open(%{width: 280, corner_radius: 4})

      assert find(tree, :box, width: 280).props.corner_radius == 4
    end

    test "closed renders nothing" do
      assert MishkaAlertDialog.alert_dialog(%{open: false}, body(), actions()) ==
               %{type: :column, props: %{}, children: []}
    end
  end

  describe "an alert dialog with no way out" do
    test "warns when opened with no actions — the user would be trapped" do
      log =
        capture_log(fn ->
          MishkaAlertDialog.alert_dialog(%{open: true, title: "Stuck"}, body(), [])
        end)

      assert log =~ "no actions"
    end

    test "does not warn when it has actions, or when closed" do
      assert capture_log(fn -> open() end) == ""

      assert capture_log(fn ->
               MishkaAlertDialog.alert_dialog(%{open: false}, body(), [])
             end) == ""
    end
  end

  describe "composite tag" do
    test "expand/3 uses the tag's children as the body" do
      tree = MishkaAlertDialog.expand(%{open: true, title: "T"}, body(), %{screen: self()})

      assert text(tree) =~ "body text"
      refute Map.has_key?(find(tree, :box, background: @scrim).props, :on_tap)
    end
  end

  test "every variant renders" do
    for extra <- [%{}, %{description: "D"}, %{width: 280}, %{dismissible: true}] do
      assert_renderable(open(extra))
    end
  end
end
