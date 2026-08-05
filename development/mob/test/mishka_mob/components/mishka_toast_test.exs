defmodule MishkaMob.Components.MishkaToastTest do
  # async: false — Mob.ScreenCase starts the globally-named `Mob.State`.
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaToast
  alias MishkaMob.Components.MishkaToast.Queue

  doctest MishkaMob.Components.MishkaToast.Queue

  defp toasts do
    [
      %{id: 1, title: "Saved", description: "All good", variant: :success},
      %{id: 2, title: "Failed", variant: :danger}
    ]
  end

  describe "Queue.push/3" do
    test "appends newest last" do
      assert Queue.push([%{id: 1}], %{id: 2}) == [%{id: 1}, %{id: 2}]
    end

    test "limit keeps the newest, dropping the oldest" do
      assert Queue.push([%{id: 1}, %{id: 2}], %{id: 3}, limit: 2) == [%{id: 2}, %{id: 3}]
    end

    test "limit larger than the queue changes nothing" do
      assert Queue.push([%{id: 1}], %{id: 2}, limit: 9) == [%{id: 1}, %{id: 2}]
    end

    test "dedup_key replaces a repeat instead of stacking it" do
      queue = [%{id: 1, title: "Saved"}, %{id: 2, title: "Other"}]
      next = Queue.push(queue, %{id: 3, title: "Saved"}, dedup_key: :title)

      assert next == [%{id: 2, title: "Other"}, %{id: 3, title: "Saved"}]
    end

    test "dedup_key accepts a function" do
      queue = [%{id: 1, kind: :a}]
      next = Queue.push(queue, %{id: 2, kind: :a}, dedup_key: & &1.kind)

      assert next == [%{id: 2, kind: :a}]
    end

    test "a key function returning nil does not collapse unrelated toasts" do
      queue = [%{id: 1}, %{id: 2}]

      assert Queue.push(queue, %{id: 3}, dedup_key: & &1[:group]) ==
               [%{id: 1}, %{id: 2}, %{id: 3}]
    end

    test "a key function still dedups when the key is present" do
      queue = [%{id: 1, group: :a}, %{id: 2, group: :b}]

      assert Queue.push(queue, %{id: 3, group: :a}, dedup_key: & &1[:group]) ==
               [%{id: 2, group: :b}, %{id: 3, group: :a}]
    end

    test "a nil key does not collapse unrelated toasts" do
      queue = [%{id: 1}, %{id: 2}]

      assert Queue.push(queue, %{id: 3}, dedup_key: :title) == [%{id: 1}, %{id: 2}, %{id: 3}]
    end
  end

  describe "Queue.dismiss/2 and expire/3" do
    test "dismiss removes by id and leaves the rest alone" do
      assert Queue.dismiss([%{id: 1}, %{id: 2}], 1) == [%{id: 2}]
      assert Queue.dismiss([%{id: 1}], 99) == [%{id: 1}]
    end

    test "expire drops only what is older than the duration" do
      queue = [%{id: 1, at: 0}, %{id: 2, at: 3_000}]

      assert Queue.expire(queue, 2_000, now: 4_000) == [%{id: 2, at: 3_000}]
    end

    test "a toast with no stamp is sticky and never expires" do
      assert Queue.expire([%{id: 1}], 1, now: 999_999) == [%{id: 1}]
    end

    test "a toast's own :duration overrides the default, both ways" do
      queue = [%{id: 1, at: 0, duration: 500}, %{id: 2, at: 0, duration: 9_000}]

      # The default would keep both; toast 1's own shorter duration expires it.
      assert Queue.expire(queue, 8_000, now: 1_000) == [%{id: 2, at: 0, duration: 9_000}]

      # And a longer one survives a default that would have dropped it.
      assert Queue.expire(queue, 100, now: 1_000) == [%{id: 2, at: 0, duration: 9_000}]
    end

    test "duration: 0 is sticky, matching the web engine" do
      assert Queue.expire([%{id: 1, at: 0, duration: 0}], 1, now: 999_999) ==
               [%{id: 1, at: 0, duration: 0}]
    end
  end

  describe "the viewport" do
    test "renders nothing when there are no toasts" do
      assert MishkaToast.toast(toasts: []) == %{type: :column, props: %{}, children: []}
    end

    test "renders a card per toast with its title and description" do
      tree = MishkaToast.toast(toasts: toasts())

      assert text(tree) =~ "Saved"
      assert text(tree) =~ "All good"
      assert text(tree) =~ "Failed"
    end

    test "each variant tints its accent bar" do
      tree = MishkaToast.toast(toasts: toasts())
      bars = tree |> find_all(:box) |> Enum.filter(&(&1.props[:width] == 4))

      assert Enum.map(bars, & &1.props.background) ==
               [MishkaToast.accent(:success), MishkaToast.accent(:danger)]
    end

    test "an unknown variant falls back to info rather than crashing" do
      assert MishkaToast.accent(:nonsense) == MishkaToast.accent(:info)
    end

    test "the dismiss tag carries the toast id" do
      tree = MishkaToast.toast(toasts: toasts(), on_dismiss: :drop)

      taps =
        tree |> find_all(:box) |> Enum.map(& &1.props[:on_tap]) |> Enum.reject(&is_nil/1)

      assert [{pid, {:drop, 1}}, {_, {:drop, 2}}] = taps
      assert pid == self()
    end

    test "no on_dismiss renders no close buttons" do
      tree = MishkaToast.toast(toasts: toasts())

      assert tree |> find_all(:box) |> Enum.all?(&(&1.props[:on_tap] == nil))
    end
  end

  describe "position" do
    test "bottom pushes the stack down; top pushes it up" do
      bottom = MishkaToast.toast(toasts: toasts(), position: :bottom)
      top = MishkaToast.toast(toasts: toasts(), position: :top)

      assert %{type: :spacer, props: %{weight: 1}} = hd(find(bottom, :column).children)
      assert %{type: :spacer, props: %{weight: 1}} = List.last(find(top, :column).children)
    end
  end

  test "expand/3 with no children delegates to toast/1" do
    assert MishkaToast.expand(%{toasts: toasts()}, [], %{screen: self()}) ==
             MishkaToast.toast(toasts: toasts())
  end

  describe "the card's flexible body" do
    # Regression: the body used fill_width while sitting before the fixed-width
    # ✕ in the same Row. A Compose Row measures a non-weighted child against the
    # space left over, so a fillMaxWidth body took the whole row and the close
    # button was measured at width 0 — present but zero-wide and untappable on
    # Android. iOS was unaffected, which is what made it survive review.
    test "takes weight, not fill_width, so the close button keeps its width" do
      tree = MishkaToast.toast(toasts: toasts(), on_dismiss: :drop)
      bodies = tree |> find_all(:box) |> Enum.filter(&(&1.props[:weight] == 1))

      assert [_, _] = bodies
      assert Enum.all?(bodies, &(&1.props[:fill_width] == nil))
    end

    test "the close button still declares its own fixed width" do
      tree = MishkaToast.toast(toasts: toasts(), on_dismiss: :drop)
      closes = tree |> find_all(:box) |> Enum.filter(&(&1.props[:on_tap] != nil))

      assert Enum.all?(closes, &(&1.props[:width] == 32))
    end
  end

  describe "slots" do
    test "a MishkaToastItem child renders as a toast, body and all" do
      item = %{
        type: :mishka_toast_item,
        props: %{id: :welcome, title: "Welcome", variant: :info},
        children: [%{type: :text, props: %{text: "In markup"}, children: []}]
      }

      tree = MishkaToast.expand(%{toasts: []}, [item], %{screen: self()})

      assert text(tree) =~ "Welcome"
      assert text(tree) =~ "In markup"
    end

    test "static items render before the queued ones" do
      item = %{type: :mishka_toast_item, props: %{title: "Static"}, children: []}
      tree = MishkaToast.expand(%{toasts: toasts()}, [item], %{screen: self()})
      titles = tree |> find_all(:text) |> Enum.map(& &1.props[:text])

      assert Enum.find_index(titles, &(&1 == "Static")) <
               Enum.find_index(titles, &(&1 == "Saved"))
    end

    test "a slot tag is consumed — no marker node reaches the renderer" do
      item = %{type: :mishka_toast_item, props: %{title: "Static"}, children: []}
      tree = MishkaToast.expand(%{toasts: []}, [item], %{screen: self()})

      assert find_all(tree, :mishka_toast_item) == []
      assert_renderable(tree)
    end

    test "MishkaToastClose content replaces the glyph on every card" do
      close = %{
        type: :mishka_toast_close,
        props: %{},
        children: [%{type: :text, props: %{text: "Dismiss"}, children: []}]
      }

      tree =
        MishkaToast.expand(%{toasts: toasts(), on_dismiss: :drop}, [close], %{screen: self()})

      # One per card — the close slot replaces the glyph on every toast.
      assert [_, _] = find_all(tree, :text, text: "Dismiss")
      refute text(tree) =~ "✕"
    end

    test "close slot content is not squeezed into the icon's square" do
      close = %{
        type: :mishka_toast_close,
        props: %{},
        children: [%{type: :text, props: %{text: "Dismiss"}, children: []}]
      }

      tree =
        MishkaToast.expand(%{toasts: toasts(), on_dismiss: :drop}, [close], %{screen: self()})

      # Regression: the content used to go inside action_icon's 32×32 Box, which
      # clipped "Dismiss" to "Dis" on a device. A hugging Row carries the tap
      # instead — so no fixed-size box may own the dismiss handler.
      taps = tree |> find_all(:box) |> Enum.filter(&(&1.props[:on_tap] != nil))
      assert taps == []

      rows = tree |> find_all(:row) |> Enum.filter(&(&1.props[:on_tap] != nil))
      assert [_, _] = rows
      assert Enum.all?(rows, &(&1.props[:width] == nil and &1.props[:fill_width] == nil))
    end

    test "a queued toast's :content renders below its title, not instead of it" do
      queued = [
        %{
          id: 1,
          title: "Kept",
          content: [%{type: :text, props: %{text: "Body node"}, children: []}]
        }
      ]

      titles = MishkaToast.toast(toasts: queued) |> find_all(:text) |> Enum.map(& &1.props[:text])

      assert "Kept" in titles
      assert "Body node" in titles

      assert Enum.find_index(titles, &(&1 == "Kept")) <
               Enum.find_index(titles, &(&1 == "Body node"))
    end

    test "content with no title is the whole card" do
      queued = [%{id: 1, content: [%{type: :text, props: %{text: "Only"}, children: []}]}]
      texts = MishkaToast.toast(toasts: queued) |> find_all(:text) |> Enum.map(& &1.props[:text])

      assert texts == ["Only"]
    end
  end

  describe "close_icon" do
    test "defaults to ✕ and is overridable" do
      assert MishkaToast.toast(toasts: toasts(), on_dismiss: :drop) |> text() =~ "✕"

      assert MishkaToast.toast(toasts: toasts(), on_dismiss: :drop, close_icon: "×")
             |> text() =~ "×"
    end
  end

  test "every variant renders" do
    for props <- [%{toasts: []}, %{toasts: toasts()}, %{toasts: toasts(), position: :top}] do
      assert_renderable(MishkaToast.toast(props))
    end
  end
end
