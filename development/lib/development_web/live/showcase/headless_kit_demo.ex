defmodule DevelopmentWeb.Showcase.HeadlessKitDemo do
  @moduledoc """
  Renders the live RESULT of skinning a headless component with a real `MishkaChelekom.Kit` — the
  `part` rules generate a styled wrapper (e.g. `my_accordion`) that delegates to the untouched
  headless component. Powers the "Customize it" section of the headless showcase, mirroring the
  styled `DevelopmentWeb.Showcase.KitDemo`.
  """
  use DevelopmentWeb, :html
  import DevelopmentWeb.Kit, only: [my_accordion: 1, my_collapsible: 1]

  @available ~w(accordion collapsible)
  def available?(name), do: name in @available

  # The REAL `customize` blocks that produce the live results, lifted verbatim from `kit.ex` so the
  # snippet and the rendered skin can never drift apart.
  @kit_path Path.expand("../../kit.ex", __DIR__)
  @external_resource @kit_path
  @kit_source File.read!(@kit_path)

  @accordion_code (case Regex.run(~r/  customize :my_accordion do.*?\n  end/s, @kit_source) do
                     [block] -> block |> String.replace(~r/^  /m, "") |> String.trim_trailing()
                     _ -> nil
                   end)

  @collapsible_code (case Regex.run(~r/  customize :my_collapsible do.*?\n  end/s, @kit_source) do
                       [block] -> block |> String.replace(~r/^  /m, "") |> String.trim_trailing()
                       _ -> nil
                     end)

  @doc "The actual Kit `customize` source for a skinned component (nil → fall back to the template)."
  def code("accordion"), do: @accordion_code
  def code("collapsible"), do: @collapsible_code
  def code(_), do: nil

  attr :component, :string, required: true

  def demo(%{component: "accordion"} = assigns) do
    ~H"""
    <.my_accordion id="hl-accordion-skin" class="w-full max-w-md">
      <:item title="What did the Kit do?" open>
        Generated <code>my_accordion/1</code> — a thin wrapper of the real headless accordion with the
        per-part classes baked in. The page just calls it; no inline styling here.
      </:item>
      <:item title="Was the component changed?">
        No — the wrapper delegates to it; the component's file is never touched.
      </:item>
      <:item title="Where do the classes live?">
        In <code>kit.ex</code>, written whole — Tailwind scans them straight from the file (no safelist).
      </:item>
    </.my_accordion>
    """
  end

  def demo(%{component: "collapsible"} = assigns) do
    ~H"""
    <.my_collapsible id="hl-collapsible-skin" open class="w-full max-w-md">
      <:trigger>What did the Kit do?</:trigger>
      <p>
        Generated <code>my_collapsible/1</code> — a thin wrapper of the real headless collapsible with
        the per-part amber classes baked in. The component's file is never touched; click to collapse.
      </p>
    </.my_collapsible>
    """
  end

  def demo(assigns), do: ~H""
end
