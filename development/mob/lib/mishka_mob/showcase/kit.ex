defmodule MishkaMob.Showcase.Kit do
  @moduledoc """
  Reusable node-map builders for the gallery UI — the Mob-native equivalent of
  Mishka's `showcase_kit`. Everything here returns `%{type:, props:, children:}`
  so both gallery screens read as declarative composition.
  """

  @doc "A primary-colored page header with an optional muted subtitle below."
  def page_header(title, subtitle \\ nil) do
    header = %{
      type: :text,
      props: %{
        text: title,
        text_size: :xl,
        text_color: :on_primary,
        background: :primary,
        padding: :space_md,
        fill_width: true
      },
      children: []
    }

    case subtitle do
      nil -> header
      text -> column([header, gap(8), muted(text)])
    end
  end

  @doc "An uppercase-ish category/section label."
  def section_label(text) do
    %{
      type: :text,
      props: %{text: String.upcase(text), text_size: :sm, text_color: :muted, padding: 4},
      children: []
    }
  end

  @doc "A tappable component row: name + one-line description, navigates via `tag`."
  def component_row(name, description, tag) do
    column(
      [
        %{
          type: :button,
          props: %{
            text: name,
            text_color: :on_surface,
            background: :surface_raised,
            text_size: :lg,
            padding: :space_md,
            fill_width: true,
            on_tap: {self(), tag}
          },
          children: []
        }
      ] ++ if(description, do: [gap(2), muted(description)], else: [])
    )
  end

  @doc """
  One example block: bold title, muted description, the live preview, and the
  code shown in a bordered box.
  """
  def example_block(title, description, preview, code) do
    children =
      [
        %{
          type: :text,
          props: %{text: title, text_size: :lg, text_color: :on_surface},
          children: []
        }
      ] ++
        if(description, do: [gap(4), muted(description)], else: []) ++
        [gap(12), preview] ++
        if(code, do: [gap(12), code_block(code)], else: [])

    %{
      type: :box,
      props: %{background: :surface, padding: :space_md, corner_radius: :radius_md},
      children: [column(children)]
    }
  end

  @doc """
  A code snippet in a bordered surface box. Mob has no monospace font, so this
  leans on a distinct border + raised background to read as "code".
  """
  def code_block(code) do
    %{
      type: :box,
      props: %{
        background: :surface_raised,
        padding: :space_sm,
        corner_radius: :radius_sm,
        border_color: :border,
        border_width: 1,
        fill_width: true
      },
      children: [
        %{
          type: :text,
          props: %{text: code, text_size: :sm, text_color: :on_surface},
          children: []
        }
      ]
    }
  end

  @doc "A standard back button (`{:tap, :back}`)."
  def back_button do
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

  @doc "A section heading (larger than `section_label`) with an optional subtitle."
  def section_header(title, subtitle \\ nil) do
    header = %{
      type: :text,
      props: %{text: title, text_size: :"2xl", text_color: :on_surface},
      children: []
    }

    case subtitle do
      nil -> header
      text -> column([header, gap(2), muted(text)])
    end
  end

  @doc """
  A component preview card: a `preview` "face" (a mini-illustration of the
  component), the name, and a caption. Tappable when `tag` is non-nil
  (navigates). Carries `weight: 1` for a 2-up `grid/1`.
  """
  def component_card(preview, name, caption, tag) do
    body =
      column([
        preview,
        gap(14),
        %{
          type: :text,
          props: %{text: name, text_size: :lg, text_color: :on_surface},
          children: []
        },
        gap(2),
        muted(caption)
      ])

    props = %{
      background: :surface,
      padding: :space_md,
      corner_radius: :radius_md,
      border_color: :border,
      border_width: 1,
      weight: 1
    }

    props = if tag, do: Map.put(props, :on_tap, {self(), tag}), else: props
    %{type: :box, props: props, children: [body]}
  end

  @doc false
  def skeleton_preview do
    column([skeleton_bar(140), gap(6), skeleton_bar(170), gap(6), skeleton_bar(100)])
  end

  @doc "A dimmed placeholder card for a not-yet-built component."
  def skeleton_card, do: component_card(skeleton_preview(), "Soon", "coming soon", nil)

  @doc "A compact button for the space-efficient default section. `weight: 1` for `grid/1`."
  def compact_button(label, tag) do
    %{
      type: :button,
      props: %{
        text: label,
        background: :surface_raised,
        text_color: :on_surface,
        text_size: :sm,
        padding: :space_sm,
        weight: 1,
        on_tap: {self(), tag}
      },
      children: []
    }
  end

  @doc """
  Lay out `weight: 1` items two-per-row. Odd counts pad with an empty flex slot
  so the last item stays half-width (not stretched).
  """
  def grid(items) do
    items
    |> Enum.chunk_every(2)
    |> Enum.map(fn
      [a, b] -> row([a, gap_h(), b])
      [a] -> row([a, gap_h(), flex_slot()])
    end)
    |> Enum.intersperse(gap(12))
    |> column()
  end

  @doc "A muted caption line."
  def muted(text) do
    %{type: :text, props: %{text: text, text_size: :sm, text_color: :muted}, children: []}
  end

  # A skeleton placeholder bar (fixed size renders reliably on both platforms).
  defp skeleton_bar(width) do
    %{
      type: :box,
      props: %{width: width, height: 10, background: :surface_raised, corner_radius: :radius_sm},
      children: []
    }
  end

  defp row(children), do: %{type: :row, props: %{fill_width: true}, children: children}
  defp gap_h, do: %{type: :spacer, props: %{size: 12}, children: []}
  defp flex_slot, do: %{type: :spacer, props: %{weight: 1}, children: []}

  @doc "A fixed-height spacer."
  def gap(size), do: %{type: :spacer, props: %{size: size}, children: []}

  @doc "A fill-width column wrapper."
  def column(children), do: %{type: :column, props: %{fill_width: true}, children: children}
end
