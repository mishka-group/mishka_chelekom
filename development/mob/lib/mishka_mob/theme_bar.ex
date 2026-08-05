defmodule MishkaMob.ThemeBar do
  @moduledoc """
  A compact theme selector meant to sit at the top of every screen, so a user
  can switch themes and immediately see components rendered in it. Each chip
  shows an icon **and** a label so it's obvious what it selects.

  Usage in a screen:

      MishkaMob.ThemeBar.bar()   # render (highlights the active theme)

      def handle_info({:tap, {:set_theme, key}}, socket),
        do: {:noreply, MishkaMob.ThemeBar.set(key, socket)}

  Theme is global (`Mob.Theme.set/1`) and the choice is persisted in
  `Mob.State`, so it survives navigation and relaunch.
  """

  @themes [
    %{key: :light, icon: "☀️", label: "Light", module: Mob.Theme.Light},
    %{key: :dark, icon: "🌙", label: "Dark", module: Mob.Theme.Dark},
    %{key: :material3, icon: "🎨", label: "Material", module: MobThemes.Material3},
    %{key: :glass, icon: "🧊", label: "Glass", module: MobThemes.ObsidianGlass}
  ]

  @doc "The theme options (key, icon, label, module)."
  def themes, do: @themes

  @doc "The active theme key (persisted in Mob.State; defaults to :dark)."
  def current, do: Mob.State.get(:theme, :dark)

  @doc "The Mob theme module for a key."
  def module_for(key) do
    entry = Enum.find(@themes, &(&1.key == key)) || hd(@themes)
    entry.module
  end

  @doc "Apply + persist a theme and return the updated socket (triggers a re-render)."
  def set(key, socket) do
    Mob.Theme.set(module_for(key))
    Mob.State.put(:theme, key)
    Mob.Socket.assign(socket, :theme, key)
  end

  @doc "The selector row: four icon+label chips, the active one highlighted."
  def bar do
    active = current()

    chips =
      @themes
      |> Enum.map(&chip(&1, &1.key == active))
      |> Enum.intersperse(gap(6))

    %{type: :row, props: %{fill_width: true}, children: chips}
  end

  defp chip(theme, active?) do
    {bg, fg} = if active?, do: {:primary, :on_primary}, else: {:surface_raised, :on_surface}

    %{
      type: :box,
      props: %{
        background: bg,
        corner_radius: :radius_md,
        padding: :space_sm,
        weight: 1,
        on_tap: {self(), {:set_theme, theme.key}}
      },
      children: [
        %{
          type: :column,
          props: %{fill_width: true},
          children: [
            centered(theme.icon, :lg, fg),
            gap(2),
            centered(theme.label, :xs, fg)
          ]
        }
      ]
    }
  end

  defp centered(text, size, color) do
    %{
      type: :text,
      props: %{
        text: text,
        text_size: size,
        text_color: color,
        text_align: :center,
        fill_width: true
      },
      children: []
    }
  end

  defp gap(n), do: %{type: :spacer, props: %{size: n}, children: []}
end
