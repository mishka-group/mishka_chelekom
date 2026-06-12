defmodule DevelopmentWeb.Showcase.Examples.Clipboard do
  @moduledoc """
  Docs examples for the `clipboard` component, taken from the Mishka source docs
  (`mishka/.../docs/clipboard_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "text", title: "Text prop"},
      %{id: "target-selector", title: "Target selector prop"},
      %{id: "timeout", title: "Timeout prop"},
      %{id: "success-class", title: "Success class prop"},
      %{id: "copy-success-text", title: "Copy success text prop"},
      %{id: "content-slot", title: "Content slot"},
      %{id: "dynamic-label", title: "Dynamic label prop"}
    ]
  end

  def example(%{section: "text"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.clipboard text="hello@mishka.tools">
        <:trigger>
          <button class="px-3 py-1 border rounded">Copy Email</button>
        </:trigger>
      </.clipboard>
    </div>
    """
  end

  def example(%{section: "target-selector"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <div id="ex-clipboard-copy-me">https://mishka.tools/chelekom/docs</div>

      <.clipboard target_selector="#ex-clipboard-copy-me">
        <:trigger>
          <button class="px-3 py-1 border rounded">Copy Link</button>
        </:trigger>
      </.clipboard>
    </div>
    """
  end

  def example(%{section: "timeout"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.clipboard text="https://mishka.tools" timeout={4000}>
        <:trigger>
          <button class="px-3 py-1 border rounded">Copy URL</button>
        </:trigger>
      </.clipboard>
    </div>
    """
  end

  def example(%{section: "success-class"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.clipboard text="Invite Code: CHELEKOM123" success_class="bg-green-500 text-white">
        <:trigger>
          <button class="px-3 py-1 border rounded">Copy Code</button>
        </:trigger>
      </.clipboard>
    </div>
    """
  end

  def example(%{section: "copy-success-text"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.clipboard text="https://mishka.tools" copy_success_text="Link copied successfully!">
        <:trigger>
          <button class="px-3 py-1 border rounded">Copy Link</button>
        </:trigger>
      </.clipboard>
    </div>
    """
  end

  def example(%{section: "content-slot"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.clipboard>
        <:content>
          Invite code: <span class="font-mono">CHELEKOM2025</span>
        </:content>
        <:trigger>
          <button class="px-3 py-1 border rounded">Copy Code</button>
        </:trigger>
      </.clipboard>
    </div>
    """
  end

  def example(%{section: "dynamic-label"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <.clipboard
        text="my-secret-token"
        dynamic_label={true}
        success_class="bg-green-500 text-white rounded"
        copy_success_text="Copied Successfully"
        show_status_text={false}
        copy_error_text="Copy failed"
      >
        <:trigger>
          <button class="px-4 py-1 border rounded">Copy</button>
        </:trigger>
      </.clipboard>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
