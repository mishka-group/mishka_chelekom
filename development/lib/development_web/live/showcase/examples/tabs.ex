defmodule DevelopmentWeb.Showcase.Examples.Tabs do
  @moduledoc """
  Docs examples for the `tabs` component, taken from the Mishka source docs
  (`mishka/.../docs/tabs_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "default", title: "Default Variant"},
      %{id: "pills", title: "Pills Variant"},
      %{id: "sizes", title: "Size prop"},
      %{id: "border", title: "Border prop"},
      %{id: "rounded", title: "Rounded prop"},
      %{id: "vertical", title: "Tab vertical prop"},
      %{id: "icons", title: "Tab slot icons"},
      %{id: "badge", title: "Tab slot badge"}
    ]
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.tabs
        :for={c <- ~w(natural primary secondary success danger info)}
        id={"ex-tabs-default-#{c}"}
        padding="large"
        variant="default"
        color={c}
      >
        <:tab icon="hero-user-circle">Profile</:tab>
        <:tab icon="hero-ticket">Tickets</:tab>
        <:tab icon="hero-cog-6-tooth">Settings</:tab>

        <:panel>
          <p>
            The Profile tab allows you to view and edit your personal details. Keep your information
            up to date to ensure a seamless experience across the platform.
          </p>
        </:panel>
        <:panel>
          <p>
            In the Tickets tab, you can manage all your active and past tickets. Whether you need
            assistance or just want to check your ticket history, this tab has all the relevant details.
          </p>
        </:panel>
        <:panel>
          <p>
            The Settings tab gives you access to customizable options for your account. Here, you can
            adjust notifications, privacy settings, and other preferences to personalize your experience.
          </p>
        </:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "pills"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.tabs
        :for={c <- ~w(natural primary secondary success danger info)}
        id={"ex-tabs-pills-#{c}"}
        padding="large"
        color={c}
        variant="pills"
      >
        <:tab icon="hero-user-circle">Profile</:tab>
        <:tab icon="hero-ticket">Tickets</:tab>
        <:tab icon="hero-cog-6-tooth">Settings</:tab>

        <:panel>
          <p>
            The Profile tab allows you to view and edit your personal details. Keep your information
            up to date to ensure a seamless experience across the platform.
          </p>
        </:panel>
        <:panel>
          <p>
            In the Tickets tab, you can manage all your active and past tickets. Whether you need
            assistance or just want to check your ticket history, this tab has all the relevant details.
          </p>
        </:panel>
        <:panel>
          <p>
            The Settings tab gives you access to customizable options for your account. Here, you can
            adjust notifications, privacy settings, and other preferences to personalize your experience.
          </p>
        </:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.tabs
        :for={s <- ~w(extra_small small medium large extra_large)}
        id={"ex-tabs-size-#{s}"}
        padding="large"
        variant="pills"
        color="primary"
        size={s}
      >
        <:tab icon="hero-user-circle">Profile</:tab>
        <:tab icon="hero-ticket">Tickets</:tab>
        <:tab icon="hero-cog-6-tooth">Settings</:tab>

        <:panel>
          <p>The Profile tab allows you to view and edit your personal details.</p>
        </:panel>
        <:panel>
          <p>In the Tickets tab, you can manage all your active and past tickets.</p>
        </:panel>
        <:panel>
          <p>The Settings tab gives you access to customizable options for your account.</p>
        </:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.tabs
        :for={b <- ~w(extra_small small medium large extra_large)}
        id={"ex-tabs-border-#{b}"}
        padding="large"
        color="secondary"
        variant="pills"
        border={b}
      >
        <:tab icon="hero-user-circle">Profile</:tab>
        <:tab icon="hero-ticket">Tickets</:tab>
        <:tab icon="hero-cog-6-tooth">Settings</:tab>

        <:panel>
          <p>The Profile tab allows you to view and edit your personal details.</p>
        </:panel>
        <:panel>
          <p>In the Tickets tab, you can manage all your active and past tickets.</p>
        </:panel>
        <:panel>
          <p>The Settings tab gives you access to customizable options for your account.</p>
        </:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.tabs
        :for={r <- ~w(extra_small small medium large extra_large)}
        id={"ex-tabs-rounded-#{r}"}
        padding="large"
        color="success"
        variant="pills"
        rounded={r}
      >
        <:tab icon="hero-user-circle">Profile</:tab>
        <:tab icon="hero-ticket">Tickets</:tab>
        <:tab icon="hero-cog-6-tooth">Settings</:tab>

        <:panel>
          <p>The Profile tab allows you to view and edit your personal details.</p>
        </:panel>
        <:panel>
          <p>In the Tickets tab, you can manage all your active and past tickets.</p>
        </:panel>
        <:panel>
          <p>The Settings tab gives you access to customizable options for your account.</p>
        </:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "vertical"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.tabs id="ex-tabs-vertical-pills" padding="large" vertical variant="pills" color="misc">
        <:tab icon="hero-user-circle">Profile</:tab>
        <:tab icon="hero-ticket">Tickets</:tab>
        <:tab icon="hero-cog-6-tooth">Settings</:tab>

        <:panel>
          <p>The Profile tab allows you to view and edit your personal details.</p>
        </:panel>
        <:panel>
          <p>In the Tickets tab, you can manage all your active and past tickets.</p>
        </:panel>
        <:panel>
          <p>The Settings tab gives you access to customizable options for your account.</p>
        </:panel>
      </.tabs>

      <.tabs id="ex-tabs-vertical-default" padding="large" vertical variant="default" color="secondary">
        <:tab icon="hero-user-circle">Profile</:tab>
        <:tab icon="hero-ticket">Tickets</:tab>
        <:tab icon="hero-cog-6-tooth">Settings</:tab>

        <:panel>
          <p>The Profile tab allows you to view and edit your personal details.</p>
        </:panel>
        <:panel>
          <p>In the Tickets tab, you can manage all your active and past tickets.</p>
        </:panel>
        <:panel>
          <p>The Settings tab gives you access to customizable options for your account.</p>
        </:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "icons"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.tabs id="ex-tabs-icons" padding="large" color="warning" variant="default">
        <:tab icon="hero-user-circle">Profile</:tab>
        <:tab icon="hero-ticket" icon_position="end">Tickets</:tab>
        <:tab icon="hero-cog-6-tooth" icon_position="end">Settings</:tab>

        <:panel>
          <p>The Profile tab allows you to view and edit your personal details.</p>
        </:panel>
        <:panel>
          <p>In the Tickets tab, you can manage all your active and past tickets.</p>
        </:panel>
        <:panel>
          <p>The Settings tab gives you access to customizable options for your account.</p>
        </:panel>
      </.tabs>
    </div>
    """
  end

  def example(%{section: "badge"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.tabs id="ex-tabs-badge-1" padding="large" color="danger" variant="pills">
        <:tab>Profile</:tab>
        <:tab badge="8">Tickets</:tab>
        <:tab>Settings</:tab>

        <:panel>
          <p>The Profile tab allows you to view and edit your personal details.</p>
        </:panel>
        <:panel>
          <p>In the Tickets tab, you can manage all your active and past tickets.</p>
        </:panel>
        <:panel>
          <p>The Settings tab gives you access to customizable options for your account.</p>
        </:panel>
      </.tabs>

      <.tabs id="ex-tabs-badge-2" padding="large" color="misc" variant="pills">
        <:tab badge_color="danger" badge="9+" badge_variant="bordered" badge_size="size-6 text-[11px]">
          Notification
        </:tab>
        <:tab>Messages</:tab>
        <:tab>Account</:tab>

        <:panel>
          <p>You have new notifications waiting for your review.</p>
        </:panel>
        <:panel>
          <p>Read and reply to your latest messages here.</p>
        </:panel>
        <:panel>
          <p>Manage your account preferences and security settings.</p>
        </:panel>
      </.tabs>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
