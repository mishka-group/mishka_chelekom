defmodule MishkaMob.DiceScreen do
  @moduledoc "Dice roller — tap to roll, tracks history and running average."
  use Mob.Screen

  @faces %{1 => "⚀", 2 => "⚁", 3 => "⚂", 4 => "⚃", 5 => "⚄", 6 => "⚅"}
  @history_max 10

  def mount(_params, _session, socket) do
    socket =
      socket
      |> Mob.Socket.assign(:face, nil)
      |> Mob.Socket.assign(:value, nil)
      |> Mob.Socket.assign(:history, [])
      |> Mob.Socket.assign(:total_rolls, 0)
      |> Mob.Socket.assign(:total_pips, 0)
    {:ok, socket}
  end

  def render(assigns) do
    avg_text =
      if assigns.total_rolls > 0 do
        avg = assigns.total_pips / assigns.total_rolls
        :erlang.float_to_binary(avg, decimals: 2)
      else
        "—"
      end

    history_text =
      assigns.history
      |> Enum.map(&Map.fetch!(@faces, &1))
      |> Enum.join("  ")

    history_section =
      if assigns.history != [] do
        [
          %{type: :spacer, props: %{size: 16}, children: []},
          %{
            type: :text,
            props: %{
              text: "Last #{length(assigns.history)} rolls",
              text_size: :sm,
              text_color: :muted,
              padding: :space_sm
            },
            children: []
          },
          %{
            type: :box,
            props: %{background: :surface_raised, padding: :space_md},
            children: [
              %{
                type: :text,
                props: %{text: history_text, text_size: 28.0, text_color: :on_surface, padding: 0},
                children: []
              }
            ]
          }
        ]
      else
        []
      end

    column_children =
      [
        header("🎲  Dice Roller"),
        %{type: :spacer, props: %{size: 32}, children: []},

        # ── Big die face ─────────────────────────────────────────────
        %{
          type: :box,
          props: %{
            background: if(assigns.face, do: :primary, else: :surface_raised),
            padding: :space_lg
          },
          children: [
            %{
              type: :text,
              props: %{
                text: assigns.face || "？",
                text_size: 96.0,
                text_color: if(assigns.face, do: :on_primary, else: :muted),
                padding: 0
              },
              children: []
            }
          ]
        },

        %{type: :spacer, props: %{size: 24}, children: []},

        # ── Roll button ───────────────────────────────────────────────
        %{
          type: :button,
          props: %{
            text: if(assigns.total_rolls == 0, do: "Roll!", else: "Roll again"),
            background: :primary,
            text_color: :on_primary,
            text_size: :xl,
            padding: :space_md,
            on_tap: {self(), :roll}
          },
          children: []
        },

        %{type: :spacer, props: %{size: 32}, children: []},
        %{type: :divider, props: %{color: :border}, children: []},
        %{type: :spacer, props: %{size: 16}, children: []},

        # ── Stats ─────────────────────────────────────────────────────
        %{
          type: :row,
          props: %{padding: 0},
          children: [
            stat("Rolls", "#{assigns.total_rolls}"),
            %{type: :spacer, props: %{size: 16}, children: []},
            stat("Average", avg_text)
          ]
        }
      ] ++ history_section ++ [
        %{type: :spacer, props: %{size: 32}, children: []},
        back_button()
      ]

    %{
      type: :scroll,
      props: %{background: :background},
      children: [
        %{type: :column, props: %{background: :background, padding: :space_md}, children: column_children}
      ]
    }
  end

  def handle_info({:tap, :roll}, socket) do
    value   = :rand.uniform(6)
    face    = Map.fetch!(@faces, value)
    history = [value | socket.assigns.history] |> Enum.take(@history_max)
    socket =
      socket
      |> Mob.Socket.assign(:value, value)
      |> Mob.Socket.assign(:face, face)
      |> Mob.Socket.assign(:history, history)
      |> Mob.Socket.assign(:total_rolls, socket.assigns.total_rolls + 1)
      |> Mob.Socket.assign(:total_pips, socket.assigns.total_pips + value)
    {:noreply, socket}
  end

  def handle_info({:tap, :back}, socket) do
    {:noreply, Mob.Socket.pop_screen(socket)}
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  # ── Helpers ────────────────────────────────────────────────────────────────

  defp stat(label, value) do
    %{
      type: :column,
      props: %{background: :surface_raised, padding: :space_md},
      children: [
        %{type: :text, props: %{text: value, text_size: :xl, text_color: :primary, padding: 0}, children: []},
        %{type: :text, props: %{text: label, text_size: :sm, text_color: :muted, padding: 0}, children: []}
      ]
    }
  end

  defp header(title) do
    %{
      type: :text,
      props: %{
        text: title,
        text_size: :xl,
        text_color: :on_primary,
        background: :primary,
        padding: :space_md
      },
      children: []
    }
  end

  defp back_button do
    %{
      type: :button,
      props: %{
        text: "← Back",
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
