defmodule DevelopmentWeb.Showcase.Examples.Progress do
  @moduledoc """
  Docs examples for the `progress` component, taken from the Mishka source docs
  (`mishka/.../docs/progress_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "default", title: "Default variant"},
      %{id: "gradient", title: "Gradient variant"},
      %{id: "sizes", title: "Sizes"},
      %{id: "chunked", title: "Chunked progress"},
      %{id: "labels", title: "Label slot"},
      %{id: "ring", title: "Ring progress"},
      %{id: "semi_circle", title: "Semi circle progress"}
    ]
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.progress
        :for={c <- ~w(primary secondary dawn misc natural info silver success danger warning)}
        id={"progress-default-#{c}"}
        variant="default"
        color={c}
        value={60}
      />
    </div>
    """
  end

  def example(%{section: "gradient"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.progress
        :for={c <- ~w(natural primary secondary dawn misc info silver success danger warning)}
        id={"progress-gradient-#{c}"}
        variant="gradient"
        color={c}
        value={70}
      />
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.progress
        :for={s <- ~w(extra_small small medium large extra_large)}
        id={"progress-size-#{s}"}
        color="misc"
        variant="default"
        size={s}
        value={57}
      />
      <div class="flex gap-5 items-center">
        <.progress
          :for={s <- ~w(extra_small small medium large extra_large)}
          id={"progress-vsize-#{s}"}
          variation="vertical"
          size={s}
          color="info"
          variant="default"
          value={55}
        />
      </div>
    </div>
    """
  end

  def example(%{section: "chunked"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.progress id="ex-progress-chunked-1">
        <.progress_section variant="default" color="primary" value={10} />
        <.progress_section variant="default" color="secondary" value={15} />
        <.progress_section variant="default" color="misc" value={10} />
        <.progress_section variant="default" color="danger" value={5} />
        <.progress_section variant="default" color="warning" value={10} />
        <.progress_section variant="default" color="success" value={10} />
        <.progress_section variant="default" color="info" value={5} />
      </.progress>

      <.progress variation="vertical" size="large">
        <.progress_section value={40} color="dawn" variant="default" variation="vertical" />
        <.progress_section value={30} color="misc" variant="default" variation="vertical" />
        <.progress_section value={10} color="danger" variant="default" variation="vertical" />
      </.progress>
    </div>
    """
  end

  def example(%{section: "labels"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <.progress id="ex-progress-label-1" size="double_large">
        <.progress_section variant="default" color="primary" value={50}>
          <:label class="font-bold">Images</:label>
        </.progress_section>
        <.progress_section variant="default" color="warning" value={25}>
          <:label>15</:label>
        </.progress_section>
      </.progress>

      <.progress id="ex-progress-label-2" size="extra_large">
        <.progress_section variant="default" color="misc" value={80}>
          <:label class="font-bold">Other</:label>
        </.progress_section>
      </.progress>
    </div>
    """
  end

  def example(%{section: "ring"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-6">
      <.ring_progress id="ex-ring-1" value={60} color="primary" />
      <.ring_progress id="ex-ring-2" value={60} color="success" />
      <.ring_progress id="ex-ring-3" value={60} color="danger" />
      <.ring_progress id="ex-ring-4" value={45} color="dawn" label="Uploading" />
    </div>
    """
  end

  def example(%{section: "semi_circle"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-6">
      <.semi_circle_progress id="ex-semi-1" value={50} color="misc" size={160} />
      <.semi_circle_progress id="ex-semi-2" value={50} color="info" size={160} />
      <.semi_circle_progress id="ex-semi-3" value={100} color="success" size={160} label="Completed" />
    </div>
    """
  end

  def example(assigns), do: ~H""
end
