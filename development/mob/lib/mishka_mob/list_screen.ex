defmodule MishkaMob.ListScreen do
  @moduledoc "Rock Paper Scissors — each round is persisted with Ecto + SQLite."
  use Mob.Screen
  import Ecto.Query

  @choices ~w(rock paper scissors)
  @emoji %{"rock" => "🪨", "paper" => "📄", "scissors" => "✂️"}

  # ── Mount ─────────────────────────────────────────────────────────────────────

  def mount(_params, _session, socket) do
    socket =
      socket
      |> Mob.Socket.assign(:rounds, load_rounds())
      |> Mob.Socket.assign(:pending, nil)
      |> Mob.List.put_renderer(:history, &history_row/1)

    {:ok, socket}
  end

  # ── Render ────────────────────────────────────────────────────────────────────

  def render(assigns) do
    score = tally(assigns.rounds)
    last = List.first(assigns.rounds)
    pending = assigns.pending

    # Left side of the arena: user's pick (or last pick, or idle)
    user_emoji =
      cond do
        pending -> @emoji[pending.user]
        last -> @emoji[last.user_choice]
        true -> "🤔"
      end

    # Right side: spinner while the computer is "thinking", emoji once revealed
    cpu_widget =
      cond do
        pending -> :spinner
        last -> @emoji[last.computer_choice]
        true -> "🤔"
      end

    busy = not is_nil(pending)

    rock_tap = {self(), :pick_rock}
    paper_tap = {self(), :pick_paper}
    scissors_tap = {self(), :pick_scissors}

    %{
      type: :column,
      props: %{background: :background, fill_width: true, fill_height: true},
      children: [
        header(),
        score_bar(score),

        # ── Arena ─────────────────────────────────────────────────────────────
        # Split row: user on the left, computer on the right.
        # The computer side shows a spinner while the round is in flight.
        %{
          type: :row,
          props: %{fill_width: true, background: :surface, padding: :space_lg},
          children: [
            arena_cell(user_emoji, "You", 1, false),
            %{
              type: :text,
              props: %{text: "vs", text_size: :sm, text_color: :muted, padding: :space_sm},
              children: []
            },
            arena_cell(cpu_widget, "CPU", 1, true)
          ]
        },
        %{type: :spacer, props: %{size: 12}, children: []},

        # ── Choice buttons ────────────────────────────────────────────────────
        %{
          type: :row,
          props: %{fill_width: true, padding_left: :space_md, padding_right: :space_md, gap: 8},
          children: [
            choice_button("🪨 Rock", rock_tap, busy),
            choice_button("📄 Paper", paper_tap, busy),
            choice_button("✂️  Scissors", scissors_tap, busy)
          ]
        },
        %{type: :spacer, props: %{size: 12}, children: []},
        %{type: :divider, props: %{color: :border}, children: []},

        # ── Round history ─────────────────────────────────────────────────────
        # Each row persisted to SQLite; most recent at top.
        %{
          type: :list,
          props: %{id: :history, items: assigns.rounds},
          children: []
        },
        back_button()
      ]
    }
  end

  # ── Events ────────────────────────────────────────────────────────────────────

  def handle_info({:tap, :pick_rock}, socket), do: pick(socket, "rock")
  def handle_info({:tap, :pick_paper}, socket), do: pick(socket, "paper")
  def handle_info({:tap, :pick_scissors}, socket), do: pick(socket, "scissors")

  # Reveal fires after the 800 ms suspense delay.
  def handle_info(:reveal, %{assigns: %{pending: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_info(:reveal, socket) do
    %{user: user, computer: computer} = socket.assigns.pending
    result = outcome(user, computer)

    MishkaMob.Repo.insert!(%MishkaMob.Round{
      user_choice: user,
      computer_choice: computer,
      result: result
    })

    socket =
      socket
      |> Mob.Socket.assign(:rounds, load_rounds())
      |> Mob.Socket.assign(:pending, nil)

    {:noreply, socket}
  end

  def handle_info({:tap, :back}, socket) do
    {:noreply, Mob.Socket.pop_screen(socket)}
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  # ── Private: game logic ───────────────────────────────────────────────────────

  defp pick(%{assigns: %{pending: p}} = socket, _) when not is_nil(p), do: {:noreply, socket}

  defp pick(socket, user) do
    computer = Enum.random(@choices)
    Process.send_after(self(), :reveal, 800)
    {:noreply, Mob.Socket.assign(socket, :pending, %{user: user, computer: computer})}
  end

  defp outcome("rock", "scissors"), do: "win"
  defp outcome("paper", "rock"), do: "win"
  defp outcome("scissors", "paper"), do: "win"
  defp outcome(same, same), do: "draw"
  defp outcome(_, _), do: "loss"

  defp tally(rounds) do
    Enum.reduce(rounds, %{win: 0, loss: 0, draw: 0}, fn r, acc ->
      Map.update!(acc, String.to_atom(r.result), &(&1 + 1))
    end)
  end

  defp load_rounds do
    MishkaMob.Repo.all(
      from(r in MishkaMob.Round,
        order_by: [desc: r.inserted_at]
      )
    )
  end

  # ── Private: components ───────────────────────────────────────────────────────

  defp header do
    %{
      type: :text,
      props: %{
        text: "🪨📄✂️  Rock Paper Scissors",
        text_size: :xl,
        text_color: :on_primary,
        background: :primary,
        padding: :space_md,
        fill_width: true
      },
      children: []
    }
  end

  defp score_bar(%{win: w, loss: l, draw: d}) do
    %{
      type: :row,
      props: %{fill_width: true, background: :surface_raised, padding: :space_sm},
      children: [
        score_cell("#{w}", "You", :green_400),
        score_cell("#{d}", "Draw", :muted),
        score_cell("#{l}", "CPU", :red_400)
      ]
    }
  end

  defp score_cell(value, label, color) do
    %{
      type: :column,
      props: %{weight: 1, align: :center, padding: :space_xs},
      children: [
        %{
          type: :text,
          props: %{
            text: value,
            text_size: :"2xl",
            text_color: color,
            text_align: "center",
            font_weight: "bold"
          },
          children: []
        },
        %{
          type: :text,
          props: %{text: label, text_size: :xs, text_color: :muted, text_align: "center"},
          children: []
        }
      ]
    }
  end

  defp arena_cell(:spinner, label, weight, _right) do
    %{
      type: :column,
      props: %{weight: weight, align: :center, padding: :space_sm},
      children: [
        %{type: :progress, props: %{color: :primary}, children: []},
        %{type: :spacer, props: %{size: 6}, children: []},
        %{
          type: :text,
          props: %{text: label, text_size: :sm, text_color: :muted, text_align: "center"},
          children: []
        }
      ]
    }
  end

  defp arena_cell(emoji, label, weight, _right) do
    %{
      type: :column,
      props: %{weight: weight, align: :center, padding: :space_sm},
      children: [
        %{
          type: :text,
          props: %{text: emoji, text_size: :"4xl", text_align: "center"},
          children: []
        },
        %{type: :spacer, props: %{size: 6}, children: []},
        %{
          type: :text,
          props: %{text: label, text_size: :sm, text_color: :muted, text_align: "center"},
          children: []
        }
      ]
    }
  end

  defp choice_button(label, tap, disabled) do
    %{
      type: :button,
      props: %{
        text: label,
        weight: 1,
        background: if(disabled, do: :surface, else: :primary),
        text_color: if(disabled, do: :muted, else: :on_primary),
        text_size: :base,
        padding: :space_md,
        disabled: disabled,
        on_tap: tap
      },
      children: []
    }
  end

  # ── Private: history row renderer ────────────────────────────────────────────

  defp history_row(%MishkaMob.Round{} = round) do
    {badge, color} =
      case round.result do
        "win" -> {"W", :green_400}
        "loss" -> {"L", :red_400}
        _ -> {"D", :muted}
      end

    %{
      type: :row,
      props: %{
        fill_width: true,
        background: :surface,
        padding_top: 12,
        padding_bottom: 12,
        padding_left: :space_md,
        padding_right: :space_md
      },
      children: [
        # User side
        %{
          type: :column,
          props: %{weight: 1, align: :center},
          children: [
            %{
              type: :text,
              props: %{text: @emoji[round.user_choice], text_size: :"2xl", text_align: "center"},
              children: []
            },
            %{
              type: :text,
              props: %{text: "You", text_size: :xs, text_color: :muted, text_align: "center"},
              children: []
            }
          ]
        },
        # Result badge
        %{
          type: :column,
          props: %{align: :center, padding: :space_sm},
          children: [
            %{
              type: :text,
              props: %{
                text: badge,
                text_size: :lg,
                text_color: color,
                font_weight: "bold",
                text_align: "center"
              },
              children: []
            },
            %{
              type: :text,
              props: %{
                text: format_time(round.inserted_at),
                text_size: :xs,
                text_color: :muted,
                text_align: "center"
              },
              children: []
            }
          ]
        },
        # CPU side
        %{
          type: :column,
          props: %{weight: 1, align: :center},
          children: [
            %{
              type: :text,
              props: %{
                text: @emoji[round.computer_choice],
                text_size: :"2xl",
                text_align: "center"
              },
              children: []
            },
            %{
              type: :text,
              props: %{text: "CPU", text_size: :xs, text_color: :muted, text_align: "center"},
              children: []
            }
          ]
        }
      ]
    }
  end

  defp format_time(%NaiveDateTime{} = dt) do
    diff = NaiveDateTime.diff(NaiveDateTime.utc_now(), dt)

    cond do
      diff < 10 -> "just now"
      diff < 60 -> "#{diff}s ago"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      true -> "#{div(diff, 3600)}h ago"
    end
  end

  defp back_button do
    %{
      type: :button,
      props: %{
        text: "← Back",
        fill_width: true,
        background: :surface_raised,
        text_color: :on_surface,
        text_size: :lg,
        padding: :space_sm,
        on_tap: {self(), :back}
      },
      children: []
    }
  end
end
