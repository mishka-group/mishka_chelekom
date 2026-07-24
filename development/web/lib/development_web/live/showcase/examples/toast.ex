defmodule DevelopmentWeb.Showcase.Examples.Toast do
  @moduledoc """
  Docs examples for the `toast` component, taken from the Mishka source docs
  (`mishka/.../docs/toast_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The doc gates every toast behind a `phx-click`/socket `@toast_pos` trigger and renders them
  `fixed` to a screen corner. For an inline, self-contained showcase the toasts are rendered
  directly with `fixed={false}` so they appear in the example body instead of being pinned to the
  viewport.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "variants", title: "Variants"},
      %{id: "colors", title: "Colors"},
      %{id: "rounded", title: "Rounded"},
      %{id: "padding", title: "Padding"},
      %{id: "border", title: "Border"},
      %{id: "space", title: "Space"},
      %{id: "group", title: "Toast group"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.toast
        :for={v <- ~w(default outline shadow bordered gradient)}
        id={"ex-toast-variant-#{v}"}
        variant={v}
        color="primary"
        fixed={false}
      >
        {String.capitalize(v)} variant
      </.toast>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.toast
        :for={c <- ~w(natural primary secondary success warning danger info silver misc dawn)}
        id={"ex-toast-color-#{c}"}
        variant="default"
        color={c}
        fixed={false}
      >
        {String.capitalize(c)} toast
      </.toast>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.toast
        :for={r <- ~w(extra_small small medium large extra_large)}
        id={"ex-toast-rounded-#{r}"}
        rounded={r}
        color="misc"
        variant="default"
        fixed={false}
      >
        Rounded {r}
      </.toast>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.toast
        :for={p <- ~w(extra_small small medium large extra_large)}
        id={"ex-toast-padding-#{p}"}
        padding={p}
        color="primary"
        variant="default"
        fixed={false}
      >
        Padding {p}
      </.toast>
    </div>
    """
  end

  def example(%{section: "border"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.toast
        :for={b <- ~w(extra_small small medium large extra_large)}
        id={"ex-toast-border-#{b}"}
        color="silver"
        variant="bordered"
        border={b}
        fixed={false}
      >
        Border {b}
      </.toast>
    </div>
    """
  end

  def example(%{section: "space"} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <.toast
        :for={s <- ~w(extra_small small medium large extra_large)}
        id={"ex-toast-space-#{s}"}
        space={s}
        color="dawn"
        variant="default"
        fixed={false}
      >
        <div>Space {s}</div>
        <div>Second line</div>
      </.toast>
    </div>
    """
  end

  def example(%{section: "group"} = assigns) do
    ~H"""
    <.toast_group id="ex-toast-group-1" space="medium">
      <.toast
        id="ex-toast-group-item-1"
        color="warning"
        variant="default"
        content_border="small"
        border_position="end"
        fixed={false}
      >
        <div>First message inside the toast group.</div>
      </.toast>
      <.toast
        id="ex-toast-group-item-2"
        color="success"
        variant="default"
        content_border="small"
        border_position="end"
        fixed={false}
      >
        <div>Second message inside the toast group.</div>
      </.toast>
      <.toast
        id="ex-toast-group-item-3"
        color="info"
        variant="default"
        content_border="small"
        border_position="end"
        fixed={false}
      >
        <div>Third message inside the toast group.</div>
      </.toast>
    </.toast_group>
    """
  end

  def example(assigns), do: ~H""
end
