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
      <:item title="Zero runtime?">Components are generated into your app — no prod dependency.</:item>
    </.accordion>
    """
  end

  def show(%{component: "carousel"} = assigns) do
    ~H"""
    <.carousel id={@id} {@props}>
      <:slide title="First slide" description="A sample slide" image="https://picsum.photos/seed/1/640/280" />
      <:slide title="Second slide" description="Another slide" image="https://picsum.photos/seed/2/640/280" />
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

  # --- Fallback to the generated previews ---------------------------------------------

  def show(assigns), do: PreviewGenerated.show(assigns)
end
