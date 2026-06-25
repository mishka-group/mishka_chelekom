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

  def show(%{component: "shape"} = assigns) do
    assigns =
      assign(
        assigns,
        :shape_half,
        if(assigns.props[:half] in [nil, "none", ""], do: nil, else: assigns.props[:half])
      )

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
        state =
          cond do
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

  def show(%{component: "table"} = assigns) do
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

  def show(%{component: "table_content"} = assigns) do
    sections = [
      {"introduction", "Introduction",
       "A components & UI kit for Phoenix & LiveView, generated into your app with zero runtime dependency."},
      {"installation", "Installation",
       "Add the package, run the generator, and the components are copied straight into your project."},
      {"configuration", "Configuration",
       "Tailwind v4, theme tokens, and the Kit macro let you restyle everything without touching the source."},
      {"components", "Components",
       "Buttons, forms, tables, navigation, overlays — 70+ styled components, plus a headless layer."},
      {"api", "API reference",
       "Every component documents its attributes, slots, and the events it emits."}
    ]

    assigns = assign(assigns, sections: sections, scroll_id: "#{assigns.id}-doc")

    ~H"""
    <div
      id={@scroll_id}
      class={[
        "max-h-80 w-full overflow-y-auto rounded-box border border-base-300 bg-base-100 p-3",
        @props[:animated] && "scroll-smooth"
      ]}
    >
      <div class="sticky top-0 z-10 mb-2 bg-base-100 pb-2">
        <.table_content id={@id} {@props} title="On this page">
          <.content_item
            :for={{anchor, label, _} <- @sections}
            icon="hero-hashtag"
            active={anchor == "introduction"}
          >
            <.link href={"#" <> @scroll_id <> "-" <> anchor}>{label}</.link>
          </.content_item>
        </.table_content>
      </div>

      <div class="space-y-8 px-1 pt-2 text-sm">
        <section
          :for={{anchor, label, body} <- @sections}
          id={@scroll_id <> "-" <> anchor}
          class="scroll-mt-2"
        >
          <h4 class="mb-1 font-semibold">{label}</h4>
          <p class="text-base-content/60">{body}</p>
          <div class="mt-3 h-16 rounded-lg bg-base-200/50"></div>
        </section>
      </div>
    </div>
    """
  end

  def show(%{component: "timeline"} = assigns) do
    assigns =
      assign(assigns, :milestones, [
        %{
          icon: "hero-flag",
          title: "Kickoff",
          time: "January 2026",
          desc: "Project setup and initial configuration."
        },
        %{
          icon: "hero-code-bracket",
          title: "Development",
          time: "February 2026",
          desc: "Built and tested the component library."
        },
        %{
          icon: "hero-rocket-launch",
          title: "Launch",
          time: "March 2026",
          desc: "Shipped the first release to production."
        },
        %{
          icon: "hero-star",
          title: "Milestone",
          time: "April 2026",
          desc: "Reached 1,000 active users."
        }
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

  def show(%{component: "typography"} = assigns) do
    ~H"""
    <div class="space-y-2 text-left">
      <.h1 color={@props[:color]}>Heading one</.h1>
      <.h2 color={@props[:color]}>Heading two</.h2>
      <.h3 color={@props[:color]}>Heading three</.h3>
      <.h4 color={@props[:color]}>Heading four</.h4>
      <.p color={@props[:color]} size={@props[:size]}>
        Body paragraph with <.strong>strong</.strong>, <.em>emphasis</.em>, <.mark>a highlight</.mark>, <.u>underline</.u>, <.s>strikethrough</.s>, and an
        <.abbr title="HyperText Markup Language">HTML</.abbr>
        abbreviation.
      </.p>
      <.small color={@props[:color]}>Small print — captions and fine details.</.small>
    </div>
    """
  end

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

  def show(%{component: "breadcrumb"} = assigns) do
    ~H"""
    <.breadcrumb id={@id} {@props}>
      <:item icon="hero-home" link="/">Home</:item>
      <:item icon="hero-folder" link="/docs">Docs</:item>
      <:item icon="hero-bookmark">Breadcrumb</:item>
    </.breadcrumb>
    """
  end

  def show(%{component: "dropdown"} = assigns) do
    assigns =
      assigns
      |> assign(:dd_id, "#{assigns.id}-#{:erlang.phash2(assigns.props)}")
      |> assign(:smart?, assigns.props[:smart_position] == true)

    ~H"""
    <div class="w-full">
      <div
        class={["flex w-full justify-center", (@smart? && "items-end") || "items-center"]}
        style={@smart? && "height: 70vh; max-height: 34rem;"}
      >
        <.dropdown id={@dd_id} {@props}>
          <:trigger>
            <.button variant="outline" color="natural" size="small" class="gap-2">
              Account menu <.icon name="hero-chevron-down" class="size-4 opacity-70" />
            </.button>
          </:trigger>
          <:content>
            <ul class="min-w-44 text-sm">
              <li class="flex cursor-pointer items-center gap-2 px-3 py-2 hover:opacity-80">
                <.icon name="hero-user-circle" class="size-4 opacity-70" /> Profile
              </li>
              <li class="flex cursor-pointer items-center gap-2 px-3 py-2 hover:opacity-80">
                <.icon name="hero-cog-6-tooth" class="size-4 opacity-70" /> Settings
              </li>
              <li class="flex cursor-pointer items-center gap-2 px-3 py-2 hover:opacity-80">
                <.icon name="hero-credit-card" class="size-4 opacity-70" /> Billing
              </li>
              <li class="flex cursor-pointer items-center gap-2 px-3 py-2 hover:opacity-80">
                <.icon name="hero-arrow-right-on-rectangle" class="size-4 opacity-70" /> Sign out
              </li>
            </ul>
          </:content>
        </.dropdown>
      </div>
      <p :if={@smart?} class="mt-3 text-center text-xs text-base-content/50">
        Smart position on: the trigger sits low in the viewport, so opening the menu flips it
        <span class="font-medium">upward</span>
        when there's no room below.
      </p>
    </div>
    """
  end

  def show(%{component: "footer"} = assigns) do
    ~H"""
    <div class="w-full text-left">
      <.footer id={@id} space="small" {@props}>
        <.footer_section padding="small" class="border-b border-current/15">
          <h4 class="flex items-center gap-1.5 font-bold text-base">
            <.icon name="hero-sparkles" class="size-4" /> Mishka Chelekom
          </h4>
        </.footer_section>

        <.footer_section padding="small" class="grid grid-cols-2 gap-3">
          <ul class="space-y-1.5 text-sm">
            <li><.link href="#" class="hover:underline">Docs</.link></li>
            <li><.link href="#" class="hover:underline">Components</.link></li>
            <li><.link href="#" class="hover:underline">Blog</.link></li>
          </ul>
          <ul class="space-y-1.5 text-sm">
            <li><.link href="#" class="hover:underline">About</.link></li>
            <li><.link href="#" class="hover:underline">Contact</.link></li>
            <li><.link href="#" class="hover:underline">License</.link></li>
          </ul>
        </.footer_section>

        <.footer_section
          text_position="center"
          padding="small"
          class="border-t border-current/15 text-xs"
        >
          © 2026 Mishka Chelekom. All rights reserved.
        </.footer_section>
      </.footer>
    </div>
    """
  end

  def show(%{component: "mega_menu"} = assigns) do
    ~H"""
    <div class="w-full text-left">
      <p class="mb-2 text-xs text-base-content/50">
        Hover the trigger to open it — enable <span class="font-medium">clickable</span> to switch to
        click-to-toggle.
      </p>
      <div class="relative min-h-48">
        <.mega_menu id={@id} class="relative" top_gap="none" width="full" {@props}>
          <:trigger>
            <.button variant="outline" color="natural" size="small" class="w-full justify-between">
              Products <.icon name="hero-chevron-down" class="size-4" />
            </.button>
          </:trigger>

          <div class="grid grid-cols-2 gap-x-6 gap-y-1 p-1">
            <ul class="space-y-2">
              <li class="cursor-pointer hover:underline hover:text-primary-light">Components</li>
              <li class="cursor-pointer hover:underline hover:text-primary-light">Templates</li>
              <li class="cursor-pointer hover:underline hover:text-primary-light">Pricing</li>
            </ul>
            <ul class="space-y-2">
              <li class="cursor-pointer hover:underline hover:text-primary-light">Docs</li>
              <li class="cursor-pointer hover:underline hover:text-primary-light">Changelog</li>
              <li class="cursor-pointer hover:underline hover:text-primary-light">Support</li>
            </ul>
          </div>
        </.mega_menu>
      </div>
    </div>
    """
  end

  def show(%{component: "menu"} = assigns) do
    ~H"""
    <.menu id={@id} {@props} class="w-full max-w-[260px] mx-auto text-left">
      <li>
        <.button
          display="flex"
          full_width
          size="py-1 px-2"
          icon="hero-home"
          icon_class="size-5"
          content_position="start"
        >
          Dashboard
        </.button>
      </li>

      <li>
        <.button
          display="flex"
          full_width
          size="py-1 px-2"
          icon="hero-envelope-open"
          icon_class="size-5"
          content_position="start"
          content_class="flex justify-between items-center gap-2 w-full"
        >
          <span>Inbox</span>
          <.badge size="w-7 text-[11px] h-5">10</.badge>
        </.button>
      </li>

      <li>
        <.button
          phx-click={
            JS.toggle(to: "#menu-ecom-sub")
            |> JS.toggle_class("rotate-180", to: "#menu-ecom-caret")
          }
          display="flex"
          full_width
          size="py-1 px-2"
          icon="hero-shopping-cart"
          icon_class="size-5"
          content_position="start"
          content_class="flex justify-between items-center gap-2 w-full"
        >
          E-commerce
          <span id="menu-ecom-caret" class="rotate-180 transition-transform duration-200">
            <.icon name="hero-chevron-down" class="size-4 opacity-60" />
          </span>
        </.button>

        <ul id="menu-ecom-sub" class="mt-1 ml-5 space-y-1 border-l border-base-300 pl-3">
          <li>
            <.button
              display="flex"
              full_width
              size="py-1 px-2"
              icon="hero-cube"
              icon_class="size-4 opacity-70"
              content_position="start"
            >
              Products
            </.button>
          </li>
          <li>
            <.button
              display="flex"
              full_width
              size="py-1 px-2"
              icon="hero-document-text"
              icon_class="size-4 opacity-70"
              content_position="start"
            >
              Invoices
            </.button>
          </li>
        </ul>
      </li>

      <li>
        <.button
          display="flex"
          full_width
          size="py-1 px-2"
          icon="hero-user-group"
          icon_class="size-5"
          content_position="start"
        >
          Users
        </.button>
      </li>

      <li>
        <.button
          display="flex"
          full_width
          size="py-1 px-2"
          icon="hero-cog-6-tooth"
          icon_class="size-5"
          content_position="start"
        >
          Settings
        </.button>
      </li>
    </.menu>
    """
  end

  def show(%{component: "navbar"} = assigns) do
    ~H"""
    <div class="w-full overflow-hidden">
      <.navbar id={@id} name="Acme" link="#" class="w-full" {@props}>
        <:list icon="hero-home" icon_class="size-4 block me-1.5">
          <.link href="#">Home</.link>
        </:list>
        <:list icon="hero-squares-2x2" icon_class="size-4 block me-1.5">
          <.link href="#">Dashboard</.link>
        </:list>
      </.navbar>
    </div>
    """
  end

  def show(%{component: "scroll_area"} = assigns) do
    items = [
      {"Deployment succeeded", "production-web-01 · build #482", "2m ago"},
      {"New comment on PR #128", "Refactor the auth pipeline middleware", "14m ago"},
      {"Database backup completed", "snapshot stored to s3://backups/db", "1h ago"},
      {"Invitation accepted", "sarah.kim@example.com joined the team", "3h ago"},
      {"Build queued", "feature/scroll-area pipeline run", "5h ago"},
      {"SSL certificate renewed", "valid until 2027-06-15 · auto-renew", "1d ago"}
    ]

    assigns =
      assigns
      |> assign(:items, items)
      |> assign(:horizontal?, assigns.props[:horizontal] == true)

    ~H"""
    <div class="w-full max-w-[280px] text-left rounded-lg border border-black/10 dark:border-white/10">
      <.scroll_area id={@id} height="h-44" width="w-full" {@props}>
        <div :if={@horizontal?} class="flex w-max gap-3 pe-2">
          <div
            :for={{title, detail, when_} <- @items}
            class="w-44 shrink-0 rounded-md bg-black/5 p-2 dark:bg-white/10"
          >
            <p class="truncate text-sm font-semibold">{title}</p>
            <p class="mt-0.5 truncate text-xs opacity-70">{detail}</p>
            <span class="text-[11px] opacity-60">{when_}</span>
          </div>
        </div>

        <div :if={!@horizontal?} class="space-y-2">
          <div
            :for={{title, detail, when_} <- @items}
            class="rounded-md bg-black/5 p-2 dark:bg-white/10"
          >
            <div class="flex items-center justify-between gap-2">
              <p class="truncate text-sm font-semibold">{title}</p>
              <span class="whitespace-nowrap text-[11px] opacity-60">{when_}</span>
            </div>
            <p class="whitespace-nowrap text-xs opacity-70">{detail}</p>
          </div>
        </div>
      </.scroll_area>
    </div>
    """
  end

  def show(%{component: "sidebar"} = assigns) do
    ~H"""
    <.sidebar
      id={@id}
      {@props}
      list_wrapper_class="ps-2.5"
      class="!relative !h-auto !z-0 !transform-none max-w-full w-full max-h-72 rounded"
    >
      <:item icon="hero-home" label="Dashboard" link="/" class="mb-2 text-sm" />
      <:item icon="hero-inbox" label="Messages" link="/" class="mb-2 text-sm" />
      <:item icon="hero-folder" label="Projects" link="/" class="mb-2 text-sm" />
      <:item icon="hero-chart-bar" label="Analytics" link="/" class="mb-2 text-sm" />
      <:item icon="hero-cog-6-tooth" label="Settings" link="/" class="mb-2 text-sm" />
    </.sidebar>
    """
  end

  def show(%{component: "drawer"} = assigns) do
    pos = Map.get(assigns.props, :position, "left")

    assigns =
      assigns
      |> assign(:side?, pos in ["left", "right", nil])
      |> assign(:pos, pos)
      |> assign(:drawer_id, "#{assigns.id}-#{:erlang.phash2(assigns.props)}")

    ~H"""
    <div class="relative grid h-72 w-full place-items-center overflow-hidden rounded-box border border-base-300 bg-base-200/30">
      <.button
        size="small"
        variant="outline"
        color="natural"
        phx-click={DevelopmentWeb.Components.Drawer.show_drawer(@drawer_id, @pos)}
      >
        Open drawer
      </.button>

      <.drawer
        id={@drawer_id}
        title="Menu"
        class={[
          "!absolute !z-10",
          @side? && "!h-full",
          !@side? && "!inset-x-0 !w-full"
        ]}
        overlay_class="!absolute"
        {@props}
      >
        <ul class="space-y-1 text-sm">
          <li class="flex items-center gap-2 rounded px-3 py-2 hover:bg-black/10 cursor-pointer">
            <.icon name="hero-home" class="size-4" /> Dashboard
          </li>
          <li class="flex items-center gap-2 rounded px-3 py-2 hover:bg-black/10 cursor-pointer">
            <.icon name="hero-inbox" class="size-4" /> Inbox
          </li>
          <li class="flex items-center gap-2 rounded px-3 py-2 hover:bg-black/10 cursor-pointer">
            <.icon name="hero-star" class="size-4" /> Favorites
          </li>
          <li class="flex items-center gap-2 rounded px-3 py-2 hover:bg-black/10 cursor-pointer">
            <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
          </li>
        </ul>
      </.drawer>
    </div>
    """
  end

  def show(%{component: "modal"} = assigns) do
    modal_id = "#{assigns.id}-#{:erlang.phash2(assigns.props)}"
    assigns = assign(assigns, :modal_id, modal_id)

    ~H"""
    <div class="relative grid h-60 w-full place-items-center overflow-hidden rounded-box border border-base-300 bg-base-200/30">
      <.button
        size="small"
        variant="outline"
        color="natural"
        phx-click={DevelopmentWeb.Components.Modal.show_modal(@modal_id)}
      >
        Open modal
      </.button>

      <.modal
        id={@modal_id}
        title="Delete project?"
        class="!absolute !inset-0"
        overlay_class="!absolute"
        wrapper_class="!absolute"
        {@props}
      >
        <div class="space-y-4">
          <p class="text-sm">
            This permanently removes the <span class="font-medium">Chelekom</span>
            workspace and all of its data. This action cannot be undone.
          </p>
          <div class="flex justify-end gap-2">
            <.button
              type="button"
              variant="default"
              color="natural"
              size="small"
              phx-click={DevelopmentWeb.Components.Modal.hide_modal(@modal_id)}
            >
              Cancel
            </.button>
            <.button
              type="button"
              variant="default"
              color="danger"
              size="small"
              phx-click={DevelopmentWeb.Components.Modal.hide_modal(@modal_id)}
            >
              Delete
            </.button>
          </div>
        </div>
      </.modal>
    </div>
    """
  end

  def show(%{component: "overlay"} = assigns) do
    ~H"""
    <div class="relative h-64 w-full overflow-hidden rounded-box border border-base-300 bg-base-100">
      <div class="space-y-3 p-4">
        <div class="flex items-center gap-3">
          <div class="size-10 shrink-0 rounded-full bg-base-300"></div>
          <div class="space-y-2">
            <div class="h-3 w-32 rounded bg-base-300"></div>
            <div class="h-2.5 w-20 rounded bg-base-200"></div>
          </div>
        </div>
        <div class="h-2.5 w-full rounded bg-base-200"></div>
        <div class="h-2.5 w-5/6 rounded bg-base-200"></div>
        <div class="h-2.5 w-2/3 rounded bg-base-200"></div>
        <div class="mt-4 h-9 w-28 rounded-lg bg-base-300"></div>
      </div>
      <.overlay id={@id} {@props}>
        <div class="flex h-full flex-col items-center justify-center gap-3">
          <.spinner size="large" />
          <div class="text-sm font-medium text-base-content">Loading account…</div>
        </div>
      </.overlay>
    </div>
    """
  end

  def show(%{component: "popover"} = assigns) do
    p = assigns.props

    assigns =
      assigns
      |> assign(:fkey, :erlang.phash2(p))
      |> assign(:inline?, p[:inline] == true)

    ~H"""
    <div class="flex w-full flex-col items-center gap-4 py-10">
      <p :if={@inline?} class="max-w-xs text-center text-sm leading-relaxed">
        Mishka Chelekom is written in
        <.popover id={"#{@id}-#{@fkey}"} {@props}>
          <:trigger class="cursor-pointer font-medium text-primary-light underline decoration-dotted underline-offset-2">
            Elixir
          </:trigger>
          <:content>
            <span class="block font-semibold">Elixir</span>
            <span class="block text-xs leading-relaxed opacity-90">
              A dynamic, functional language for building scalable, maintainable applications.
            </span>
          </:content>
        </.popover>
        — {if @props[:clickable], do: "click", else: "hover"} the highlighted word.
      </p>

      <.popover :if={!@inline?} id={"#{@id}-#{@fkey}"} {@props}>
        <:trigger>
          <.button variant="outline" color="primary" size="small" class="gap-1.5">
            <.icon name="hero-information-circle" class="size-4" /> Account details
          </.button>
        </:trigger>
        <:content>
          <h4 class="font-semibold">Workspace plan</h4>
          <span class="block text-xs leading-relaxed opacity-90">
            You are on the Pro plan with 8 of 10 seats used. Upgrade any time to add more members.
          </span>
          <a href="#" class="block text-xs underline underline-offset-2">
            Manage billing <.icon name="hero-arrow-right" class="size-3" />
          </a>
        </:content>
      </.popover>

      <p :if={!@inline?} class="text-xs text-base-content/40">
        {if @props[:clickable], do: "Click", else: "Hover or focus"} the trigger to reveal it.
      </p>
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

  def show(%{component: "divider"} = assigns) do
    ~H"""
    <div>
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
    <div class="relative w-full max-w-[300px] overflow-hidden">
      <.dock id={@id} {@props} class="!relative !w-full !translate-x-0 !bottom-auto !top-auto">
        <:item icon="hero-home" label="Home" navigate="/" active />
        <:item icon="hero-inbox" label="Inbox" navigate="/inbox" badge="3" />
        <:item icon="hero-bell" label="Alerts" navigate="/alerts" badge="9+" />
        <:item icon="hero-cog-6-tooth" label="Settings" navigate="/settings" />
      </.dock>
    </div>
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
    assigns =
      assign(
        assigns,
        :img_filter,
        if(assigns.props[:filter] in [nil, "none"], do: "", else: assigns.props[:filter])
      )

    ~H"""
    <div class="w-64">
      <.image
        id={@id}
        src="/images/card-media.svg"
        alt="Abstract dusk landscape (locally generated, no copyright)"
        rounded={@props[:rounded]}
        filter={@img_filter}
        filter_size="large"
        class="w-full"
      />
    </div>
    """
  end

  def show(%{component: "video"} = assigns) do
    ~H"""
    <.video id={@id} thumbnail="/images/video-poster.jpg" controls preload="metadata" {@props}>
      <:source src="/videos/sample.mp4" type="video/mp4" />
    </.video>
    """
  end

  def show(%{component: "pagination"} = assigns) do
    presence_off = fn {k, v} -> k in [:grouped, :hide_controls, :show_edges] and v == false end
    assigns = assign(assigns, :pg_props, assigns.props |> Enum.reject(presence_off) |> Map.new())

    ~H"""
    <.pagination id={@id} {@pg_props} />
    """
  end

  def show(%{component: "form_wrapper"} = assigns) do
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
    ~H"""
    <.form for={@form} phx-change="validate" phx-submit="save" class="w-full">
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
    p = assigns.props
    assigns = assign(assigns, :fkey, :erlang.phash2(p))

    ~H"""
    <div class="flex w-full flex-col items-center gap-6 py-10">
      <div class="flex flex-col items-center gap-2">
        <.tooltip id={"#{@id}-btn-#{@fkey}"} text="This is a tooltip" {@props}>
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

  def show(assigns), do: PreviewGenerated.show(assigns)

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
