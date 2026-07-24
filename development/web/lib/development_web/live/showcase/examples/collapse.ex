defmodule DevelopmentWeb.Showcase.Examples.Collapse do
  @moduledoc """
  Docs examples for the `collapse` component, taken from the Mishka source docs
  (`mishka/.../docs/collapse_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "basic-usage", title: "Basic Usage"},
      %{id: "initially-open", title: "Initially Open"},
      %{id: "custom-duration", title: "Custom Animation Duration"},
      %{id: "server-events", title: "Server Events"}
    ]
  end

  def example(%{section: "basic-usage"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.collapse id="ex-collapse-basic">
        <:trigger>
          <button class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
            Toggle Content
          </button>
        </:trigger>

        <div class="p-4 bg-gray-100 mt-2 rounded">
          This content will be hidden/shown when clicking the trigger button.
        </div>
      </.collapse>
    </div>
    """
  end

  def example(%{section: "initially-open"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.collapse id="ex-collapse-open" open={true}>
        <:trigger>
          <button class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
            Toggle (Initially Open)
          </button>
        </:trigger>

        <div class="p-4 bg-green-100 mt-2 rounded">
          This content is initially visible when the page loads.
        </div>
      </.collapse>
    </div>
    """
  end

  def example(%{section: "custom-duration"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.collapse id="ex-collapse-slow" duration={500}>
        <:trigger>
          <button class="px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600">
            Slow Animation (500ms)
          </button>
        </:trigger>

        <div class="p-4 bg-purple-100 mt-2 rounded">
          This collapse animation takes 500ms instead of the default 200ms.
        </div>
      </.collapse>
    </div>
    """
  end

  def example(%{section: "server-events"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.collapse id="ex-collapse-server" server_events={true}>
        <:trigger>
          <button class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600">
            Server Events Enabled
          </button>
        </:trigger>

        <div class="p-4 bg-red-100 mt-2 rounded">
          This collapse sends open/close events to the LiveView server.
          Check your browser's network tab to see the events.
        </div>
      </.collapse>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
