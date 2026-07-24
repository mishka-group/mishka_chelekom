defmodule MishkaMob.TextScreen do
  @moduledoc "Text input demo screen."
  use Mob.Screen

  def mount(_params, _session, socket) do
    socket =
      socket
      |> Mob.Socket.assign(:text, Mob.State.get(:draft_text, ""))
      |> Mob.Socket.assign(:focused, false)
    {:ok, socket}
  end

  def render(assigns) do
    char_count = String.length(assigns.text)

    %{
      type: :scroll,
      props: %{background: :background},
      children: [
        %{
          type: :column,
          props: %{background: :background, padding: :space_md},
          children: [
            header("✏️  Text Input"),
            %{type: :spacer, props: %{size: 24}, children: []},

            # ── Input field ──────────────────────────────────────────────
            %{
              type: :text_field,
              props: %{
                value: assigns.text,
                placeholder: "Type something…",
                keyboard: :default,
                return_key: :done,
                on_change: {self(), :text_changed},
                on_focus:  {self(), :focused},
                on_blur:   {self(), :blurred}
              },
              children: []
            },
            %{type: :spacer, props: %{size: 8}, children: []},
            %{
              type: :text,
              props: %{
                text: "#{char_count} character#{if char_count == 1, do: "", else: "s"}",
                text_size: :sm,
                text_color: :muted,
                padding: 4
              },
              children: []
            },

            %{type: :spacer, props: %{size: 24}, children: []},
            %{type: :divider, props: %{color: :border}, children: []},
            %{type: :spacer, props: %{size: 16}, children: []},

            # ── Echo box ─────────────────────────────────────────────────
            %{
              type: :text,
              props: %{text: "Preview", text_size: :sm, text_color: :muted, padding: :space_sm},
              children: []
            },
            %{
              type: :box,
              props: %{background: :surface_raised, padding: :space_md},
              children: [
                %{
                  type: :text,
                  props: %{
                    text: if(assigns.text == "", do: "Your text will appear here…", else: assigns.text),
                    text_size: :lg,
                    text_color: if(assigns.text == "", do: :muted, else: :on_surface),
                    padding: 0
                  },
                  children: []
                }
              ]
            },

            %{type: :spacer, props: %{size: 32}, children: []},
            back_button()
          ]
        }
      ]
    }
  end

  def handle_info({:change, :text_changed, value}, socket) do
    # Mob.State.put/2 syncs to disk on every call — fine for short text.
    # For heavier values, debounce writes using Process.send_after/3 instead.
    Mob.State.put(:draft_text, value)
    {:noreply, Mob.Socket.assign(socket, :text, value)}
  end

  def handle_info({:focus, :focused}, socket) do
    {:noreply, Mob.Socket.assign(socket, :focused, true)}
  end

  def handle_info({:blur, :blurred}, socket) do
    {:noreply, Mob.Socket.assign(socket, :focused, false)}
  end

  def handle_info({:tap, :back}, socket) do
    {:noreply, Mob.Socket.pop_screen(socket)}
  end

  def handle_info(_message, socket), do: {:noreply, socket}

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
