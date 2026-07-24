defmodule MishkaMob.Components.EventTest do
  use ExUnit.Case, async: true

  alias MishkaMob.Components.Event

  describe "handler/1" do
    test "widens a bare tag to {self(), tag} — the only shape the renderer registers" do
      assert Event.handler(:save) == {self(), :save}
    end

    test "leaves an already-wired handler alone, whichever process owns it" do
      other = spawn(fn -> :ok end)

      assert Event.handler({self(), :save}) == {self(), :save}
      assert Event.handler({other, :save}) == {other, :save}
    end

    test "nil stays nil so the prop can be omitted entirely" do
      assert Event.handler(nil) == nil
    end

    test "a non-atom tag is widened too — tags may be tuples" do
      assert Event.handler({:toggle, :item_a}) == {self(), {:toggle, :item_a}}
    end

    test "widening uses the calling process, which at render time is the screen" do
      parent = self()

      task =
        Task.async(fn ->
          send(parent, {:from_task, Event.handler(:x)})
          :ok
        end)

      Task.await(task)
      assert_receive {:from_task, {pid, :x}}
      refute pid == parent
    end
  end
end
