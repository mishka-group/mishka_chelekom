defmodule DevelopmentWeb.Showcase.Examples.Footer do
  @moduledoc """
  Docs examples for the `footer` component, taken from the Mishka source docs
  (`mishka/.../docs/footer_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  Notes on omissions from the source doc:
    * The overview example uses a `<.text_field>`, `<.button>`, and inline brand SVGs; skipped in
      favor of the focused prop sections below.
    * `~p"..."` route helpers / `<.image>` asset paths are replaced with `href="#"` links so the
      module stays self-contained and compilable.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "variants", title: "Variants"},
      %{id: "colors", title: "Colors"},
      %{id: "rounded", title: "Rounded"},
      %{id: "padding", title: "Padding"},
      %{id: "text_position", title: "Text position"},
      %{id: "font_weight", title: "Font weight"},
      %{id: "sections", title: "Footer sections"}
    ]
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.footer id="ex-footer-default" text_position="center" variant="default" color="natural">
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer id="ex-footer-outline" text_position="center" variant="outline" color="misc">
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer id="ex-footer-shadow" text_position="center" variant="shadow" color="silver">
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer id="ex-footer-bordered" text_position="center" variant="bordered" color="primary">
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer
        id="ex-footer-transparent"
        text_position="center"
        variant="transparent"
        color="secondary"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer id="ex-footer-gradient" text_position="center" variant="gradient" color="danger">
        © Mishka Chelekom - All Rights Reserved
      </.footer>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.footer
        :for={c <- ~w(natural primary secondary success warning danger info)}
        id={"ex-footer-color-#{c}"}
        text_position="center"
        variant="default"
        color={c}
      >
        © Mishka Chelekom - {String.capitalize(c)}
      </.footer>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.footer
        id="ex-footer-rounded-1"
        text_position="center"
        rounded="extra_small"
        color="silver"
        variant="default"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer
        id="ex-footer-rounded-2"
        text_position="center"
        rounded="extra_large"
        color="info"
        variant="default"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.footer
        id="ex-footer-padding-1"
        text_position="center"
        padding="extra_small"
        color="silver"
        variant="default"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer
        id="ex-footer-padding-2"
        text_position="center"
        padding="extra_large"
        color="info"
        variant="default"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
    </div>
    """
  end

  def example(%{section: "text_position"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.footer id="ex-footer-pos-center" text_position="center" variant="default" color="silver">
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer
        id="ex-footer-pos-left"
        text_position="left"
        padding="small"
        variant="default"
        color="danger"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer
        id="ex-footer-pos-right"
        text_position="right"
        padding="small"
        variant="default"
        color="info"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
    </div>
    """
  end

  def example(%{section: "font_weight"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <.footer
        id="ex-footer-fw-light"
        text_position="center"
        font_weight="font-light"
        color="silver"
        variant="default"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer
        id="ex-footer-fw-medium"
        text_position="center"
        font_weight="font-medium"
        color="danger"
        variant="default"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
      <.footer
        id="ex-footer-fw-bold"
        text_position="center"
        font_weight="font-bold"
        color="info"
        variant="default"
      >
        © Mishka Chelekom - All Rights Reserved
      </.footer>
    </div>
    """
  end

  def example(%{section: "sections"} = assigns) do
    ~H"""
    <.footer
      id="ex-footer-sections"
      color="secondary"
      padding="small"
      space="medium"
      variant="default"
    >
      <.footer_section class="border-b border-[#E5E7EB]" padding="small">
        <h4 class="font-bold text-lg">Mishka Chelekom</h4>
      </.footer_section>
      <.footer_section class="grid grid-cols-2 gap-2" padding="large">
        <ul class="space-y-4">
          <li><.link class="hover:text-teal-500" href="#">Mishka</.link></li>
          <li><.link class="hover:text-teal-500" href="#">Chelekom</.link></li>
          <li><.link class="hover:text-teal-500" href="#">Blog</.link></li>
        </ul>
        <p class="text-sm">
          The Mishka Chelekom UI kit is a powerful resource for building modern, interactive
          applications with Phoenix LiveView.
        </p>
      </.footer_section>
      <.footer_section text_position="center" class="border-t" padding="small">
        © All rights reserved.
      </.footer_section>
    </.footer>
    """
  end

  def example(assigns), do: ~H""
end
