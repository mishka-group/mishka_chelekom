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

  describe "handler/2 — a tag carrying a per-item value" do
    test "composes a bare tag with its value" do
      assert Event.handler(:check, "lib/app.ex") == {self(), {:check, "lib/app.ex"}}
    end

    test "UNWRAPS an already-widened tag instead of nesting it" do
      # The bug this exists for. Mob.Composite widens on_check={:check} to
      # {screen_pid, :check} before expand/3 runs, so a component reached as a
      # TAG never sees the bare atom. Composing that pair the naive way gave
      # {self(), {{pid, :check}, value}} — the renderer registered it, the tap
      # fired, the message arrived, and the screen's handle({:check, value})
      # clause did not match, so the catch-all swallowed it.
      screen = spawn(fn -> :ok end)

      assert Event.handler({screen, :check}, "lib/app.ex") == {screen, {:check, "lib/app.ex"}}
    end

    test "the two paths agree, which is why the function form never caught it" do
      # Called as a plain function the prop is a bare atom; called as a tag it is
      # already wired. Both must produce the same TAG, or a component behaves
      # differently depending on how it was written.
      {_pid, from_function} = Event.handler(:check, "a")
      {_pid, from_tag} = Event.handler({self(), :check}, "a")

      assert from_function == from_tag
    end

    test "nil stays nil, so a valueless prop is still omitted" do
      assert Event.handler(nil, "anything") == nil
    end

    test "a value may be any term, not just a string" do
      assert Event.handler(:pick, %{id: 1}) == {self(), {:pick, %{id: 1}}}
      assert Event.handler(:pick, 7) == {self(), {:pick, 7}}
    end
  end
end
