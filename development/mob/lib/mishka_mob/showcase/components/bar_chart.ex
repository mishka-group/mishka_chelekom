defmodule MishkaMob.Showcase.Components.BarChart do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaBarChart`.

  Four charts of the same data: a ranking with one shared scale, the same numbers
  as columns, a chart whose bars are tappable — the tapped row shows its reading
  without a separate tooltip — and a capped list with a count.
  """
  use MishkaMob.Showcase.Page

  import Mob.Sigil

  alias MishkaMob.Showcase.Example

  @green 0xFF4E9A73
  @amber 0xFFB08E55
  @blue 0xFF5B7CA8
  @red 0xFFB3564E
  @grey 0xFF8A8177

  @impl true
  def entry do
    %{
      slug: :bar_chart,
      name: "Bar Chart",
      category: "Data display",
      order: 902,
      description: "Rows of data as bars on one shared scale — a ranking, or columns."
    }
  end

  @impl true
  def mount(socket), do: Mob.Socket.assign(socket, :bc_selected, nil)

  @impl true
  def handle({:bc_select, key}, socket), do: Mob.Socket.assign(socket, :bc_selected, key)
  def handle(_tag, socket), do: socket

  @doc "The four genres, as the card's own rows."
  def hours do
    [
      %{id: "action", label: "Action", value: 6, value_text: "6h", color: @green},
      %{id: "adventure", label: "Adventure", value: 5, value_text: "5h", color: @amber},
      %{id: "thriller", label: "Thriller", value: 3, value_text: "3h", color: @blue},
      %{id: "scifi", label: "Science Fiction", value: 3, value_text: "3h", color: @red},
      %{id: "else", label: "Everything else", value: 6, value_text: "6h", color: @grey}
    ]
  end

  @doc """
  Three rows: two banded bars and one flat colour, side by side.

  Every band is a mid-tone on purpose. A near-black band reads on a light card
  and disappears on a dark one, so the gallery — which draws every example in
  four themes — would show a three-colour bar as a two-colour bar half the time.
  Bands are the caller's palette; these are chosen to be visible in all of them.
  """
  def bands do
    [
      %{label: "Dusk", value: 1.0, colors: [0xFF5B7CA8, 0xFF8A6FA8, 0xFFB3564E]},
      %{label: "Ember", value: 0.8, segments: [{0.6, 0xFFB08E55}, {0.4, 0xFFB3564E}]},
      %{label: "Slate", value: 0.55, color: 0xFF8A8177}
    ]
  end

  @doc "The week as columns, each carrying its own two bands: deep base, light top."
  def week_bands do
    [
      {"M", 4, [0xFF4C6E96, 0xFF8FB0D6]},
      {"T", 7, [0xFFA97F45, 0xFFD6B27A]},
      {"W", 3, [0xFF3F7F5F, 0xFF7FB79B]},
      {"T", 6, [0xFF9E4A44, 0xFFCE8A83]},
      {"F", 2, [0xFF6E5588, 0xFFA98FC2]},
      {"S", 5, [0xFF4C6E96, 0xFF8FB0D6]},
      {"S", 1, [0xFFA97F45, 0xFFD6B27A]}
    ]
    |> Enum.map(fn {label, value, colors} ->
      %{label: label, value: value, colors: colors}
    end)
  end

  @doc "Five fractions and nothing else, so the colour scale decides."
  def plain do
    [
      {"10%", 0.1},
      {"25%", 0.25},
      {"40%", 0.4},
      {"70%", 0.7},
      {"100%", 1.0}
    ]
  end

  @doc "A week of episodes, for the columns."
  def week do
    [
      {"M", 4},
      {"T", 7},
      {"W", 3},
      {"T", 6},
      {"F", 2},
      {"S", 5},
      {"S", 1}
    ]
  end

  @doc "Eight albums, so the cap has something to cut."
  def albums do
    for {title, plays} <- [
          {"The Long Hollow", 14},
          {"Nightjar", 11},
          {"Paper Cities", 9},
          {"Low Tide", 8},
          {"The Second Sun", 6},
          {"Winter Machine", 4},
          {"Harbour Lights", 3},
          {"After the Rain", 2}
        ] do
      %{label: title, value: plays, value_text: "#{plays}"}
    end
  end

  @impl true
  def examples do
    [
      %Example{
        title: "Where the hours went",
        description:
          "One scale for every row, taken from the loudest. The gutter and the " <>
            "reading are declared widths, which is what keeps five bars starting " <>
            "and ending on the same x.",
        code: ~S"""
        <MishkaBarChart
          rows={hours()}
          label_width={96}
          value_width={34}
          show_values={true}
          bar_size={8}
          track_color={:surface_raised}
          gap={12}
          value_size={11}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaBarChart
              id="bc-hours"
              rows={MishkaMob.Showcase.Components.BarChart.hours()}
              label_width={96}
              value_width={34}
              show_values={true}
              bar_size={8}
              track_color={:surface_raised}
              gap={12}
              value_size={11}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "The same week, as columns",
        description:
          "The same rows, a different orientation: seven columns on one baseline, " <>
            "each height arithmetic rather than measurement, so both platforms " <>
            "agree.",
        code: ~S"""
        <MishkaBarChart
          rows={week()}
          orientation={:vertical}
          color={0xFF4E9A73}
          max={7}
          height={110}
          bar_size={24}
          gap={10}
          show_values={true}
          track_color={:surface_raised}
          label_size={11}
          value_size={11}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaBarChart
              id="bc-week"
              rows={MishkaMob.Showcase.Components.BarChart.week()}
              orientation={:vertical}
              color={0xFF4E9A73}
              max={7}
              height={110}
              bar_size={24}
              gap={10}
              show_values={true}
              track_color={:surface_raised}
              label_size={11}
              value_size={11}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "A banded scale, and a ramp",
        description:
          "The same five fractions coloured by where they fall: strict bands " <>
            "under 30% red, under 100% blue, a full bar grey — then the same stops " <>
            "blended channel by channel.",
        code: ~S"""
        <MishkaBarChart
          rows={plain()}
          color_scale={[{0.0, 0xFFB3564E}, {0.3, 0xFF5B7CA8}, {1.0, 0xFF8A8177}]}
          scale_mode={:steps}
          label_width={96}
          bar_size={8}
          track_color={:surface_raised}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaBarChart
              rows={MishkaMob.Showcase.Components.BarChart.plain()}
              color_scale={[{0.0, 0xFFB3564E}, {0.3, 0xFF5B7CA8}, {1.0, 0xFF8A8177}]}
              scale_mode={:steps}
              label_width={96}
              bar_size={8}
              track_color={:surface_raised}
              gap={10}
            />
            <Spacer size={20} />
            <MishkaBarChart
              rows={MishkaMob.Showcase.Components.BarChart.plain()}
              color_scale={[{0.0, 0xFFB3564E}, {0.3, 0xFF5B7CA8}, {1.0, 0xFF8A8177}]}
              scale_mode={:fade}
              label_width={96}
              bar_size={8}
              track_color={:surface_raised}
              gap={10}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "One bar, several colours",
        description:
          "Each bar carries its own bands: the first runs three colours, the second " <>
            "two uneven ones, and the third stays a flat colour — beside them in the " <>
            "same chart. The bands are mid-tones so every theme can show all of them.",
        code: ~S"""
        <MishkaBarChart
          rows={[
            %{label: "Dusk", value: 1.0, colors: [0xFF5B7CA8, 0xFF8A6FA8, 0xFFB3564E]},
            %{label: "Ember", value: 0.8, segments: [{0.6, 0xFFB08E55}, {0.4, 0xFFB3564E}]},
            %{label: "Slate", value: 0.55, color: 0xFF8A8177}
          ]}
          label_width={96}
          bar_size={14}
          corner_radius={7}
          track_color={:surface_raised}
          gap={12}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaBarChart
              id="bc-bands"
              rows={MishkaMob.Showcase.Components.BarChart.bands()}
              label_width={96}
              bar_size={14}
              corner_radius={7}
              track_color={:surface_raised}
              gap={12}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "The same week, in colours",
        description:
          "The banded fill works on columns too: each day carries its own two " <>
            "bands, deep at the baseline and light at the top, and the rings clip " <>
            "them to the column's rounding.",
        code: ~S"""
        <MishkaBarChart
          rows={week_bands()}
          orientation={:vertical}
          max={7}
          height={110}
          bar_size={24}
          gap={10}
          show_values={true}
          track_color={:surface_raised}
          label_size={11}
          value_size={11}
        />
        """,
        render: fn _assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaBarChart
              id="bc-week-bands"
              rows={MishkaMob.Showcase.Components.BarChart.week_bands()}
              orientation={:vertical}
              max={7}
              height={110}
              bar_size={24}
              gap={10}
              show_values={true}
              track_color={:surface_raised}
              label_size={11}
              value_size={11}
            />
          </Column>
          """
        end
      },
      %Example{
        title: "Tap a bar and read it",
        description:
          "The chart holds no state: it sends the row's key, the page keeps which " <>
            "one is selected, and the selected row draws its reading even with " <>
            "show_values off.",
        code: ~S"""
        <MishkaBarChart
          rows={albums()}
          selected={@bc_selected}
          on_tap={:bc_select}
          color={0xFF8A8177}
          selected_color={0xFF4E9A73}
          label_width={150}
          value_width={40}
          limit={4}
          more_text="and 4 more"
          bar_size={7}
          track_color={:surface_raised}
          gap={11}
          value_size={12}
        />
        """,
        render: fn assigns ->
          ~MOB"""
          <Column fill_width={true}>
            <MishkaBarChart
              id="bc-albums"
              rows={MishkaMob.Showcase.Components.BarChart.albums()}
              selected={assigns[:bc_selected]}
              on_tap={:bc_select}
              color={0xFF8A8177}
              selected_color={0xFF4E9A73}
              label_width={150}
              value_width={40}
              limit={4}
              more_text="and 4 more"
              bar_size={7}
              track_color={:surface_raised}
              gap={11}
              value_size={12}
            />
            <Spacer size={12} />
            <Text
              text={"Selected: " <> to_string(assigns[:bc_selected] || "none")}
              text_size={:sm}
              text_color={:muted}
            />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def card_preview do
    ~MOB"""
    <Column fill_width={true} padding_top={6} padding_bottom={6}>
      <Row fill_width={true} align="center">
        <Box width={34} height={7} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box weight={1.0} height={7} background={:surface_raised} corner_radius={:radius_pill}>
          <Box width={118} height={7} background={:primary} corner_radius={:radius_pill} />
        </Box>
        <Spacer size={8} />
        <Box width={14} height={7} background={:surface_raised} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={8} />
      <Row fill_width={true} align="center">
        <Box width={26} height={7} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box weight={1.0} height={7} background={:surface_raised} corner_radius={:radius_pill}>
          <Box width={78} height={7} background={:primary} corner_radius={:radius_pill} />
        </Box>
        <Spacer size={8} />
        <Box width={14} height={7} background={:surface_raised} corner_radius={:radius_sm} />
      </Row>
      <Spacer size={8} />
      <Row fill_width={true} align="center">
        <Box width={40} height={7} background={:muted} corner_radius={:radius_sm} />
        <Spacer size={8} />
        <Box weight={1.0} height={7} background={:surface_raised} corner_radius={:radius_pill}>
          <Box width={52} height={7} background={:primary} corner_radius={:radius_pill} />
        </Box>
        <Spacer size={8} />
        <Box width={14} height={7} background={:surface_raised} corner_radius={:radius_sm} />
      </Row>
    </Column>
    """
  end

  @impl true
  def props do
    [
      %{
        name: "rows",
        type: "list of maps / tuples",
        default: "[]",
        description: "One entry per bar, in reading order."
      },
      %{
        name: "orientation",
        type: ":horizontal | :vertical",
        default: ":horizontal",
        description: "Ranking rows, or columns on a baseline."
      },
      %{
        name: "max",
        type: "number",
        default: "loudest row",
        description: "The value a full bar means."
      },
      %{
        name: "bar_size",
        type: "number",
        default: "6 / fills the slot",
        description: "Bar thickness, or column width."
      },
      %{
        name: "gap",
        type: "number",
        default: "10",
        description: "Between rows, or between columns."
      },
      %{
        name: "corner_radius",
        type: "number",
        default: "3",
        description: "Rounding on the bar and its track."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":primary",
        description: "The default fill; a row's own wins."
      },
      %{
        name: "track_color",
        type: "color / ARGB",
        default: ":transparent",
        description: "The groove behind each bar."
      },
      %{
        name: "selected",
        type: "term",
        default: "nil",
        description: "The key of the selected row."
      },
      %{
        name: "selected_color",
        type: "color / ARGB",
        default: "nil",
        description: "The selected row's fill."
      },
      %{
        name: "selected_value_color",
        type: "color / ARGB",
        default: "value_color",
        description: "The selected row's reading ink."
      },
      %{
        name: "show_values",
        type: "boolean",
        default: "false",
        description: "Draw each row's reading."
      },
      %{
        name: "value_width",
        type: "number",
        default: "nil",
        description: "A declared width for the reading, so the tracks end at one x."
      },
      %{
        name: "value_size",
        type: "number",
        default: "12 / 11",
        description: "The reading's size."
      },
      %{
        name: "value_color",
        type: "color / ARGB",
        default: ":muted",
        description: "The reading's ink."
      },
      %{
        name: "value_weight",
        type: "string",
        default: "unset",
        description: "The reading's weight."
      },
      %{name: "value_font", type: "string", default: "unset", description: "The reading's face."},
      %{
        name: "value_gap",
        type: "number",
        default: "3",
        description: "Vertical only: between a column's reading and its top."
      },
      %{
        name: "label_width",
        type: "number",
        default: "84",
        description: "The gutter, horizontal only; nil hugs."
      },
      %{
        name: "label_size",
        type: "number",
        default: "12.5 / 11",
        description: "The label's size."
      },
      %{
        name: "label_color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "The label's ink."
      },
      %{
        name: "label_weight",
        type: "string",
        default: "unset",
        description: "The label's weight."
      },
      %{name: "label_font", type: "string", default: "unset", description: "The label's face."},
      %{
        name: "label_gap",
        type: "number",
        default: "12",
        description: "Between the gutter and the bar."
      },
      %{
        name: "height",
        type: "number",
        default: "120",
        description: "The plot height, vertical only."
      },
      %{
        name: "on_tap",
        type: "tag / {pid, tag}",
        default: "nil",
        description: "Tapping any bar, with the row's key."
      },
      %{
        name: "on_long_press",
        type: "tag / {pid, tag}",
        default: "nil",
        description: "Pressing any bar, with the row's key."
      },
      %{
        name: "limit",
        type: "integer",
        default: "nil",
        description: "Draw only the first N rows."
      },
      %{
        name: "more_text",
        type: "string",
        default: "nil",
        description: "Drawn under the plot when rows were cut."
      },
      %{name: "more_size", type: "number", default: "11", description: "The tail's size."},
      %{
        name: "more_color",
        type: "color / ARGB",
        default: ":muted",
        description: "The tail's ink."
      },
      %{name: "id", type: "string", default: "nil", description: "TestTag; rows are id-key."}
    ]
  end
end
