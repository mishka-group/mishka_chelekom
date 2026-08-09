defmodule DevelopmentWeb.Showcase.HeadlessDaisyUIExamples do
  @moduledoc """
  The same headless components as `HeadlessBaseUIExamples`, wearing the daisyUI skin.

  The point of these examples is what is *missing* from them: no `trigger_class`, no `popup_class`,
  no utility soup. `mix mishka.ui.gen.headless <name> --skin daisyui` installs a stylesheet that
  paints the `chelekom-<name>__<part>` classes and `data-*` state the component already emits, so
  the markup here is the component's plain API and nothing else. Behavior, ARIA and keyboard
  handling are byte-identical to the Base UI gallery — only the paint differs.
  """
  use Phoenix.Component

  alias DevelopmentWeb.Showcase.ExampleSource

  import DevelopmentWeb.Components.Headless.Accordion
  import DevelopmentWeb.Components.Headless.Select

  @faq [
    {"What is a skin?",
     "A stylesheet that paints the classes and data-attributes the headless component already emits. It never touches markup, ARIA or behavior."},
    {"Does it change the component?",
     "No. The same generated module renders both galleries — only the stylesheet differs, so keyboard navigation and screen-reader semantics are identical."},
    {"Can I still use utility classes?",
     "Yes. Every per-part class attribute still applies on top, so you can override any part the skin paints."}
  ]

  @sections %{
    "accordion" => [
      {"accordion-hero", "Hero",
       "A single-open FAQ accordion painted by the daisyUI skin — same component as the Base UI gallery, but the markup carries no styling classes at all."},
      {"accordion-multiple", "Multiple",
       "Several panels open at once, with the skin's height transition and daisyUI's rotating arrow."}
    ],
    "select" => [
      {"select-hero", "Hero",
       "The trigger is painted as a daisyUI select and the listbox as a daisyUI menu; the arrow, radii and colors come from the active daisyUI theme."},
      {"select-grouped", "Grouped",
       "Options split into labelled groups, each label painted as a daisyUI menu title."},
      {"select-multiple", "Multiple",
       "A multi-select that stays open, with the daisyUI menu-active treatment on every chosen row."},
      {"select-form", "In a form",
       "The select inside a real form next to a daisyUI button — submitting flashes the value the hidden input carried."}
    ]
  }

  @spec has?(String.t()) :: boolean()
  def has?(component), do: Map.has_key?(@sections, component)

  @spec sections(String.t()) :: [{String.t(), String.t(), String.t()}]
  def sections(component), do: Map.get(@sections, component, [])

  @spec components() :: [String.t()]
  def components, do: @sections |> Map.keys() |> Enum.sort()

  @spec source(String.t()) :: String.t() | nil
  def source(id), do: ExampleSource.code(__MODULE__, id)

  attr :section, :string, required: true

  @spec example(map()) :: Phoenix.LiveView.Rendered.t()
  def example(%{section: "accordion-hero"} = assigns) do
    assigns = assign(assigns, :faq, @faq)

    ~H"""
    <.accordion id="daisyui-accordion-hero" collapsible heading_level={3} class="max-w-80">
      <:item :for={{question, answer} <- @faq} title={question}>
        {answer}
      </:item>
    </.accordion>
    """
  end

  def example(%{section: "accordion-multiple"} = assigns) do
    assigns = assign(assigns, :faq, @faq)

    ~H"""
    <.accordion
      id="daisyui-accordion-multiple"
      multiple
      collapsible
      heading_level={3}
      class="max-w-80"
    >
      <:item :for={{question, answer} <- @faq} title={question}>
        {answer}
      </:item>
    </.accordion>
    """
  end

  def example(%{section: "select-hero"} = assigns) do
    ~H"""
    <.select id="daisyui-select-hero" label="Apple" placeholder="Select apple" value="fuji">
      <:option value="gala">Gala</:option>
      <:option value="fuji">Fuji</:option>
      <:option value="honeycrisp">Honeycrisp</:option>
      <:option value="granny-smith">Granny Smith</:option>
      <:option value="pink-lady">Pink Lady</:option>
    </.select>
    """
  end

  def example(%{section: "select-grouped"} = assigns) do
    ~H"""
    <.select id="daisyui-select-grouped" label="Produce" placeholder="Select produce">
      <:option value="gala" group="Apples">Gala</:option>
      <:option value="fuji" group="Apples">Fuji</:option>
      <:option value="honeycrisp" group="Apples">Honeycrisp</:option>
      <:option value="bartlett" group="Pears">Bartlett</:option>
      <:option value="bosc" group="Pears">Bosc</:option>
      <:option value="comice" group="Pears" disabled>Comice (out of stock)</:option>
    </.select>
    """
  end

  def example(%{section: "select-multiple"} = assigns) do
    ~H"""
    <.select
      id="daisyui-select-multiple"
      label="Languages"
      placeholder="Select languages"
      multiple
      value={["javascript", "typescript"]}
    >
      <:option value="javascript">JavaScript</:option>
      <:option value="typescript">TypeScript</:option>
      <:option value="elixir">Elixir</:option>
      <:option value="rust">Rust</:option>
      <:option value="go">Go</:option>
    </.select>
    """
  end

  def example(%{section: "select-form"} = assigns) do
    ~H"""
    <form phx-submit="daisyui_select_submit" class="flex items-end gap-3">
      <.select
        id="daisyui-select-form"
        name="apple"
        label="Apple"
        placeholder="Select apple"
        value="gala"
        required
      >
        <:option value="gala">Gala</:option>
        <:option value="fuji">Fuji</:option>
        <:option value="honeycrisp">Honeycrisp</:option>
      </.select>
      <button type="submit" class="d-btn d-btn-primary">Save</button>
    </form>
    """
  end
end
