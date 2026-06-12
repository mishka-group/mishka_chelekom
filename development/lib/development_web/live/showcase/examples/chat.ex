defmodule DevelopmentWeb.Showcase.Examples.Chat do
  @moduledoc """
  Docs examples for the `chat` component, taken from the Mishka source docs
  (`mishka/.../docs/chat_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "variants", title: "Variants"},
      %{id: "colors", title: "Colors"},
      %{id: "status", title: "Status slot"},
      %{id: "meta", title: "Meta slot"},
      %{id: "font_weight", title: "Font weight"},
      %{id: "border", title: "Border"},
      %{id: "rounded", title: "Rounded"},
      %{id: "position", title: "Position"},
      %{id: "flow", title: "Chat flow"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat :for={v <- ~w(default outline transparent shadow gradient bordered)} variant={v} color="natural">
        <.chat_section>
          <div>Shahryar Tavakkoli</div>
          <p>This bubble uses the {v} variant of the chat component.</p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat :for={c <- ~w(natural primary secondary success warning danger info misc dawn)} variant="default" color={c}>
        <.chat_section>
          <div>{String.capitalize(c)}</div>
          <p>Mishka Chelekom chat bubble in the {c} color.</p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(%{section: "status"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat variant="default" color="info">
        <.chat_section>
          <div>Shahryar Tavakkoli</div>
          <p>Mishka Chelekom is easy to install and use for fast integration with your Phoenix LiveView projects.</p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(%{section: "meta"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat variant="default" color="info">
        <.chat_section>
          <div>Shahryar Tavakkoli</div>
          <p>Mishka Chelekom is easy to install and use for fast integration with your Phoenix LiveView projects.</p>

          <:meta>
            <div class="flex items-center justify-between gap-2">
              <div>20:40</div>
              <div>
                <.icon name="hero-check" class="size-3.5" />
              </div>
            </div>
          </:meta>
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(%{section: "font_weight"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat variant="default" color="natural">
        <.chat_section font_weight="font-bold">
          <div>Shahryar Tavakkoli</div>
          <p>Mishka Chelekom is easy to install and use for fast integration with your Phoenix LiveView projects.</p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat :for={b <- ~w(extra_small small medium large extra_large)} border={b} variant="default" color="natural">
        <.chat_section>
          <div>Border: {b}</div>
          <p>That's awesome. I think our users will really appreciate the improvements.</p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat :for={r <- ~w(extra_small small medium large extra_large)} rounded={r} variant="default" color="natural">
        <.chat_section>
          <div>Rounded: {r}</div>
          <p>That's awesome. I think our users will really appreciate the improvements.</p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(%{section: "position"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <.chat variant="default" color="natural">
        <.chat_section>
          <div>Mona Aghili</div>
          <p>This message is in the normal (left-aligned) position.</p>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>

      <.chat position="flipped" variant="default" color="natural">
        <.chat_section>
          <div>Shahryar Tavakkoli</div>
          <p>This message is in the flipped (right-aligned) position.</p>
          <:status time="22:11" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(%{section: "flow"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-10">
      <.chat variant="gradient" color="misc">
        <.avatar size="medium" rounded="full" border="small" color="silver">MA</.avatar>

        <.chat_section>
          <div>Hey, have you checked out the new Mishka Chelekom UI Kit?</div>
          <:status time="22:10" deliver="Delivered" />
        </.chat_section>
      </.chat>

      <.chat position="flipped" variant="gradient" color="misc">
        <.avatar size="medium" rounded="full" border="small" color="silver">ST</.avatar>

        <.chat_section>
          <div>Yeah, I did! The components are so easy to integrate with Phoenix LiveView.</div>
          <:status time="22:11" deliver="Delivered" />
        </.chat_section>
      </.chat>

      <.chat variant="gradient" color="misc">
        <.avatar size="medium" rounded="full" border="small" color="silver">MA</.avatar>

        <.chat_section>
          <div>I agree. I used the button component in my project, and it works perfectly with the design!</div>
          <:status time="22:12" deliver="Delivered" />
        </.chat_section>
      </.chat>

      <.chat position="flipped" variant="gradient" color="misc">
        <.avatar size="medium" rounded="full" border="small" color="silver">ST</.avatar>

        <.chat_section>
          <div>Exactly. The fact that you can adjust the size and even add icons made my layout so much cleaner!</div>
          <:status time="22:13" deliver="Delivered" />
        </.chat_section>
      </.chat>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
