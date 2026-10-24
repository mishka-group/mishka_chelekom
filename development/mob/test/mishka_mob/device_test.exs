defmodule MishkaMob.DeviceTest do
  # The device driver's own logic that needs no phone: polling, receipts, geometry.
  # What needs one is in test/device/harness_test.exs.
  use ExUnit.Case, async: true

  alias MishkaMob.Device
  alias Mob.Agent.Receipt

  describe "assert_eventually/2" do
    test "returns the value as soon as the condition holds" do
      attempts = :counters.new(1, [])

      value =
        Device.assert_eventually(fn ->
          :counters.add(attempts, 1, 1)
          if :counters.get(attempts, 1) >= 3, do: :ready
        end)

      assert value == :ready
      assert :counters.get(attempts, 1) == 3
    end

    test "treats a failing assertion inside the condition as not yet" do
      attempts = :counters.new(1, [])

      assert :ok =
               Device.assert_eventually(fn ->
                 :counters.add(attempts, 1, 1)
                 assert :counters.get(attempts, 1) >= 2
                 :ok
               end)
    end

    test "fails with the message and the last thing it saw once the time is up" do
      error =
        assert_raise ExUnit.AssertionError, fn ->
          Device.assert_eventually(fn -> false end, timeout: 30, message: "the panel never came")
        end

      assert error.message =~ "the panel never came (waited 30ms)"
      assert error.message =~ "last attempt returned: false"
    end

    test "carries the failed assertion's own message into the failure" do
      error =
        assert_raise ExUnit.AssertionError, fn ->
          Device.assert_eventually(fn -> assert 1 == 2, "one is not two" end, timeout: 20)
        end

      assert error.message =~ "last attempt failed with: one is not two"
    end

    test "lets any other exception through at once instead of polling on it" do
      started = System.monotonic_time(:millisecond)

      assert_raise ArgumentError, fn ->
        Device.assert_eventually(fn -> raise ArgumentError, "boom" end, timeout: 5_000)
      end

      assert System.monotonic_time(:millisecond) - started < 1_000
    end
  end

  describe "new_receipts/2" do
    @newest_first [%Receipt{action_id: "c"}, %Receipt{action_id: "b"}, %Receipt{action_id: "a"}]

    test "keeps what arrived after the receipt seen before the action" do
      assert ["c", "b"] = @newest_first |> Device.new_receipts("a") |> Enum.map(& &1.action_id)
    end

    test "is empty when nothing arrived" do
      assert [] = Device.new_receipts(@newest_first, "c")
    end

    test "is everything held when there was no receipt before" do
      assert [_, _, _] = Device.new_receipts(@newest_first, nil)
    end
  end

  describe "center/1 and tree_has_text?/2" do
    test "the centre of a frame is half way along each side" do
      frame = %{left: 10.0, top: 20.0, right: 30.0, bottom: 60.0, width: 20.0, height: 40.0}

      assert Device.center(frame) == {20.0, 40.0}
    end

    test "text is found in a string prop at any depth, and not in a handler" do
      tree = %{
        type: :column,
        props: %{},
        children: [
          %{
            type: :box,
            props: %{on_tap: {self(), :open}},
            children: [%{type: :text, props: %{text: "Order details"}, children: []}]
          }
        ]
      }

      assert Device.tree_has_text?(tree, "details")
      refute Device.tree_has_text?(tree, "shipped")
    end
  end
end
