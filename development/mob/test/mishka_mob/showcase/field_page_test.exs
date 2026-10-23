defmodule MishkaMob.Showcase.FieldPageTest do
  # async: false — the registry and composite registry are global (persistent_term).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.ComponentScreen

  setup do
    Showcase.reset()
    Showcase.register_all()
    :ok
  end

  defp mounted, do: mount_screen(ComponentScreen, %{slug: :field})

  defp expanded(view), do: view |> tree() |> Mob.Composite.expand(self())

  describe "the form's buttons" do
    # Each of two half-row buttons had about 77dp for "Create account" once the
    # node's 16dp padding and the Button's own 24dp on each side were taken off:
    # it drew as "Create …". Stacked, each gets the whole row.
    test "Create account and Reset are not halves of a row" do
      for row <- find_all(expanded(mounted()), :row) do
        buttons = Enum.filter(row.children, &(&1.type == :button))

        assert Enum.count_until(buttons, 2) < 2,
               "a row shares its width between #{inspect(Enum.map(buttons, & &1.props.text))}"
      end
    end

    test "each fills the width and is not wrapped in a weighted Box" do
      tree = expanded(mounted())

      for label <- ["Create account", "Reset"] do
        node = find(tree, :button, text: label)

        assert node.props.fill_width == true

        parent =
          tree
          |> flatten()
          |> Enum.find(fn candidate -> node in candidate.children end)

        refute Map.has_key?(parent.props, :weight),
               "#{label} sits in a box that shares its width"
      end
    end
  end

  describe "the role strip" do
    # A segmented control cannot be empty: `selected/2` falls back to the first
    # option when `value` names none. So Owner IS drawn selected on a form whose
    # role is still nil — by the control's contract, not by a bug — and the form
    # has to say so rather than leave "Pick a role." under a chosen-looking strip.
    test "the first segment is drawn selected while the role is still unanswered" do
      view = mounted() |> render_info({:tap, :fld_submit})

      assert assigns(view).form.role == nil
      assert text(expanded(view)) =~ "Pick a role."

      assert find(expanded(view), :box, id: "fld-role-owner-selected")
      refute find(expanded(view), :box, id: "fld-role-admin-selected")
    end

    test "the example tells the reader that Owner only looks picked" do
      assert text(expanded(mounted())) =~ "Owner looks picked before you tap it"
    end

    test "tapping a role records it and clears the error" do
      view =
        mounted()
        |> render_info({:tap, :fld_submit})
        |> render_info({:tap, {:fld_role, :admin}})

      assert assigns(view).form.role == :admin
      refute text(expanded(view)) =~ "Pick a role."
      assert find(expanded(view), :box, id: "fld-role-admin-selected")
    end
  end
end
