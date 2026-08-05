defmodule DevelopmentWeb.Showcase.Examples.Stat do
  @moduledoc """
  Docs examples for the `stat` component, taken from the Mishka source docs
  (`mishka/.../docs/stat_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "basic", title: "Basic usage"},
      %{id: "figure", title: "Figure slot"},
      %{id: "trend", title: "Trend indicator"},
      %{id: "actions", title: "Actions slot"},
      %{id: "variants", title: "Variants & colors"},
      %{id: "sizes", title: "Sizes"},
      %{id: "group", title: "Stat group"},
      %{id: "dashboard", title: "Dashboard recipe"}
    ]
  end

  def example(%{section: "basic"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.stat title="Total revenue" value="$45,231.89" description="Last 30 days" />
    </div>
    """
  end

  def example(%{section: "figure"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <.stat title="Total likes" value="25.6K" description="From all platforms" color="primary">
        <:figure><.icon name="hero-heart" /></:figure>
      </.stat>
      <.stat
        title="Comments"
        value="1.2K"
        description="This week"
        color="info"
        figure_position="end"
      >
        <:figure><.icon name="hero-chat-bubble-left-right" /></:figure>
      </.stat>
      <.stat
        title="Files uploaded"
        value="89"
        description="Today"
        color="warning"
        figure_position="top"
      >
        <:figure><.icon name="hero-document" /></:figure>
      </.stat>
    </div>
    """
  end

  def example(%{section: "trend"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <.stat title="MRR" value="$12,400" description="20.1% from last month" trend="up" />
      <.stat title="Churn" value="3.2%" description="0.4% from last month" trend="down" />
      <.stat title="ARPU" value="$84" description="Flat vs last month" trend="neutral" />
    </div>
    """
  end

  def example(%{section: "actions"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.stat title="Account balance" value="$89,400">
        <:actions>
          <.button color="success" size="small">Add funds</.button>
        </:actions>
      </.stat>
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <.stat variant="default" color="primary" title="Visits" value="42K" description="This week" />
      <.stat variant="shadow" color="success" title="Sales" value="$2.3K" description="Up 12%" />
      <.stat variant="bordered" color="info" title="Signups" value="1,204" description="Today" />
      <.stat variant="gradient" color="misc" title="Revenue" value="$98K" description="MTD" />
      <.stat variant="base" title="Latency" value="248ms" description="p95" />
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <.stat
        :for={s <- ~w(extra_small small medium large extra_large)}
        size={s}
        title={"Size #{s}"}
        value="42"
        description="example"
      />
    </div>
    """
  end

  def example(%{section: "group"} = assigns) do
    ~H"""
    <.stat_group>
      <.stat title="Downloads" value="31K" description="Last 30 days" />
      <.stat title="New users" value="4,200" description="+12% MoM" trend="up" />
      <.stat title="New posts" value="1,200" description="-3% MoM" trend="down" />
    </.stat_group>
    """
  end

  def example(%{section: "dashboard"} = assigns) do
    ~H"""
    <.stat_group>
      <.stat
        title="Revenue"
        value="$89,400"
        description="20.1% from last month"
        trend="up"
        color="success"
      >
        <:figure><.icon name="hero-currency-dollar" /></:figure>
      </.stat>
      <.stat
        title="Subscriptions"
        value="2,340"
        description="+180 from last month"
        trend="up"
        color="primary"
      >
        <:figure><.icon name="hero-user-group" /></:figure>
      </.stat>
      <.stat
        title="Active now"
        value="573"
        description="+201 since last hour"
        trend="up"
        color="info"
      >
        <:figure><.icon name="hero-bolt" /></:figure>
      </.stat>
    </.stat_group>
    """
  end

  def example(assigns), do: ~H""
end
