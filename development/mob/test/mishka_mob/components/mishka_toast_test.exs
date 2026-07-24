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

  test "expand/3 delegates to toast/1" do
    assert MishkaToast.expand(%{toasts: toasts()}, [], %{screen: self()}) ==
             MishkaToast.toast(toasts: toasts())
  end

  test "every variant renders" do
    for props <- [%{toasts: []}, %{toasts: toasts()}, %{toasts: toasts(), position: :top}] do
      assert_renderable(MishkaToast.toast(props))
    end
  end
end
