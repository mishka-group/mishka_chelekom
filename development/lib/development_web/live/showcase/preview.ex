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
    <.collapse id={@id} {@props}>
      <:trigger>Toggle details</:trigger>
      The collapsible content lives here.
    </.collapse>
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

  def show(%{component: "clipboard"} = assigns) do
    ~H"""
    <.clipboard id={@id} {@props}>
      <:trigger>Copy</:trigger>
      Copyable text
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
    ~H"""
    <.form_wrapper id={@id} for={@form} {@props}>
      <p class="text-sm">Wrap any form fields here.</p>
    </.form_wrapper>
    """
  end

  def show(%{component: "email_field"} = assigns) do
    ~H"""
    <.email_field id={@id} name="demo" value="" label="Email" {@props} />
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
