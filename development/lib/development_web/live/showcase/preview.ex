defmodule DevelopmentWeb.Showcase.Preview do
  @moduledoc """
  Renders a single component preview for the showcase explorer.

  Most components are handled generically by `DevelopmentWeb.Showcase.PreviewGenerated`
  (auto-generated from the catalog — spreads the chosen props via `{@props}`).

  Composite components whose generic preview would render empty or crash (because they
  need structured child slots or specific required attrs) get a richer, hand-written
  override here. Add a clause for any component you want to improve; unmatched components
  fall through to the generated module.

  Assigns: `:component` (name), `:id`, `:props` (map of atom-keyed attrs), `:form` (for
  field components), `:sample` (default inner content).
  """
  use DevelopmentWeb, :html

  alias DevelopmentWeb.Showcase.PreviewGenerated

  # --- Curated overrides for composite / slot-driven components ------------------------

  def show(%{component: "accordion"} = assigns) do
    ~H"""
    <.accordion id={@id} {@props}>
      <:item title="What is Mishka Chelekom?">
        A fully featured components & UI kit library for Phoenix & Phoenix LiveView.
      </:item>
      <:item title="Is it headless?">Styled today; a headless layer is on the roadmap.</:item>
      <:item title="Zero runtime?">
        Components are generated into your app — no prod dependency.
      </:item>
    </.accordion>
    """
  end

  # Card: the generic `<.card>{@sample}</.card>` renders a bare box — indistinguishable from a badge
  # or button. A card's whole point is composing parts, so show a real one: media + title + body +
  # footer, all driven by the controls on the root `<.card>` (variant/color/border/rounded/padding…).
  def show(%{component: "card"} = assigns) do
    ~H"""
    <div class="w-72 text-left">
      <.card id={@id} {@props}>
        <.card_media src="/images/card-media.svg" alt="Abstract landscape at dusk" />
        <.card_content padding="large" space="small">
          <.card_title title="Mishka Chelekom" icon="hero-sparkles" />
          <p class="text-sm opacity-70">
            A components &amp; UI kit for Phoenix &amp; LiveView. This whole card is driven by the
            controls — change the variant, color, padding or rounding and every part follows.
          </p>
        </.card_content>
        <.card_footer padding="large">
          <.button variant="default" color="primary" class="w-full justify-center gap-1.5">
            See more <.icon name="hero-arrow-right" class="size-4" />
          </.button>
        </.card_footer>
      </.card>
    </div>
    """
  end

  # Chat: the bubble's look comes from a `<.chat_section>` (name + message + `:status` slot) inside
  # `<.chat>` — the generic `<.chat>{@sample}</.chat>` has no section, so the controls have nothing
  # styled to act on and it renders as bare text. Render a real bubble, driven by the controls.
  def show(%{component: "chat"} = assigns) do
    ~H"""
    <div class="w-full">
      <.chat id={@id} {@props}>
        <.chat_section>
          <div class="font-medium">Mishka Chelekom</div>
          <p>
            This bubble is driven by the controls — change the variant, color, rounding, padding,
            size or spacing and watch it update.
          </p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  # Layout (`<.flex>`): a flexbox container — so show it arranging things. Put numbered boxes inside a
  # sized frame and let the controls (direction/justify/align/gap/wrap) visibly rearrange them.
  def show(%{component: "layout"} = assigns) do
    ~H"""
    <div class="w-full rounded-box border border-base-300 bg-base-200/40 p-3">
      <.flex id={@id} {@props} class="min-h-44 w-full">
        <div
          :for={
            {n, cls} <- [
              {"1", "bg-primary-light"},
              {"2", "bg-secondary-light"},
              {"3", "bg-success-light"},
              {"4", "bg-warning-light"}
            ]
          }
          class={["grid size-11 shrink-0 place-items-center rounded-lg font-semibold text-white", cls]}
        >
          {n}
        </div>
      </.flex>
    </div>
    """
  end

  # List: render real `<:item>` rows (the generic `<.list>{@sample}</.list>` has no `<li>`s, so
  # `hoverable` — which adds `[&_li]:hover:bg-…` — had nothing to act on). The `padding` control is
  # routed to the items (the list container has no padding attr) so rows get height for the hover.
  def show(%{component: "list"} = assigns) do
    assigns =
      assign(assigns,
        list_props: Map.drop(assigns.props, [:padding]),
        item_pad: assigns.props[:padding] || "small"
      )

    ~H"""
    <div class="w-72">
      <.list id={@id} {@list_props}>
        <:item padding={@item_pad} icon="hero-inbox" title="Inbox">12 unread</:item>
        <:item padding={@item_pad} icon="hero-star" title="Starred">3 items</:item>
        <:item padding={@item_pad} icon="hero-paper-airplane" title="Sent">All caught up</:item>
        <:item padding={@item_pad} icon="hero-trash" title="Trash">Empty</:item>
      </.list>
    </div>
    """
  end

  # Progress: four renderers behind one `type` control — bar (horizontal/vertical), ring, semi-circle.
  # `value` (the range slider) and `color` drive all; `variant`/`size`/`rounded` shape the bar. The
  # bar only fills when `value` is set, so it's passed explicitly (the old preview passed none → empty).
  def show(%{component: "progress"} = assigns) do
    assigns = assign(assigns, :ptype, assigns.props[:type] || "horizontal")

    ~H"""
    <div class="flex items-center justify-center">
      <%= case @ptype do %>
        <% "ring" -> %>
          <.ring_progress
            id={@id}
            value={@props[:value]}
            color={@props[:color]}
            label={"#{@props[:value]}%"}
          />
        <% "semi_circle" -> %>
          <.semi_circle_progress
            id={@id}
            value={@props[:value]}
            color={@props[:color]}
            label={"#{@props[:value]}%"}
          />
        <% "vertical" -> %>
          <div class="flex items-end gap-4">
            <.progress
              id={@id}
              value={@props[:value]}
              variation="vertical"
              color={@props[:color]}
              variant={@props[:variant]}
              size={@props[:size]}
              rounded={@props[:rounded]}
            />
            <span class="text-sm font-semibold tabular-nums">{@props[:value]}%</span>
          </div>
        <% _ -> %>
          <div class="w-72 space-y-2">
            <div class="flex items-center justify-between text-sm">
              <span class="text-base-content/70">Uploading project files…</span>
              <span class="font-semibold tabular-nums">{@props[:value]}%</span>
            </div>
            <.progress
              id={@id}
              value={@props[:value]}
              variation="horizontal"
              color={@props[:color]}
              variant={@props[:variant]}
              size={@props[:size]}
              rounded={@props[:rounded]}
            />
          </div>
      <% end %>
    </div>
    """
  end

  # Keyboard: a `<kbd>` key. One key holding "Mishka Chelekom" looks like a pill — show what it's for:
  # a shortcuts cheat-sheet (Ctrl + C, ⌘ + K …), each key a `<.keyboard>` driven by the controls.
  def show(%{component: "keyboard"} = assigns) do
    assigns =
      assign(assigns, :shortcuts, [
        {"Copy", ["Ctrl", "C"]},
        {"Paste", ["Ctrl", "V"]},
        {"Command palette", ["⌘", "K"]},
        {"Save", ["Ctrl", "S"]}
      ])

    ~H"""
    <div class="w-72 space-y-2.5 text-sm">
      <div :for={{label, keys} <- @shortcuts} class="flex items-center justify-between gap-6">
        <span class="text-base-content/60">{label}</span>
        <span class="flex items-center gap-1.5">
          <%= for {key, i} <- Enum.with_index(keys) do %>
            <span :if={i > 0} class="text-xs text-base-content/30">+</span>
            <.keyboard {@props}>{key}</.keyboard>
          <% end %>
        </span>
      </div>
    </div>
    """
  end

  # Jumbotron: a hero section — not a banner. Fill it with the real pattern: an eyebrow badge, a big
  # heading, a subtitle and a CTA row, as DIRECT children so the `space` control spaces them. Padding
  # is driven by the control (kept out of `class`, which is last and would override it); sensible
  # defaults live in `ComponentLive.preview_override/1`.
  def show(%{component: "jumbotron"} = assigns) do
    ~H"""
    <.jumbotron id={@id} {@props} class="text-center">
      <span class="mx-auto inline-flex w-fit items-center gap-1.5 rounded-full bg-base-200 px-3 py-1 text-xs font-medium text-base-content/70">
        <.icon name="hero-sparkles" class="size-3.5 text-primary-light" /> Now in beta
      </span>
      <h1 class="mx-auto max-w-2xl text-3xl font-extrabold tracking-tight md:text-4xl">
        Build your Phoenix UI faster
      </h1>
      <p class="mx-auto max-w-xl text-base text-base-content/70">
        A fully featured components &amp; UI kit for Phoenix &amp; LiveView — generated straight into
        your app, with zero runtime dependency.
      </p>
      <div class="flex flex-col items-center justify-center gap-3 pt-1 sm:flex-row">
        <.button color="primary" class="gap-1.5">
          Get started <.icon name="hero-arrow-right" class="size-4" />
        </.button>
        <.button variant="outline" color="natural">Read the docs</.button>
      </div>
    </.jumbotron>
    """
  end

  # Indicator: a status dot. `position` and `pinging` come through `:global` rest as boolean attrs
  # (`<.indicator top_right pinging />`), so translate the controls into them. Show it two ways —
  # standalone (color/size/pinging) and on an outline button (the mishka pattern), where `position`
  # drops the dot into a corner (the button is `relative` so the absolute dot anchors to it).
  def show(%{component: "indicator"} = assigns) do
    positions =
      ~w(top_left top_center top_right middle_left middle_right bottom_left bottom_center bottom_right)

    pos = assigns.props[:position]
    pos_attr = if pos in positions, do: %{String.to_atom(pos) => true}, else: %{}
    ping_attr = if assigns.props[:pinging], do: %{pinging: true}, else: %{}

    assigns =
      assign(assigns,
        ind_color: assigns.props[:color] || "primary",
        ind_size: assigns.props[:size] || "medium",
        on_button_attrs: Map.merge(pos_attr, ping_attr),
        dot_attrs: ping_attr
      )

    ~H"""
    <div class="flex items-center gap-10">
      <div class="flex flex-col items-center gap-2">
        <.indicator color={@ind_color} size={@ind_size} {@dot_attrs} />
        <span class="text-[11px] text-base-content/50">standalone</span>
      </div>

      <div class="flex flex-col items-center gap-2">
        <.button variant="outline" color="primary" class="relative">
          Inbox <.indicator color={@ind_color} size={@ind_size} {@on_button_attrs} />
        </.button>
        <span class="text-[11px] text-base-content/50">on a button · {@props[:position]}</span>
      </div>
    </div>
    """
  end

  # Rating: render in NON-field mode so the `interactive` flag is honoured (the form-field clause
  # forces interactive=true, which made the toggle look dead). Interactive non-field stars push the
  # "rating" event on click → ComponentLive updates `select`. `select` (slider, default 2) drives the
  # fill, `precision` (full/half) the half-star clicking.
  def show(%{component: "rating"} = assigns) do
    assigns = assign(assigns, :prec, if(assigns.props[:precision] == "half", do: 0.5, else: 1.0))

    ~H"""
    <div class="flex flex-col items-center gap-3">
      <.rating
        id={@id}
        select={@props[:select]}
        precision={@prec}
        interactive={@props[:interactive]}
        color={@props[:color]}
        size={@props[:size]}
        count={5}
      />
      <div class="text-sm text-base-content/60">
        <span class="font-semibold text-base-content tabular-nums">{@props[:select]}</span>
        / 5
        <span :if={@props[:interactive]} class="ml-1 text-xs text-base-content/40">
          · click the stars
        </span>
      </div>
    </div>
    """
  end

  # Shape: it clips its content into a form — text looks bad clipped, so fill it instead. Show the
  # chosen `variant`/`size`/`half` two ways: a vibrant gradient (inner_block) and a local image (`src`).
  def show(%{component: "shape"} = assigns) do
    assigns =
      assign(assigns, :shape_half, if(assigns.props[:half] in [nil, "none", ""], do: nil, else: assigns.props[:half]))

    ~H"""
    <div class="flex flex-wrap items-center justify-center gap-8">
      <div class="flex flex-col items-center gap-2">
        <.shape variant={@props[:variant]} size={@props[:size]} half={@shape_half}>
          <div class="size-full bg-linear-to-br from-indigo-500 to-fuchsia-500"></div>
        </.shape>
        <span class="text-[11px] text-base-content/50">gradient</span>
      </div>
      <div class="flex flex-col items-center gap-2">
        <.shape
          variant={@props[:variant]}
          size={@props[:size]}
          half={@shape_half}
          src="/images/card-media.svg"
          alt="Sample"
        />
        <span class="text-[11px] text-base-content/50">image</span>
      </div>
    </div>
    """
  end

  # Skeleton: a loading placeholder — one bar doesn't show what it's for. Compose a realistic
  # "profile card loading" layout (avatar + lines + media + paragraph), all driven by the controls
  # (`color`/`rounded`/`animated`/`visible`). `@bar` carries the shared props for the line pieces.
  def show(%{component: "skeleton"} = assigns) do
    assigns =
      assign(assigns, :bar, %{
        color: assigns.props[:color],
        rounded: assigns.props[:rounded],
        animated: assigns.props[:animated],
        visible: assigns.props[:visible]
      })

    ~H"""
    <div class="w-72 space-y-4 rounded-box border border-base-300 bg-base-100 p-4">
      <div class="flex items-center gap-3">
        <.skeleton
          color={@props[:color]}
          rounded="full"
          animated={@props[:animated]}
          visible={@props[:visible]}
          class="size-12 shrink-0"
        />
        <div class="flex-1 space-y-2">
          <.skeleton {@bar} class="h-3 w-2/3" />
          <.skeleton {@bar} class="h-3 w-1/3" />
        </div>
      </div>

      <.skeleton {@bar} class="h-28 w-full" />

      <div class="space-y-2">
        <.skeleton {@bar} class="h-3 w-full" />
        <.skeleton {@bar} class="h-3 w-full" />
        <.skeleton {@bar} class="h-3 w-4/5" />
      </div>
    </div>
    """
  end

  # Speed dial: its root is hardcoded `fixed`, so it floats over the whole page. Scope it to a
  # `relative` preview box and override `fixed` → `!absolute` (like the banner). Give it a `+` FAB icon
  # and several action items so hovering/clicking the button fans them out. Driven by the controls.
  def show(%{component: "speed_dial"} = assigns) do
    ~H"""
    <div class="relative h-72 w-full overflow-hidden rounded-box border border-base-300 bg-base-200/30">
      <span class="absolute left-3 top-3 text-xs text-base-content/40">
        hover / click the button ↘
      </span>
      <.speed_dial id={@id} {@props} icon="hero-plus" class="!absolute !bottom-4 !end-4">
        <:item icon="hero-share" />
        <:item icon="hero-pencil-square" />
        <:item icon="hero-document-duplicate" />
        <:item icon="hero-trash" />
      </.speed_dial>
    </div>
    """
  end

  # Stat: a dashboard metric — figure + title + value + description + trend — not bare text. `trend`
  # (none/up/down/neutral) colors the description and adds a ↗/↘ arrow; `figure_position` moves the
  # icon. The rest of the controls (variant/color/size/rounded/padding) restyle the card.
  def show(%{component: "stat"} = assigns) do
    trend = if assigns.props[:trend] in [nil, "none", ""], do: nil, else: assigns.props[:trend]
    assigns = assign(assigns, stat_props: Map.drop(assigns.props, [:trend]), strend: trend)

    ~H"""
    <div class="w-64">
      <.stat
        id={@id}
        {@stat_props}
        title="Total revenue"
        value="$45,231.89"
        description="20.1% vs last month"
        trend={@strend}
      >
        <:figure>
          <.icon name="hero-currency-dollar" class="size-6" />
        </:figure>
      </.stat>
    </div>
    """
  end

  # Stepper: a multi-step wizard — the generic preview had no steps. Build a 4-step flow whose states
  # (completed / current / upcoming `none`) are driven by the `current` slider, so you can step
  # through it. variant/color/size/space + vertical/col_step restyle it.
  def show(%{component: "stepper"} = assigns) do
    current = assigns.props[:current] || 2
    vertical = assigns.props[:vertical] || false

    steps =
      for {n, title, desc} <- [
            {1, "Account", "Email & password"},
            {2, "Profile", "About you"},
            {3, "Payment", "Billing details"},
            {4, "Done", "Review & finish"}
          ] do
        state = cond do
          n < current -> "completed"
          n == current -> "current"
          true -> "none"
        end

        %{n: n, title: title, desc: desc, state: state}
      end

    assigns = assign(assigns, steps: steps, vert: vertical)

    ~H"""
    <div class="w-full">
      <.stepper
        id={@id}
        variant={@props[:variant]}
        color={@props[:color]}
        size={@props[:size]}
        vertical={@vert}
        col_step={@props[:col_step]}
      >
        <.stepper_section
          :for={s <- @steps}
          step={s.state}
          step_number={s.n}
          title={s.title}
          description={s.desc}
          vertical={@vert}
        />
      </.stepper>
    </div>
    """
  end

  # Table: the generic `<.table>{@sample}</.table>` has no rows/headers — nothing reads as a table.
  # Render a real users table: `<:header>` columns + `<.tr>/<.td>` rows (with a status badge), driven
  # by the controls (variant/color/padding/table_fixed). `rows_border` gives visible row separators.
  def show(%{component: "table"} = assigns) do
    # Names vary in length on purpose. With the table capped at the container width (`max-w-full`),
    # `table_fixed` is visible: auto-layout sizes the Name column to the longest name (long names fit
    # on one line); fixed-layout makes all 3 columns EQUAL, so the long names wrap to 2-3 lines and
    # those rows grow taller. 3 columns so it fits the narrow preview without clipping.
    assigns =
      assign(assigns, :rows, [
        %{name: "Al Park", role: "Admin", status: "Active", color: "success"},
        %{name: "Bob Martinez", role: "Editor", status: "Active", color: "success"},
        %{name: "Alexandra Richardson", role: "Viewer", status: "Suspended", color: "danger"},
        %{name: "Eve Adams", role: "Editor", status: "Active", color: "success"},
        %{name: "Maximilian Cunningham", role: "Admin", status: "Invited", color: "info"},
        %{name: "Grace Kim", role: "Viewer", status: "Active", color: "success"},
        %{name: "Jonathan Fitzgerald", role: "Editor", status: "Suspended", color: "danger"},
        %{name: "Henry Ford", role: "Admin", status: "Active", color: "success"}
      ])

    ~H"""
    <div class="max-h-64 w-full overflow-y-auto overflow-x-hidden rounded-box border border-base-300">
      <.table
        id={@id}
        {@props}
        class="w-full"
        rows_border="extra_small"
        inner_wrapper_class="max-w-full"
        thead_class="sticky top-0 z-10 bg-white dark:bg-base-bg-dark"
      >
        <:header>Name</:header>
        <:header>Role</:header>
        <:header>Status</:header>
        <.tr :for={u <- @rows}>
          <.td class="font-medium">{u.name}</.td>
          <.td>{u.role}</.td>
          <.td>
            <.badge color={u.color} variant="outline" size="small">{u.status}</.badge>
          </.td>
        </.tr>
      </.table>
    </div>
    """
  end

  # Table content (TOC): a titled list of anchor links — the generic `{@sample}` showed bare text.
  # Build a real "On this page" table of contents; each `<:item>` needs `link` + `link_title` to render
  # its link, `active` marks the current section. Driven by variant/color/size/rounded/padding/space.
  def show(%{component: "table_content"} = assigns) do
    sections = [
      {"introduction", "Introduction", "A components & UI kit for Phoenix & LiveView, generated into your app with zero runtime dependency."},
      {"installation", "Installation", "Add the package, run the generator, and the components are copied straight into your project."},
      {"configuration", "Configuration", "Tailwind v4, theme tokens, and the Kit macro let you restyle everything without touching the source."},
      {"components", "Components", "Buttons, forms, tables, navigation, overlays — 70+ styled components, plus a headless layer."},
      {"api", "API reference", "Every component documents its attributes, slots, and the events it emits."}
    ]

    assigns = assign(assigns, sections: sections, scroll_id: "#{assigns.id}-doc")

    ~H"""
    <%!-- `animated` enables smooth scrolling; mirror it onto this scroll box so clicking a TOC link
          glides to the section (vs jumps) right here in the preview. --%>
    <div
      id={@scroll_id}
      class={[
        "max-h-80 w-full overflow-y-auto rounded-box border border-base-300 bg-base-100 p-3",
        @props[:animated] && "scroll-smooth"
      ]}
    >
      <div class="sticky top-0 z-10 mb-2 bg-base-100 pb-2">
        <.table_content id={@id} {@props} title="On this page">
          <.content_item :for={{anchor, label, _} <- @sections} icon="hero-hashtag" active={anchor == "introduction"}>
            <.link href={"#" <> @scroll_id <> "-" <> anchor}>{label}</.link>
          </.content_item>
        </.table_content>
      </div>

      <div class="space-y-8 px-1 pt-2 text-sm">
        <section :for={{anchor, label, body} <- @sections} id={@scroll_id <> "-" <> anchor} class="scroll-mt-2">
          <h4 class="mb-1 font-semibold">{label}</h4>
          <p class="text-base-content/60">{body}</p>
          <div class="mt-3 h-16 rounded-lg bg-base-200/50"></div>
        </section>
      </div>
    </div>
    """
  end

  # Timeline: a sequence of events — the generic preview had no sections. Build a project-milestone
  # timeline (bullet icon + title + time + description per `timeline_section`). `horizontal` lays it
  # out as a row (scrollable); color/size + hide_last_line/gapped_sections drive the rest.
  def show(%{component: "timeline"} = assigns) do
    assigns =
      assign(assigns, :milestones, [
        %{icon: "hero-flag", title: "Kickoff", time: "January 2026", desc: "Project setup and initial configuration."},
        %{icon: "hero-code-bracket", title: "Development", time: "February 2026", desc: "Built and tested the component library."},
        %{icon: "hero-rocket-launch", title: "Launch", time: "March 2026", desc: "Shipped the first release to production."},
        %{icon: "hero-star", title: "Milestone", time: "April 2026", desc: "Reached 1,000 active users."}
      ])

    ~H"""
    <div class="w-full overflow-x-auto">
      <.timeline id={@id} {@props}>
        <.timeline_section
          :for={s <- @milestones}
          bullet_icon={s.icon}
          title={s.title}
          time={s.time}
          description={s.desc}
          horizontal={@props[:horizontal]}
        />
      </.timeline>
    </div>
    """
  end

  # Typography: it's a whole family (h1–h6, p, strong/em/mark/u/s/small/abbr…), but the generic
  # preview showed one `<.h1>`. Render a type specimen — the heading scale, a body paragraph with
  # inline styles, and small print. `color` recolors all; `size` drives the body text.
  def show(%{component: "typography"} = assigns) do
    ~H"""
    <div class="space-y-2 text-left">
      <.h1 color={@props[:color]}>Heading one</.h1>
      <.h2 color={@props[:color]}>Heading two</.h2>
      <.h3 color={@props[:color]}>Heading three</.h3>
      <.h4 color={@props[:color]}>Heading four</.h4>
      <.p color={@props[:color]} size={@props[:size]}>
        Body paragraph with <.strong>strong</.strong>, <.em>emphasis</.em>,
        <.mark>a highlight</.mark>, <.u>underline</.u>, <.s>strikethrough</.s>, and an
        <.abbr title="HyperText Markup Language">HTML</.abbr> abbreviation.
      </.p>
      <.small color={@props[:color]}>Small print — captions and fine details.</.small>
    </div>
    """
  end

  # Gallery: a grid of media. Use CSS-gradient tiles (local, no image files) with varied aspect ratios
  # so `type` (default/masonry/featured), `cols` and `gap` visibly reshape the layout. `rounded` is
  # mapped to a radius on each tile.
  def show(%{component: "gallery"} = assigns) do
    radius =
      case assigns.props[:rounded] do
        "extra_small" -> "rounded-sm"
        "small" -> "rounded-md"
        "large" -> "rounded-xl"
        "extra_large" -> "rounded-2xl"
        "full" -> "rounded-3xl"
        "none" -> "rounded-none"
        _ -> "rounded-lg"
      end

    assigns =
      assign(assigns,
        radius: radius,
        tiles: [
          {"bg-linear-to-br from-indigo-400 to-fuchsia-500", "aspect-square"},
          {"bg-linear-to-br from-rose-400 to-orange-400", "aspect-[3/4]"},
          {"bg-linear-to-br from-emerald-400 to-teal-500", "aspect-video"},
          {"bg-linear-to-br from-sky-400 to-blue-600", "aspect-square"},
          {"bg-linear-to-br from-amber-400 to-pink-500", "aspect-[4/3]"},
          {"bg-linear-to-br from-violet-500 to-purple-700", "aspect-square"}
        ]
      )

    ~H"""
    <div class="w-full">
      <.gallery id={@id} {@props}>
        <.gallery_media :for={{grad, aspect} <- @tiles}>
          <div class={["w-full", aspect, grad, @radius]}></div>
        </.gallery_media>
      </.gallery>
    </div>
    """
  end

  def show(%{component: "carousel"} = assigns) do
    ~H"""
    <.carousel id={@id} {@props}>
      <:slide
        title="First slide"
        description="A sample slide"
        image="https://picsum.photos/seed/1/640/280"
      />
      <:slide
        title="Second slide"
        description="Another slide"
        image="https://picsum.photos/seed/2/640/280"
      />
    </.carousel>
    """
  end

  def show(%{component: "tabs"} = assigns) do
    ~H"""
    <.tabs id={@id} {@props}>
      <:tab>Overview</:tab>
      <:tab>Details</:tab>
      <:panel>The overview panel.</:panel>
      <:panel>The details panel.</:panel>
    </.tabs>
    """
  end

  def show(%{component: "checkbox_card"} = assigns) do
    ~H"""
    <.checkbox_card id={@id} name="demo" {@props}>
      <:checkbox value="a" title="Option A" description="First option">Option A</:checkbox>
      <:checkbox value="b" title="Option B" description="Second option">Option B</:checkbox>
    </.checkbox_card>
    """
  end

  # Collapse: a single disclosure (headless `Collapsible` hook). Show a real expandable panel — a
  # styled clickable row with a chevron that flips when open (the hook sets `aria-expanded` on the
  # trigger), over a bordered card. The `open` / `keep_mounted` flags drive it (toggling remounts).
  def show(%{component: "collapse"} = assigns) do
    ~H"""
    <div class="w-72">
      <.collapse
        id={@id}
        {@props}
        class="rounded-box border border-base-300 bg-base-100 overflow-hidden"
      >
        <:trigger>
          <div class="flex w-full items-center justify-between gap-3 px-4 py-3 font-medium cursor-pointer select-none transition-colors hover:bg-base-200/60">
            <span class="flex items-center gap-2">
              <.icon name="hero-truck" class="size-4 text-base-content/60" /> Shipping &amp; returns
            </span>
            <.icon
              name="hero-chevron-down"
              class="size-4 text-base-content/40 transition-transform [[aria-expanded=true]_&]:rotate-180"
            />
          </div>
        </:trigger>
        <div class="px-4 pb-4 pt-1 text-sm text-base-content/70 space-y-2">
          <p>
            Free standard shipping on orders over $50 — most orders ship within 1–2 business days.
          </p>
          <p>Not happy? Return any item within 30 days for a full refund, no questions asked.</p>
        </div>
      </.collapse>
    </div>
    """
  end

  # Divider: render it with a text label inside real content so `type` (line style), `color`, `size`
  # and `position` (text placement) are all visible — and adapt the layout for `variation`:
  # a vertical divider needs a fixed-height row with content on either side.
  def show(%{component: "divider"} = assigns) do
    ~H"""
    <div>
      <%!-- vertical: the line only renders WITHOUT `.divider-content`, so no text slot here --%>
      <div :if={@props[:variation] == "vertical"} class="flex h-28 items-stretch gap-6">
        <div class="flex items-center text-sm text-base-content/60">Left</div>
        <.divider id={@id} {@props} height="h-full" />
        <div class="flex items-center text-sm text-base-content/60">Right</div>
      </div>

      <div :if={@props[:variation] != "vertical"} class="w-72 space-y-3">
        <p class="text-sm text-base-content/60">Section one</p>
        <.divider id={@id} {@props}>
          <:text>OR</:text>
        </.divider>
        <p class="text-sm text-base-content/60">Section two</p>
      </div>
    </div>
    """
  end

  # Device mockup: the iPhone screen is 272×572. Fill it with a realistic app *skeleton* (status bar,
  # header, search, hero, a loading list, bottom nav) instead of bare text — driven by the `color`
  # control on the frame. Kept on a white screen with gray placeholders so it reads as a loading app.
  def show(%{component: "device_mockup"} = assigns) do
    ~H"""
    <.device_mockup id={@id} {@props}>
      <div class="flex h-full w-full flex-col bg-white text-gray-800">
        <div class="flex items-center justify-between px-5 pt-3.5 pb-1 text-[11px] font-semibold">
          <span>9:41</span>
          <div class="flex items-center gap-1 text-gray-700">
            <.icon name="hero-signal" class="size-3.5" />
            <.icon name="hero-wifi" class="size-3.5" />
            <.icon name="hero-battery-100" class="size-4" />
          </div>
        </div>

        <div class="flex items-center justify-between px-4 pt-2 pb-3">
          <div class="space-y-1.5">
            <div class="h-2 w-14 rounded bg-gray-200"></div>
            <div class="h-3.5 w-24 rounded bg-gray-300"></div>
          </div>
          <div class="size-9 rounded-full bg-gray-200"></div>
        </div>

        <div class="px-4">
          <div class="h-9 w-full rounded-xl bg-gray-100"></div>
        </div>

        <div class="px-4 pt-3">
          <div class="h-28 w-full rounded-2xl bg-linear-to-br from-gray-200 to-gray-100"></div>
        </div>

        <div class="space-y-3 px-4 pt-4 animate-pulse">
          <div :for={_ <- 1..3} class="flex items-center gap-3">
            <div class="size-10 shrink-0 rounded-xl bg-gray-200"></div>
            <div class="flex-1 space-y-1.5">
              <div class="h-2.5 w-3/4 rounded bg-gray-200"></div>
              <div class="h-2 w-1/2 rounded bg-gray-100"></div>
            </div>
          </div>
        </div>

        <div class="mt-auto flex items-center justify-around border-t border-gray-100 px-6 py-3 text-gray-400">
          <.icon name="hero-home-solid" class="size-5 text-gray-800" />
          <.icon name="hero-magnifying-glass" class="size-5" />
          <.icon name="hero-heart" class="size-5" />
          <.icon name="hero-user" class="size-5" />
        </div>
      </div>
    </.device_mockup>
    """
  end

  def show(%{component: "dock"} = assigns) do
    ~H"""
    <.dock id={@id} {@props}>
      <:item icon="hero-home" label="Home" />
      <:item icon="hero-user" label="Profile" />
      <:item icon="hero-cog-6-tooth" label="Settings" />
    </.dock>
    """
  end

  def show(%{component: "radio_card"} = assigns) do
    ~H"""
    <.radio_card id={@id} name="demo" {@props}>
      <:radio value="a" title="Option A" description="First option" />
      <:radio value="b" title="Option B" description="Second option" />
    </.radio_card>
    """
  end

  # Clipboard: the JS hook copies `.clipboard-content` (or `text=` / `target_selector`). The old
  # preview put the value in the inner block, so `.clipboard-content` never rendered (its `:if` needs
  # the `<:content>` slot) and there was nothing to copy → "Copy failed". Put the value in `<:content>`
  # (what's shown is what's copied) with a real Copy button. The `show_status_text` / `dynamic_label`
  # flags drive the feedback; toggling them remounts the preview, so the hook re-reads them.
  # Clipboard: the component ships `phx-update="ignore"` — its DOM is owned by the JS hook and LiveView
  # must never patch its insides. So its id is deliberately STATIC (not the nonce-based `@id`): the
  # widget mounts once and is only attribute-patched, so the Copy trigger is never dropped. (A
  # nonce-driven remount — which Reset and flag toggles trigger elsewhere — would destroy the
  # hook-owned trigger.) The two display flags can't be toggled through the ignore barrier, so they're
  # removed from the controls (see `Catalog.dead_flags/1`); `show_status_text` defaults to true, giving
  # the "Copied!" feedback on copy.
  def show(%{component: "clipboard"} = assigns) do
    ~H"""
    <.clipboard
      id="showcase-clipboard-demo"
      {@props}
      class="inline-flex items-center gap-3 rounded-box border border-base-300 bg-base-100 px-3 py-2"
    >
      <:content>
        <code class="text-sm font-mono text-base-content/80">hello@mishka.tools</code>
      </:content>
      <:trigger>
        <.button size="extra_small" variant="outline" color="natural" class="gap-1.5">
          <.icon name="hero-clipboard-document" class="size-4" /> Copy
        </.button>
      </:trigger>
    </.clipboard>
    """
  end

  def show(%{component: "image"} = assigns) do
    ~H"""
    <.image id={@id} src="https://picsum.photos/seed/mishka/320/200" alt="Sample" {@props} />
    """
  end

  def show(%{component: "video"} = assigns) do
    ~H"""
    <.video id={@id} {@props}>
      <:source src="https://www.w3schools.com/html/mov_bbb.mp4" type="video/mp4" />
    </.video>
    """
  end

  def show(%{component: "pagination"} = assigns) do
    ~H"""
    <.pagination id={@id} total={100} active={1} {@props} />
    """
  end

  def show(%{component: "form_wrapper"} = assigns) do
    # form_wrapper renders a <.form> around its content + an :actions slot. Put real fields in it so the
    # wrapper's styling (variant/color/padding/space/rounded) is visible in context. Fields use
    # name/value (not field={...}) — these components' field clause is what the showcase uses elsewhere;
    # name-based keeps it self-contained. `phx-submit="save"` is absorbed by the catch-all handle_event.
    ~H"""
    <.form_wrapper id={@id} for={@form} phx-submit="save" {@props}>
      <div class="space-y-3">
        <.text_field
          id="fw-name"
          name="fw_name"
          value=""
          label="Full name"
          placeholder="Ada Lovelace"
        />
        <.email_field
          id="fw-email"
          name="fw_email"
          value=""
          label="Email"
          placeholder="ada@example.com"
        />
        <.checkbox_field
          id="fw-subscribe"
          name="fw_subscribe"
          value="true"
          label="Subscribe to updates"
        />
      </div>
      <:actions>
        <.button type="submit" color="primary">Save</.button>
      </:actions>
    </.form_wrapper>
    """
  end

  def show(%{component: "email_field"} = assigns) do
    ~H"""
    <.email_field id={@id} name="demo" value="" label="Email" placeholder="you@example.com" {@props} />
    """
  end

  def show(%{component: "combobox"} = assigns) do
    # The combobox's runtime DOM (search box, multi-select mode, create option) lives under
    # phx-update="ignore", so it's frozen at first paint — re-rendering with new props does nothing.
    # We key the id ONLY on the STRUCTURAL flags (searchable/multiple/creatable): toggling one
    # renames the hook element → LiveView remounts it → the structure actually changes. We do NOT
    # key on variant/color (cosmetic): changing those must not remount, so the search/selection
    # survive (the open-dropdown color simply stays at first paint, like the Mishka docs).
    ~H"""
    <.combobox
      id={"#{@id}-#{@props[:searchable]}-#{@props[:multiple]}-#{@props[:creatable]}"}
      name="demo_combobox"
      label="Choose countries"
      description="Per-option flags · grouped · searchable multi-select"
      placeholder="Select countries…"
      search_placeholder="Search countries…"
      {@props}
    >
      <:start_section>
        <.icon name="hero-globe-alt" class="size-5" />
      </:start_section>
      <:option :for={c <- combobox_countries()} group={c.group} value={c.code}>
        <span class="flex items-center gap-2"><span class="text-base">{c.flag}</span> {c.name}</span>
      </:option>
    </.combobox>
    """
  end

  def show(%{component: "alert"} = assigns) do
    # Docs-accurate alert: a `title` (so the component's default icon renders — it only shows inside
    # the title block) + a working dismiss via the real `hide_alert/1` JS helper (client-side fade,
    # no server round-trip), targeting the alert's id. `{@props}` drives variant/kind/size/rounded/
    # padding from the controls. Below it, a real `<.flash>` stack shows the flash / flash_group
    # story (flash_group isn't importable here and needs a live @flash map; a flash stack is the
    # honest, self-contained equivalent — each flash keeps its own built-in X).
    ~H"""
    <div class="w-full space-y-5">
      <.alert id={@id} title="Heads up" {@props}>
        <div class="flex items-start justify-between gap-2">
          <p>{@sample} — fully driven by the controls.</p>
          <button
            type="button"
            phx-click={hide_alert("##{@id}")}
            aria-label="close"
            class="group shrink-0 p-1 -m-1"
          >
            <.icon name="hero-x-mark-solid" class="alert-icon opacity-40 group-hover:opacity-70" />
          </button>
        </div>
      </.alert>

      <div class="space-y-1.5">
        <div class="text-xs uppercase tracking-wide text-base-content/40">
          flash &amp; flash_group — dismissible
        </div>
        <div class="relative w-full max-w-sm [&_.flash-alert:not(:first-child)]:mt-2">
          <.flash id={"#{@id}-flash-info"} kind={:success} variant="bordered" title="Success!">
            Your changes were saved.
          </.flash>
          <.flash id={"#{@id}-flash-error"} kind={:danger} variant="bordered" title="Error!">
            Something needs your attention.
          </.flash>
        </div>
      </div>
    </div>
    """
  end

  def show(%{component: "native_select"} = assigns) do
    ~H"""
    <.native_select id={@id} name="demo_select" label="Choose a framework" {@props}>
      <:option value="phoenix">Phoenix</:option>
      <:option value="rails">Ruby on Rails</:option>
      <:option value="django">Django</:option>
      <:option value="laravel">Laravel</:option>
    </.native_select>
    """
  end

  def show(%{component: "checkbox_field"} = assigns) do
    # A real checkbox GROUP: all boxes share ONE name ("notify"), each a distinct value. That's where
    # `multiple` matters — it appends `[]` to the shared name. WITHOUT it the same key repeats and the
    # server keeps only the LAST value (silent data loss); WITH it `[]` collects every checked box into
    # a list. The boxes are styled live by {@props}; the panel below shows the actual request body and
    # parsed params for both modes, highlighting the one the `multiple` control currently selects.
    multiple_on = assigns.props[:multiple] == true
    items = [{"email", "Email", true}, {"sms", "SMS", true}, {"push", "Push", true}]
    checked = for {v, _l, true} <- items, do: v

    assigns =
      assign(assigns,
        multiple_on: multiple_on,
        group_name: if(multiple_on, do: "notify[]", else: "notify"),
        items: items,
        body_off: Enum.map_join(checked, "&", &"notify=#{&1}"),
        body_on: Enum.map_join(checked, "&", &"notify[]=#{&1}"),
        params_off: inspect(%{"notify" => List.last(checked)}),
        params_on: inspect(%{"notify" => checked})
      )

    ~H"""
    <div class="flex w-full flex-col gap-3 text-left">
      <p class="text-xs text-base-content/50">
        A checkbox group — all share <code class="font-mono">name="{@group_name}"</code>:
      </p>

      <.checkbox_field
        :for={{val, lbl, chk} <- @items}
        id={"#{@id}-#{val}"}
        name={@group_name}
        value={val}
        checked={chk}
        label={lbl}
        {@props}
      />

      <div class="space-y-2 rounded-box bg-base-300/40 p-3 font-mono text-[11px] leading-5">
        <div class={!@multiple_on || "opacity-40"}>
          <div class="font-semibold">multiple OFF · name="notify"</div>
          <div>request body → {@body_off}</div>
          <div>server params → {@params_off}</div>
          <div class="text-warning">↳ same key repeats, so only the last value survives</div>
        </div>
        <div class={["border-t border-base-content/10 pt-2", @multiple_on || "opacity-40"]}>
          <div class="font-semibold">multiple ON · name="notify[]"</div>
          <div>request body → {@body_on}</div>
          <div>server params → {@params_on}</div>
          <div class="text-success">↳ [] collects every checked box into a list</div>
        </div>
      </div>
    </div>
    """
  end

  def show(%{component: "fieldset"} = assigns) do
    # Fieldset groups form controls under a legend — it renders `:control` SLOTS, not inner_block, so
    # the generic `<.fieldset>{@sample}</.fieldset>` preview drew an empty box. Give it a legend plus a
    # few real controls; {@props} drives variant/color/size/rounded/padding/space so the frame, legend
    # and spacing all respond to the settings.
    ~H"""
    <.fieldset id={@id} legend="Notifications" {@props}>
      <:control>
        <.checkbox_field
          id={"#{@id}-c1"}
          name="fs_email"
          value="true"
          checked
          label="Email"
          space="small"
        />
      </:control>
      <:control>
        <.checkbox_field id={"#{@id}-c2"} name="fs_sms" value="true" label="SMS" space="small" />
      </:control>
      <:control>
        <.checkbox_field
          id={"#{@id}-c3"}
          name="fs_push"
          value="true"
          checked
          label="Push"
          space="small"
        />
      </:control>
    </.fieldset>
    """
  end

  def show(%{component: "banner"} = assigns) do
    # The banner is hardcoded `fixed z-50` (it pins to the viewport, full-width) — so in the showcase it
    # flies to the top of the page and you can't see rounded/padding/border change. We override the
    # position to `!relative` (+ `!z-auto`) so it renders IN the preview box, where its styling is
    # visible. {@props} drives variant/color/rounded/padding/border + the hide_dismiss flag. The
    # built-in dismiss X pushes a "dismiss" event (handled by the catch-all; Reset restores it via the
    # preview nonce). `size`/`space` are dropped from the controls in Catalog — the component ignores
    # them, so they'd be dead knobs here.
    # rounded/border are position-scoped in this component: `rounded` only emits a class when
    # `rounded_position` is top/bottom/all, and `border` only with a position AND a non-filled variant
    # (it's nil for default/shadow/transparent/gradient). We pin `rounded_position="all"` and
    # `border_position="full"` so both render all around; the default variant (`bordered`) makes the
    # border visible immediately. They sit before {@props} so the live controls still win on overlap.
    ~H"""
    <.banner
      id={@id}
      class="!relative !z-auto w-full max-w-md"
      rounded_position="all"
      border_position="full"
      {@props}
    >
      <span class="text-sm">{@sample} — a dismissible banner.</span>
    </.banner>
    """
  end

  def show(%{component: "file_field"} = assigns) do
    # Follows the mishka file_live demo: a plain file input, plus a dropzone wired to a real upload
    # (allow_upload(:showcase_file) in the LiveView mount → @uploads, with target+uploads as mishka
    # does). Wrapped in a form so live_file_input / phx-drop-target work; the validate/save events are
    # absorbed by the catch-all handle_event. The standalone `live` flag is dropped from the controls
    # (Catalog.dead_flags) — mishka never uses it and its branch needs an @upload only dropzone sets.
    ~H"""
    <.form for={@form} phx-change="validate" phx-submit="save" class="w-full">
      <%!-- No `id` on the dropzone: its <label for={id}> WRAPS the <input id={id}>, and a label that
            both points to (via `for`) and contains its input fires the file picker twice → it opens
            and instantly cancels. mishka passes no id so the input is associated only by containment
            (single trigger). --%>
      <.file_field
        :if={@props[:dropzone]}
        target={:showcase_file}
        uploads={@uploads}
        dropzone_type="image"
        {@props}
      />
      <.file_field :if={!@props[:dropzone]} id={@id} name="demo_file" label="Pick a file" {@props} />
    </.form>
    """
  end

  def show(%{component: "input_field"} = assigns) do
    # input_field is the core `<.input>` that dispatches by `type`. We surface `type` as a control
    # (Catalog.extra_dims) and switch the rendered input here: `select` needs `options`/`prompt`,
    # everything else gets a `placeholder` (a global-rest attr, ignored by types that don't use it).
    type = assigns.props[:type] || "text"
    assigns = assign(assigns, type: type, rest: Map.drop(assigns.props, [:type]))

    ~H"""
    <div class="w-full">
      <.input
        :if={@type == "select"}
        id={@id}
        field={@form[:demo]}
        label="Demo field"
        type="select"
        prompt="Choose an option"
        options={[{"One", "1"}, {"Two", "2"}, {"Three", "3"}]}
        {@rest}
      />
      <.input
        :if={@type != "select"}
        id={@id}
        field={@form[:demo]}
        label="Demo field"
        type={@type}
        placeholder="Type something…"
        {@rest}
      />
    </div>
    """
  end

  def show(%{component: "range_field"} = assigns) do
    # `ring` (a focus indicator) only works with the CUSTOM appearance — the default appearance is a
    # native slider whose thumb can't take a custom ring. So render appearance="custom" (a styled slider
    # with a color-driven thumb halo); with ring=true, focusing the slider adds an offset outline ring
    # around the thumb (Radix/shadcn style). {@props} drives color/size + the ring/reverse flags.
    ~H"""
    <.range_field
      id={@id}
      name="demo_range"
      value="50"
      label="Demo field — focus the slider with Ring on"
      appearance="custom"
      {@props}
    />
    """
  end

  def show(%{component: "toggle_field"} = assigns) do
    # Mirrors the mishka "rounded" docs: a row of toggles showing each `rounded` value (square → pill),
    # so the corner-radius prop is visible at a glance. color/size (and reverse) come from the controls
    # via {@props}; `rounded` is set per toggle since it isn't a showcase dim. Name-based, all "on".
    assigns =
      assign(assigns, :rounds, [
        {"extra_small", "Extra small"},
        {"small", "Small"},
        {"medium", "Medium"},
        {"large", "Large"},
        {"extra_large", "Extra large"},
        {"full", "Full radius"}
      ])

    ~H"""
    <div class="flex w-full flex-wrap items-end justify-center gap-5">
      <div :for={{key, lbl} <- @rounds} class="flex flex-col items-center gap-2">
        <span class="text-[11px] font-medium text-base-content/60">{lbl}</span>
        <.toggle_field
          id={"tf-#{key}"}
          name={"tf_#{key}"}
          value="true"
          checked
          rounded={key}
          {@props}
        />
      </div>
    </div>
    """
  end

  def show(%{component: "radio_field"} = assigns) do
    # Two ways to use it: individual <.radio_field> sharing ONE name (so only one can be selected — a
    # real radio group), and the <.group_radio> component with :radio slots. Both driven by {@props}
    # (color/size/space + ring/reverse). Name-based (not field={...}) keeps it self-contained.
    ~H"""
    <div class="w-full space-y-5 text-left">
      <div>
        <p class="mb-2 text-xs font-semibold uppercase tracking-wide text-base-content/50">
          Individual radios (shared name → one selection)
        </p>
        <div class="space-y-1">
          <.radio_field id="rf-elixir" name="fav_lang" value="elixir" checked label="Elixir" {@props} />
          <.radio_field id="rf-ruby" name="fav_lang" value="ruby" label="Ruby" {@props} />
          <.radio_field id="rf-python" name="fav_lang" value="python" label="Python" {@props} />
        </div>
      </div>

      <div>
        <p class="mb-2 text-xs font-semibold uppercase tracking-wide text-base-content/50">
          Radio group component (group_radio)
        </p>
        <.group_radio
          id="rf-plan"
          name="plan"
          variation="horizontal"
          color={@props[:color]}
          size={@props[:size]}
          space={@props[:space]}
        >
          <:radio value="free">Free</:radio>
          <:radio value="pro" checked>Pro</:radio>
          <:radio value="team">Team</:radio>
        </.group_radio>
      </div>
    </div>
    """
  end

  def show(%{component: "avatar"} = assigns) do
    # Two avatars, both driven by the controls: an SVG-icon avatar (no image, no copyright — the `:icon`
    # slot) and an initials avatar showing "SHA". `space` is an AVATAR_GROUP prop (gap between items),
    # not an `avatar` one — the showcase derives it from the catalog's args (priv/components/avatar.exs
    # lists `space:`, which covers both avatar and avatar_group). A lone <.avatar> ignores it, so we
    # wrap the pair in <.avatar_group> and route `space` there; the per-avatar dims (color/size/rounded)
    # go to each avatar. Now every control is live — color/size/rounded restyle both, space changes the
    # gap. Avatar has no JS hook, so a plain re-render updates everything (no remount keying needed).
    # `space` only ever OVERLAPS (negative margins) — so each avatar gets a ring the colour of the
    # preview surface, making the overlap read as a layered stack instead of merging into one blob.
    # `relative` + a higher z on hover would be nice but isn't needed; later siblings already paint on
    # top. Rings live in the showcase only (not a component class), so they don't fight the controls.
    assigns = assign(assigns, :avatar_props, Map.drop(assigns.props, [:space]))

    ~H"""
    <.avatar_group id={"#{@id}-group"} space={@props[:space] || "small"}>
      <.avatar id={"#{@id}-icon"} class="ring-2 ring-base-100" {@avatar_props}>
        <:icon name="hero-user-solid" />
      </.avatar>
      <.avatar id={"#{@id}-sha"} class="ring-2 ring-base-100" {@avatar_props}>SHA</.avatar>
    </.avatar_group>
    """
  end

  def show(%{component: "tooltip"} = assigns) do
    # The tooltip's visible anchor comes from the `:trigger` slot ONLY — its inner_block is treated as
    # hidden tooltip *content* (see the component's render), so the generic `<.tooltip>{@sample}</.tooltip>`
    # preview renders an empty trigger and shows nothing. Give it a real trigger plus `text`; the styled
    # bubble (driven by variant/color/size/… from the controls via {@props}) appears on hover or focus.
    #
    # The `Floating` JS hook (1) caches clickable/position/delays at mount and never re-reads them in
    # updated(), and (2) RELOCATES the tooltip bubble to <body> (setupFloatingContent → appendChild) —
    # so it leaves LiveView's DOM tree entirely. That means patching the same element does nothing: the
    # flags keep their mounted behavior AND class changes for size/variant/color/rounded/padding never
    # reach the moved bubble. The fix is to remount on ANY control change — the tooltip holds no user
    # state, so we key each id on a hash of the full prop set. A changed id → LiveView removes+adds the
    # element → destroyed() returns the bubble to its parent and a fresh mount renders it with the new
    # classes/behavior.
    #
    # Two examples, because one trigger can't show every option: the BUTTON shows clickable (the label
    # flips hover↔click) and show_arrow (arrow on the bubble); the IN-TEXT one shows `inline` — when
    # inline the trigger is a `<span>` that flows inside the sentence, otherwise a block `<div>` that
    # breaks onto its own line.
    p = assigns.props
    assigns = assign(assigns, :fkey, :erlang.phash2(p))

    ~H"""
    <div class="flex w-full flex-col items-center gap-6">
      <div class="flex flex-col items-center gap-2">
        <.tooltip id={"#{@id}-btn-#{@fkey}"} text="This is a tooltip" position="bottom" {@props}>
          <:trigger>
            <.button variant="outline" color="primary" size="small">
              {if @props[:clickable], do: "Click me", else: "Hover me"}
            </.button>
          </:trigger>
        </.tooltip>
        <p class="text-xs text-base-content/40">
          {if @props[:clickable], do: "Click", else: "Hover or focus"} the trigger to reveal it.
        </p>
      </div>

      <div class="max-w-xs text-center text-sm leading-7 text-base-content/70">
        Mishka Chelekom is a
        <.tooltip
          id={"#{@id}-inline-#{@fkey}"}
          text="An inline tooltip flows with the text"
          position="top"
          {@props}
        >
          <:trigger>
            <span class="cursor-help text-primary underline decoration-dotted underline-offset-2">
              component library
            </span>
          </:trigger>
        </.tooltip>
        for Phoenix — toggle <strong>Inline</strong>
        to flow this trigger into the line or break it onto its own.
      </div>
    </div>
    """
  end

  # --- Fallback to the generated previews ---------------------------------------------

  def show(assigns), do: PreviewGenerated.show(assigns)

  # Demo data for the combobox preview — shows per-option flags/icons + option groups.
  defp combobox_countries do
    [
      %{group: "Americas", code: "br", flag: "🇧🇷", name: "Brazil"},
      %{group: "Americas", code: "ca", flag: "🇨🇦", name: "Canada"},
      %{group: "Americas", code: "us", flag: "🇺🇸", name: "United States"},
      %{group: "Europe", code: "de", flag: "🇩🇪", name: "Germany"},
      %{group: "Europe", code: "fr", flag: "🇫🇷", name: "France"},
      %{group: "Europe", code: "no", flag: "🇳🇴", name: "Norway"},
      %{group: "Asia", code: "jp", flag: "🇯🇵", name: "Japan"},
      %{group: "Asia", code: "kr", flag: "🇰🇷", name: "South Korea"},
      %{group: "Asia", code: "in", flag: "🇮🇳", name: "India"}
    ]
  end
end
