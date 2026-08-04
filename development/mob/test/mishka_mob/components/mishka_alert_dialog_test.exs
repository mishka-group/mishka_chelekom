defmodule MishkaMob.Components.MishkaAlertDialogTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  import ExUnit.CaptureLog

  alias MishkaMob.Components.{MishkaAlertDialog, MishkaDialog}

  @scrim 0x99_00_00_00
  @absorb :__mishka_alert_dialog_backdrop

  defp actions, do: [MishkaAlertDialog.action("Cancel", id: "cancel")]
  defp body, do: [%{type: :text, props: %{text: "body text"}, children: []}]

  defp open(extra \\ %{}) do
    props = Map.merge(%{open: true, title: "Discard?", on_close: :cancel}, extra)
    MishkaAlertDialog.alert_dialog(props, body(), actions())
  end

  defp tagged(extra \\ %{}), do: open(Map.put(extra, :id, "ad"))

  defp backdrop(tree), do: find(tree, :box, background: @scrim)

  # A dialog with no actions warns, on purpose. Where that is exactly the shape
  # under test, swallow the log rather than let it litter the run.
  defp quietly(fun) do
    {result, _log} = with_log(fun)
    result
  end

  defp ids(tree) do
    tree
    |> flatten()
    |> Enum.map(&Map.get(&1.props, :id))
    |> Enum.reject(&is_nil/1)
  end

  describe "the one rule that makes it an alert dialog" do
    test "the backdrop absorbs the tap instead of closing" do
      # Not `refute has_key?(:on_tap)`: a Compose Box with a background but no
      # pointer input paints over the page without consuming a touch, so an
      # unhandled backdrop leaks every tap to whatever is underneath — including
      # the button that opened the dialog.
      assert backdrop(open()).props.on_tap == {self(), @absorb}
    end

    test "dismissible: true is ignored, because that would just be a Dialog" do
      assert backdrop(open(%{dismissible: true})).props.on_tap == {self(), @absorb}
    end

    test "on_close never reaches the backdrop, whatever it is set to" do
      refute backdrop(open(%{on_close: :cancel})).props.on_tap == {self(), :cancel}
    end

    test "neither does on_open_change, which is the same dismissal by another name" do
      tree = open(%{on_close: nil, on_open_change: :changed})

      assert backdrop(tree).props.on_tap == {self(), @absorb}
    end

    test "an equivalent Dialog DOES dismiss — the difference is real, not cosmetic" do
      dialog = MishkaDialog.dialog(%{open: true, on_close: :cancel}, body(), actions())

      assert find(dialog, :box, background: @scrim).props.on_tap == {self(), :cancel}
    end

    test "modal is forced too — an alert dialog is never see-through" do
      assert find(tagged(%{modal: false}), :box, id: "ad-backdrop-modal")
      refute find(tagged(%{modal: false}), :box, id: "ad-backdrop-plain")
    end

    test "expanded as a tag, the absorbed tap goes to the SCREEN, not the caller" do
      screen = spawn(fn -> :ok end)

      tree =
        MishkaAlertDialog.expand(
          %{open: true, title: "T", actions: actions()},
          body(),
          %{screen: screen}
        )

      assert backdrop(tree).props.on_tap == {screen, @absorb}
    end

    test "it is a Dialog in every other respect" do
      props = %{id: "ad", open: true, title: "T", description: "D", on_close: :cancel}
      plain = [%{type: :button, props: %{text: "Cancel"}, children: []}]

      alert = MishkaAlertDialog.alert_dialog(props, body(), plain)

      dialog =
        MishkaDialog.dialog(Map.merge(props, %{dismissible: false, modal: true}), body(), plain)

      assert unseal(alert) == dialog
    end
  end

  # Drop the one thing the wrapper adds, so the rest can be compared whole.
  defp unseal(%{children: [backdrop, viewport]} = root) do
    %{root | children: [%{backdrop | props: Map.delete(backdrop.props, :on_tap)}, viewport]}
  end

  describe "testTags" do
    test "every part of an open dialog is addressable" do
      tree = tagged(%{description: "gone forever"})

      parts = ~w(ad-open ad-backdrop-modal ad-panel ad-title ad-description ad-content ad-footer)

      for tag <- parts do
        assert tag in ids(tree), "missing testTag #{tag}"
      end
    end

    test "the tags are Dialog's, so a test need not know which of the two it has" do
      tree = tagged(%{description: "gone forever"})
      dialog = MishkaDialog.dialog(%{id: "ad", open: true, title: "Discard?"}, body(), actions())

      assert ids(dialog) -- ids(tree) == []
    end

    test "the tags land on the right nodes" do
      tree = tagged(%{description: "gone forever"})

      assert text(find(tree, :column, id: "ad-title")) == "Discard?"
      assert text(find(tree, :column, id: "ad-description")) == "gone forever"
      assert text(find(tree, :column, id: "ad-content")) == "body text"
      assert find(tree, :box, id: "ad-backdrop-modal").props.background == @scrim
      assert find(tree, :box, id: "ad-panel").props.width == 320
      assert find(tree, :column, id: "ad-footer")
    end

    test "the open tag exists only while open, which is how a test reads the state" do
      assert find(tagged(), :box, id: "ad-open")

      assert MishkaAlertDialog.alert_dialog(%{id: "ad", open: false}, body(), actions()) ==
               %{type: :column, props: %{}, children: []}
    end

    test "an atom id works too" do
      tree = MishkaAlertDialog.alert_dialog(%{id: :ad, open: true, title: "T"}, [], actions())

      assert "ad-open" in ids(tree)
    end

    test "parts with nothing in them get no tag" do
      tree =
        quietly(fn ->
          MishkaAlertDialog.alert_dialog(%{id: "ad", open: true, title: "T"}, [], [])
        end)

      refute "ad-content" in ids(tree)
      refute "ad-footer" in ids(tree)
      refute "ad-description" in ids(tree)
    end

    test "without an id nothing is tagged at all" do
      untagged = [MishkaAlertDialog.action("Cancel")]

      assert ids(MishkaAlertDialog.alert_dialog(%{open: true, title: "T"}, body(), untagged)) ==
               []
    end
  end

  describe "action/2" do
    test "the variant picks theme tokens, never a literal" do
      assert MishkaAlertDialog.action("Cancel").props.background == :surface_raised
      assert MishkaAlertDialog.action("Ok", variant: :primary).props.background == :primary

      danger = MishkaAlertDialog.action("Delete", variant: :danger).props
      assert danger.background == :error
      assert danger.text_color == :on_error
    end

    test "the variant is folded into the testTag — a fill is not readable" do
      assert MishkaAlertDialog.action("Delete", id: "go", variant: :danger).props.id ==
               "go-danger"

      assert MishkaAlertDialog.action("Cancel", id: "no").props.id == "no-neutral"
      refute Map.has_key?(MishkaAlertDialog.action("Cancel").props, :id)
    end

    test "an explicit on_tap is widened to {pid, tag}" do
      assert MishkaAlertDialog.action("Ok", on_tap: :done).props.on_tap == {self(), :done}
    end
  end

  describe "close: true — the port of data-close" do
    test "an action with no handler of its own fires on_close" do
      assert find(open(), :button, id: "cancel-neutral").props.on_tap == {self(), :cancel}
    end

    test "an action that already knows what it does keeps its handler" do
      tree =
        MishkaAlertDialog.alert_dialog(%{open: true, title: "T", on_close: :cancel}, [], [
          MishkaAlertDialog.action("Delete", id: "go", variant: :danger, on_tap: :really)
        ])

      assert find(tree, :button, id: "go-danger").props.on_tap == {self(), :really}
    end

    test "close: false opts out entirely" do
      tree =
        MishkaAlertDialog.alert_dialog(%{open: true, title: "T", on_close: :cancel}, [], [
          MishkaAlertDialog.action("Details", id: "more", close: false)
        ])

      refute Map.has_key?(find(tree, :button, id: "more-neutral").props, :on_tap)
    end

    test "an action inside the actions slot is wired the same way" do
      tree =
        MishkaAlertDialog.alert_dialog(%{open: true, title: "T", on_close: :cancel}, [
          MishkaAlertDialog.actions([MishkaAlertDialog.action("Cancel", id: "cancel")])
        ])

      assert find(tree, :button, id: "cancel-neutral").props.on_tap == {self(), :cancel}
    end

    test "without an on_close there is nothing to wire" do
      tree = MishkaAlertDialog.alert_dialog(%{open: true, title: "T"}, [], actions())

      refute Map.has_key?(find(tree, :button, id: "cancel-neutral").props, :on_tap)
    end

    test "the close flag never reaches the renderer" do
      refute Map.has_key?(find(open(), :button, id: "cancel-neutral").props, :close)
    end

    test "a node that is not an action is passed through untouched" do
      spacer = %{type: :spacer, props: %{size: 8}, children: []}

      tree =
        MishkaAlertDialog.alert_dialog(%{open: true, title: "T", on_close: :cancel}, [], [spacer])

      assert find(tree, :spacer, size: 8)
    end
  end

  describe "slots" do
    test "title and description take nodes, which is what the web slots are for" do
      heading = %{type: :text, props: %{text: "rich heading"}, children: []}

      tree =
        MishkaAlertDialog.alert_dialog(
          %{id: "ad", open: true},
          [
            MishkaAlertDialog.title([heading]),
            MishkaAlertDialog.description([heading]),
            MishkaAlertDialog.actions([MishkaAlertDialog.action("Got it", id: "ok")])
          ]
        )

      assert text(find(tree, :column, id: "ad-title")) == "rich heading"
      assert text(find(tree, :column, id: "ad-description")) == "rich heading"
      assert find(tree, :button, id: "ok-neutral")
      # No body was passed, and the slots must not have become one.
      refute "ad-content" in ids(tree)
    end

    test "a string slot builds the same node as the shorthand prop" do
      from_slot =
        MishkaAlertDialog.alert_dialog(%{id: "ad", open: true}, [
          MishkaAlertDialog.title("Discard?"),
          MishkaAlertDialog.actions(actions())
        ])

      assert text(find(from_slot, :column, id: "ad-title")) == "Discard?"
    end

    test "actions/1 and Dialog's footer/1 are the same slot under two names" do
      assert MishkaAlertDialog.actions(actions()) == MishkaDialog.footer(actions())

      # Every Dialog slot tag works here too — <MishkaDialogTitle> and friends
      # are written inside an alert dialog verbatim. The one addition is the
      # action tag, which Dialog has no equivalent of.
      assert MishkaDialog.slot_types() -- MishkaAlertDialog.slot_types() == []

      assert MishkaAlertDialog.slot_types() -- MishkaDialog.slot_types() ==
               [:mishka_alert_dialog_action]
    end

    test "no slot type ever reaches the renderer" do
      tree =
        MishkaAlertDialog.alert_dialog(%{open: true}, [
          MishkaAlertDialog.title("T"),
          MishkaAlertDialog.description("D"),
          MishkaAlertDialog.actions([MishkaAlertDialog.action("Ok")])
        ])

      types = tree |> flatten() |> Enum.map(& &1.type) |> Enum.uniq()

      assert Enum.all?(MishkaAlertDialog.slot_types(), &(&1 not in types))
      assert_renderable(tree)
    end
  end

  describe "delegation to Dialog" do
    test "title, description, body and actions all render" do
      tree = open(%{description: "Your edits will be lost."})

      assert text(tree) =~ "Discard?"
      assert text(tree) =~ "Your edits will be lost."
      assert text(tree) =~ "body text"
      assert find(tree, :button, text: "Cancel")
    end

    test "chrome props pass straight through" do
      tree =
        open(%{width: 280, corner_radius: 4, padding: :space_md, background: :surface_raised})

      panel = find(tree, :box, width: 280)

      assert panel.props.corner_radius == 4
      assert panel.props.background == :surface_raised
    end

    test "the scrim colour is the caller's when given" do
      assert find(open(%{scrim_color: 0xCC_00_00_00}), :box, background: 0xCC_00_00_00)
    end

    test "closed renders nothing" do
      assert MishkaAlertDialog.alert_dialog(%{open: false}, body(), actions()) ==
               %{type: :column, props: %{}, children: []}
    end

    test "the panel still absorbs its own stray taps" do
      assert find(open(), :box, width: 320).props.on_tap == {self(), :__mishka_dialog_ignore}
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

    test "warns when opened with nothing to read" do
      log = capture_log(fn -> MishkaAlertDialog.alert_dialog(%{open: true}, [], actions()) end)

      assert log =~ "neither title nor description"
    end

    test "a slot child silences both — it could be either part, so guessing is worse" do
      log =
        capture_log(fn ->
          MishkaAlertDialog.alert_dialog(%{open: true}, [MishkaAlertDialog.actions(actions())])
        end)

      assert log == ""
    end

    test "a title alone is fine — required description is an aria constraint, not a native one" do
      assert capture_log(fn -> open() end) == ""

      assert capture_log(fn ->
               MishkaAlertDialog.alert_dialog(%{open: true, description: "D"}, [], actions())
             end) == ""
    end

    test "a closed dialog is nobody's problem" do
      assert capture_log(fn -> MishkaAlertDialog.alert_dialog(%{open: false}, [], []) end) == ""
    end
  end

  describe "composite tag" do
    test "expand/3 uses the tag's children as the body" do
      tree =
        MishkaAlertDialog.expand(
          %{open: true, title: "T", actions: actions()},
          body(),
          %{screen: self()}
        )

      assert text(tree) =~ "body text"
    end

    test "expand/3 takes the footer from the actions prop" do
      tree =
        MishkaAlertDialog.expand(
          %{id: "ad", open: true, title: "T", actions: actions()},
          body(),
          %{screen: self()}
        )

      assert find(tree, :button, id: "cancel-neutral")
      refute Map.has_key?(find(tree, :box, id: "ad-panel").props, :actions)
    end

    test "a keyword list of props works as well as a map" do
      tree = MishkaAlertDialog.alert_dialog([id: "ad", open: true, title: "T"], [], actions())

      assert find(tree, :box, id: "ad-open")
    end
  end

  describe "the showcase page" do
    alias MishkaMob.Showcase.Components.AlertDialog, as: Page

    defp mounted, do: Page.mount(Mob.Socket.new(MishkaMob.Showcase.ComponentScreen))

    defp after_taps(tags), do: Enum.reduce(tags, mounted(), &Page.handle(&1, &2))

    # The page writes its dialogs as <MishkaAlertDialog> markup with slot-tag
    # children, so `overlay/1` hands back an unexpanded composite. Run the pass
    # the renderer runs before reading testTags off it.
    defp opened(tags) do
      case Page.overlay(after_taps(tags).assigns) do
        nil -> nil
        node -> Mob.Composite.expand(node, self())
      end
    end

    test "every example renders and shows its handler" do
      assigns = mounted().assigns

      for example <- Page.examples() do
        assert_renderable(example.render.(assigns))
        assert example.code =~ "def handle_info", "#{example.title} shows no handler"
      end
    end

    test "each example owns its trigger tag, so a test can say which one it hit" do
      assigns = mounted().assigns
      tags = Enum.flat_map(Page.examples(), &ids(&1.render.(assigns)))

      assert Enum.uniq(tags) == tags

      for tag <- ~w(ad-confirm ad-stubborn ad-delete ad-slots ad-chrome) do
        assert "#{tag}-trigger" in tags
      end
    end

    test "nothing is over the page until a trigger is tapped" do
      refute Page.overlay(mounted().assigns)
    end

    test "each trigger opens its own dialog and only its own" do
      for {tag, id} <- [
            {:ad_confirm_open, "ad-confirm"},
            {:ad_stubborn_open, "ad-stubborn"},
            {:ad_delete_open, "ad-delete"},
            {:ad_slots_open, "ad-slots"},
            {:ad_chrome_open, "ad-chrome"}
          ] do
        overlay = opened([tag])

        assert Enum.filter(ids(overlay), &String.ends_with?(&1, "-open")) == ["#{id}-open"]
        assert_renderable(overlay)
      end
    end

    test "the stubborn dialog is the one that passes dismissible and is refused" do
      overlay = opened([:ad_stubborn_open])

      assert find(overlay, :box, id: "ad-stubborn-backdrop-modal").props.on_tap ==
               {self(), @absorb}
    end

    test "the leak counter carries its count in the tag, not just in its text" do
      assigns = after_taps([:ad_stubborn_leak, :ad_stubborn_leak]).assigns
      example = Enum.at(Page.examples(), 1)

      assert "ad-stubborn-leaks-2" in ids(example.render.(assigns))
    end

    test "cancel and confirm are told apart by the assign each writes" do
      assert after_taps([:ad_confirm_open, :ad_confirm_cancel]).assigns.ad_confirm_choice ==
               "cancel"

      assert after_taps([:ad_confirm_open, :ad_confirm_go]).assigns.ad_confirm_choice == "discard"
      refute after_taps([:ad_confirm_open, :ad_confirm_go]).assigns.ad_confirm
    end

    test "the destructive confirm is the only thing that deletes" do
      refute after_taps([:ad_delete_open, :ad_delete_cancel]).assigns.ad_delete_done
      assert after_taps([:ad_delete_open, :ad_delete_go]).assigns.ad_delete_done
    end

    test "the slot-built dialog is tagged exactly like the string-built ones" do
      overlay = opened([:ad_slots_open])

      for part <- ~w(open backdrop-modal panel title description footer) do
        assert "ad-slots-#{part}" in ids(overlay), "missing testTag ad-slots-#{part}"
      end
    end

    test "the chrome example is the one carrying a body, so -content has a home" do
      overlay = opened([:ad_chrome_open])

      assert "ad-chrome-content" in ids(overlay)
    end

    test "the absorbed backdrop and panel taps change nothing" do
      opened = after_taps([:ad_confirm_open])
      strays = Page.handle(:__mishka_dialog_ignore, Page.handle(@absorb, opened))

      assert strays.assigns == opened.assigns
    end
  end

  test "every variant renders" do
    variants = [
      %{},
      %{description: "D"},
      %{width: 280},
      %{dismissible: true},
      %{id: "ad"},
      %{id: "ad", description: "D", scrim_color: 0xCC_00_00_00}
    ]

    for extra <- variants, do: assert_renderable(open(extra))
  end
end
