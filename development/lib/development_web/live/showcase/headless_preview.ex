defmodule DevelopmentWeb.Showcase.HeadlessPreview do
  @moduledoc """
  Hand-written/AI-authored example invocations for each headless component. Headless
  components ship no styling, so the showcase adds utility classes purely for legibility.
  """
  use Phoenix.Component

  import DevelopmentWeb.Components.Headless.Accordion
  import DevelopmentWeb.Components.Headless.AlertDialog
  import DevelopmentWeb.Components.Headless.Autocomplete
  import DevelopmentWeb.Components.Headless.Avatar
  import DevelopmentWeb.Components.Headless.Checkbox
  import DevelopmentWeb.Components.Headless.CheckboxGroup
  import DevelopmentWeb.Components.Headless.CloseButton
  import DevelopmentWeb.Components.Headless.Collapsible
  import DevelopmentWeb.Components.Headless.Combobox
  import DevelopmentWeb.Components.Headless.ContextMenu
  import DevelopmentWeb.Components.Headless.Dialog
  import DevelopmentWeb.Components.Headless.EmptyState
  import DevelopmentWeb.Components.Headless.Field
  import DevelopmentWeb.Components.Headless.Fieldset
  import DevelopmentWeb.Components.Headless.Menu
  import DevelopmentWeb.Components.Headless.Menubar
  import DevelopmentWeb.Components.Headless.Meter
  import DevelopmentWeb.Components.Headless.NavigationMenu
  import DevelopmentWeb.Components.Headless.NumberField
  import DevelopmentWeb.Components.Headless.Popover
  import DevelopmentWeb.Components.Headless.PreviewCard
  import DevelopmentWeb.Components.Headless.Progress
  import DevelopmentWeb.Components.Headless.RadioGroup
  import DevelopmentWeb.Components.Headless.ScrollArea
  import DevelopmentWeb.Components.Headless.Select
  import DevelopmentWeb.Components.Headless.Separator
  import DevelopmentWeb.Components.Headless.Slider
  import DevelopmentWeb.Components.Headless.Switch
  import DevelopmentWeb.Components.Headless.Tabs
  import DevelopmentWeb.Components.Headless.Toast
  import DevelopmentWeb.Components.Headless.Toggle
  import DevelopmentWeb.Components.Headless.ToggleGroup
  import DevelopmentWeb.Components.Headless.Toolbar
  import DevelopmentWeb.Components.Headless.Tooltip
  import DevelopmentWeb.Components.Headless.Tree
  import DevelopmentWeb.Components.Headless.Drawer
  import DevelopmentWeb.Components.Headless.Radio
  import DevelopmentWeb.Components.Headless.OtpField
  import DevelopmentWeb.Showcase.UI, only: [code_block: 1]

  @btn "rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm"

  # This file is its own source for the copy-paste snippets: we lift the HEEx out of each `show/1`
  # clause (and each toast `<details>` example) so the shown code can never drift from what renders.
  @preview_path Path.expand("headless_preview.ex", __DIR__)
  @external_resource @preview_path
  @preview_source File.read!(@preview_path)

  # title => raw toast example block (dedent/expand applied at runtime in example_code/1)
  @toast_codes Regex.scan(
                 ~r/<summary[^>]*>([^<]+)<\/summary>.*?(<\.toast.*?<\/\.toast>)/s,
                 @preview_source
               )
               |> Map.new(fn [_, title, code] -> {String.trim(title), code} end)

  @doc "The HEEx source of a component's live preview, ready to copy-paste."
  def source(name) do
    case Regex.run(
           ~r/def show\(%\{component: "#{Regex.escape(name)}"\} = assigns\) do\s*~H"""\n(.*?)\n\s*"""/s,
           @preview_source
         ) do
      [_, body] -> body |> dedent() |> expand_toast_class()
      _ -> nil
    end
  end

  defp example_code(title),
    do: @toast_codes |> Map.get(title, "") |> dedent() |> expand_toast_class()

  # Inline the showcase's `toast_class/1` helper back to literal classes so copied code is self-contained.
  defp expand_toast_class(code) do
    code
    |> String.replace(~s|{toast_class(:bottom)}|, ~s|"#{Enum.join(toast_class(:bottom), " ")}"|)
    |> String.replace(~s|{toast_class(:top)}|, ~s|"#{Enum.join(toast_class(:top), " ")}"|)
  end

  # Strip the first line's indent and the common indent of the rest, so extracted blocks read cleanly.
  defp dedent(code) do
    case code |> String.trim_trailing() |> String.split("\n") do
      [single] ->
        String.trim(single)

      [first | rest] ->
        min =
          rest
          |> Enum.reject(&(String.trim(&1) == ""))
          |> Enum.map(&(String.length(&1) - String.length(String.trim_leading(&1))))
          |> Enum.min(fn -> 0 end)

        [String.trim_leading(first) | Enum.map(rest, &String.slice(&1, min..-1//1))]
        |> Enum.join("\n")
    end
  end

  # Base-UI-style checkbox: a square box that fills with a ✓ when checked and a – when indeterminate
  # (driven by the indicator's own data-checked / data-indeterminate state attributes).
  defp checkbox_class do
    "inline-flex cursor-pointer items-center gap-2 [&[data-disabled]]:cursor-not-allowed [&[data-disabled]]:opacity-50 " <>
      "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-[var(--c-base-300)] [&_[data-part=indicator]]:bg-[var(--c-base-100)] [&_[data-part=indicator]]:text-xs [&_[data-part=indicator]]:leading-none [&_[data-part=indicator]]:text-[var(--c-base-100)] " <>
      "[&_[data-part=indicator][data-checked]]:border-[var(--c-base-content)] [&_[data-part=indicator][data-checked]]:bg-[var(--c-base-content)] [&_[data-part=indicator][data-checked]]:after:content-['✓'] " <>
      "[&_[data-part=indicator][data-indeterminate]]:border-[var(--c-base-content)] [&_[data-part=indicator][data-indeterminate]]:bg-[var(--c-base-content)] [&_[data-part=indicator][data-indeterminate]]:after:content-['–'] " <>
      "[&_[data-part=label]]:text-sm"
  end

  # The group: a bordered card; each item is a Base-UI checkbox row (box ✓ / dash via the indicator),
  # with the select_all parent set apart by a divider.
  defp checkbox_group_class do
    "flex w-64 flex-col gap-0.5 rounded-md border border-[var(--c-base-300)] p-3 " <>
      "[&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-semibold " <>
      "[&_[data-part=item]]:flex [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded [&_[data-part=item]]:px-2 [&_[data-part=item]]:py-1 [&_[data-part=item]]:text-sm [&_[data-part=item]:hover]:bg-[var(--c-base-200)] [&_[data-part=item][data-disabled]]:cursor-not-allowed [&_[data-part=item][data-disabled]]:opacity-50 " <>
      "[&_[data-part=item][data-parent]]:mb-1 [&_[data-part=item][data-parent]]:border-b [&_[data-part=item][data-parent]]:border-[var(--c-base-300)] [&_[data-part=item][data-parent]]:pb-1.5 [&_[data-part=item][data-parent]]:font-medium " <>
      "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:shrink-0 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-[var(--c-base-300)] [&_[data-part=indicator]]:bg-[var(--c-base-100)] [&_[data-part=indicator]]:text-xs [&_[data-part=indicator]]:leading-none [&_[data-part=indicator]]:text-[var(--c-base-100)] " <>
      "[&_[data-part=indicator][data-checked]]:border-[var(--c-base-content)] [&_[data-part=indicator][data-checked]]:bg-[var(--c-base-content)] [&_[data-part=indicator][data-checked]]:after:content-['✓'] " <>
      "[&_[data-part=indicator][data-indeterminate]]:border-[var(--c-base-content)] [&_[data-part=indicator][data-indeterminate]]:bg-[var(--c-base-content)] [&_[data-part=indicator][data-indeterminate]]:after:content-['–']"
  end

  # Combobox: a bordered control box holding (multiple) chips inline + a borderless growing input +
  # clear/trigger; a floating listbox with a ✓ on the selected option, group labels, empty/create rows.
  defp combobox_class do
    [
      "relative w-64",
      "[&_[data-part=control]]:flex [&_[data-part=control]]:flex-wrap [&_[data-part=control]]:items-center [&_[data-part=control]]:gap-1 [&_[data-part=control]]:rounded-md [&_[data-part=control]]:border [&_[data-part=control]]:border-[var(--c-base-300)] [&_[data-part=control]]:bg-[var(--c-base-100)] [&_[data-part=control]]:px-2 [&_[data-part=control]]:py-1 [&_[data-part=control]]:focus-within:ring-2 [&_[data-part=control]]:focus-within:ring-[var(--c-primary)]/30",
      "[&_[data-part=chips]]:contents [&_[data-part=chip]]:inline-flex [&_[data-part=chip]]:items-center [&_[data-part=chip]]:gap-1 [&_[data-part=chip]]:rounded [&_[data-part=chip]]:bg-[var(--c-base-200)] [&_[data-part=chip]]:px-1.5 [&_[data-part=chip]]:py-0.5 [&_[data-part=chip]]:text-sm [&_[data-part=chip-remove]]:text-[var(--c-base-content)]/50 [&_[data-part=chip-remove]]:hover:text-[var(--c-base-content)]",
      "[&_[data-part=input]]:min-w-16 [&_[data-part=input]]:flex-1 [&_[data-part=input]]:border-0 [&_[data-part=input]]:bg-transparent [&_[data-part=input]]:px-1 [&_[data-part=input]]:py-0.5 [&_[data-part=input]]:text-sm [&_[data-part=input]]:outline-none",
      "[&_[data-part=clear]]:shrink-0 [&_[data-part=clear]]:px-1 [&_[data-part=clear]]:text-[var(--c-base-content)]/40 [&_[data-part=clear]]:hover:text-[var(--c-base-content)] [&_[data-part=clear][data-hidden]]:hidden",
      "[&_[data-part=trigger]]:shrink-0 [&_[data-part=trigger]]:px-1 [&_[data-part=trigger]]:text-[var(--c-base-content)]/40 [&_[data-part=trigger]]:hover:text-[var(--c-base-content)]",
      "[&_[data-part=popup]]:absolute [&_[data-part=popup]]:left-0 [&_[data-part=popup]]:right-0 [&_[data-part=popup]]:top-full [&_[data-part=popup]]:z-10 [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:max-h-56 [&_[data-part=popup]]:overflow-auto [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-[var(--c-base-300)] [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup][data-closed]]:hidden",
      "[&_[data-part=group-label]]:block [&_[data-part=group-label]]:px-3 [&_[data-part=group-label]]:pb-1 [&_[data-part=group-label]]:pt-2 [&_[data-part=group-label]]:text-xs [&_[data-part=group-label]]:font-medium [&_[data-part=group-label]]:uppercase [&_[data-part=group-label]]:tracking-wide [&_[data-part=group-label]]:text-[var(--c-base-content)]/40",
      "[&_[data-part=item]]:flex [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item][data-highlighted]]:bg-[var(--c-base-200)] [&_[data-part=item][data-disabled]]:cursor-not-allowed [&_[data-part=item][data-disabled]]:opacity-40",
      "[&_[data-part=indicator]]:w-4 [&_[data-part=indicator]]:shrink-0 [&_[data-part=indicator]]:text-xs [&_[data-part=item][data-selected]_[data-part=indicator]]:after:content-['✓']",
      "[&_[data-part=empty]]:px-3 [&_[data-part=empty]]:py-2 [&_[data-part=empty]]:text-sm [&_[data-part=empty]]:text-[var(--c-base-content)]/50",
      "[&_[data-part=create]]:cursor-pointer [&_[data-part=create]]:rounded [&_[data-part=create]]:px-3 [&_[data-part=create]]:py-1.5 [&_[data-part=create]]:text-sm [&_[data-part=create]]:text-[var(--c-primary)] [&_[data-part=create]]:hover:bg-[var(--c-base-200)] [&_[data-part=create][data-hidden]]:hidden"
    ]
  end

  def show(%{component: "drawer"} = assigns) do
    ~H"""
    <.drawer
      id={@id}
      side="right"
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger][data-popup-open]]:bg-[var(--c-base-200)] [&_[data-part=backdrop]]:bg-black/40 [&_[data-part=popup]]:flex [&_[data-part=popup]]:w-80 [&_[data-part=popup]]:max-w-[85vw] [&_[data-part=popup]]:flex-col [&_[data-part=popup]]:gap-3 [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl [&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-[var(--c-base-content)]/70 [&_[data-part=footer]]:mt-auto [&_[data-part=footer]]:flex [&_[data-part=footer]]:justify-end [&_[data-part=footer]]:gap-2"
    >
      <:trigger>Open drawer</:trigger>
      <:title>Filters</:title>
      <:description>
        Slides from the right. Click outside, press Escape, or hit Cancel — or drag the panel rightward to swipe it away.
      </:description>
      <div class="mt-1 space-y-2 text-sm">
        <label class="flex items-center gap-2">
          <input type="checkbox" class="size-4" /> In stock
        </label>
        <label class="flex items-center gap-2">
          <input type="checkbox" class="size-4" /> On sale
        </label>
        <label class="flex items-center gap-2">
          <input type="checkbox" class="size-4" /> Free shipping
        </label>
      </div>
      <:close>
        <button class="rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm" data-close>
          Cancel
        </button>
        <button
          class="rounded-md bg-[var(--c-primary)] px-3 py-1.5 text-sm font-medium text-primary-content"
          data-close
        >
          Apply
        </button>
      </:close>
    </.drawer>
    """
  end

  def show(%{component: "radio"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.radio
        :for={
          {label, v, dis} <- [
            {"Email", "email", false},
            {"SMS", "sms", false},
            {"Push (disabled)", "push", true}
          ]
        }
        id={"#{@id}-#{v}"}
        name="notify"
        value={v}
        checked={v == "email"}
        disabled={dis}
        class={radio_class()}
      >
        {label}
      </.radio>
    </div>
    """
  end

  def show(%{component: "otp_field"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Numeric · 6 digits · auto-advance · paste distributes · roving tabindex
        </p>
        <.otp_field id={@id} name="code" length={6} class={otp_field_class()} />
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Alphanumeric · uppercase · grouped 3–3 · green when complete
        </p>
        <.otp_field
          id={"#{@id}-an"}
          length={6}
          validation_type="alphanumeric"
          transform="uppercase"
          group={3}
          separator="–"
          class={otp_field_class()}
        />
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Masked · 4 digits (-webkit-text-security)
        </p>
        <.otp_field id={"#{@id}-pin"} length={4} mask class={otp_field_class()} />
      </div>
    </div>
    """
  end

  def show(%{component: "accordion"} = assigns) do
    ~H"""
    <.accordion
      id={@id}
      class={
        [
          "w-80 divide-y divide-[var(--c-base-300)] rounded-md border border-[var(--c-base-300)]",
          # trigger: full-width header with a chevron that flips via data-panel-open
          "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-3 [&_[data-part=trigger]]:p-3 [&_[data-part=trigger]]:text-left [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:outline-none focus-visible:[&_[data-part=trigger]]:bg-[var(--c-base-200)]",
          "[&_[data-part=trigger][data-disabled]]:cursor-not-allowed [&_[data-part=trigger][data-disabled]]:opacity-40",
          "[&_[data-part=trigger]]:after:content-['▾'] [&_[data-part=trigger]]:after:text-[var(--c-base-content)]/40 [&_[data-part=trigger]]:after:transition-transform [&_[data-part=trigger][data-panel-open]]:after:rotate-180",
          # panel is a PURE height-animated wrapper — NO padding on it (padding goes on the inner
          # content), else box-border + height:0 can't collapse past the padding and the transition breaks
          "[&_[data-part=panel]]:box-border [&_[data-part=panel]]:h-[var(--accordion-panel-height)] [&_[data-part=panel]]:overflow-hidden [&_[data-part=panel]]:transition-[height] [&_[data-part=panel]]:duration-200 [&_[data-part=panel]]:ease-out",
          "[&_[data-part=panel][data-starting-style]]:h-0 [&_[data-part=panel][data-ending-style]]:h-0"
        ]
      }
    >
      <:item title="What is a headless component?" open>
        <div class="px-3 pb-3 text-sm text-[var(--c-base-content)]/70">
          It ships behavior, ARIA wiring, and keyboard support — but no styling. You bring the classes.
        </div>
      </:item>
      <:item title="How does keyboard navigation work?">
        <div class="px-3 pb-3 text-sm text-[var(--c-base-content)]/70">
          Arrow keys move focus between headers, Home/End jump to the ends, Enter/Space toggles.
        </div>
      </:item>
      <:item title="This header is disabled" disabled>
        <div class="px-3 pb-3 text-sm text-[var(--c-base-content)]/70">
          Disabled headers are skipped by arrow-key navigation and can't be toggled.
        </div>
      </:item>
      <:item title="Can panels animate?">
        <div class="px-3 pb-3 text-sm text-[var(--c-base-content)]/70">
          Yes — the panel exposes <code>--accordion-panel-height</code>
          plus <code>data-starting-style</code>/<code>data-ending-style</code>
          so your CSS transitions height.
        </div>
      </:item>
    </.accordion>
    """
  end

  def show(%{component: "alert_dialog"} = assigns) do
    assigns = assign(assigns, btn: @btn)

    ~H"""
    <.alert_dialog
      id={@id}
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=backdrop]]:bg-black/40 [&_[data-part=popup]]:w-80 [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl [&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold [&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-[var(--c-base-content)]/70 [&_[data-part=actions]]:mt-4 [&_[data-part=actions]]:flex [&_[data-part=actions]]:justify-end [&_[data-part=actions]]:gap-2"
    >
      <:trigger>Delete account</:trigger>
      <:title>Delete account?</:title>
      <:description>This permanently removes your account and cannot be undone.</:description>
      <:actions>
        <button class={@btn} data-close>Cancel</button>
        <button class={[@btn, "bg-[var(--c-error)] text-error-content"]} data-close>Delete</button>
      </:actions>
    </.alert_dialog>
    """
  end

  def show(%{component: "autocomplete"} = assigns) do
    ~H"""
    <.autocomplete
      id={@id}
      name="food"
      placeholder="Search food…"
      auto_highlight
      clear
      class={[
        "relative w-64",
        "[&_[data-part=input]]:w-full [&_[data-part=input]]:rounded-md [&_[data-part=input]]:border [&_[data-part=input]]:border-[var(--c-base-300)] [&_[data-part=input]]:px-3 [&_[data-part=input]]:py-1.5 [&_[data-part=input]]:pr-8",
        "[&_[data-part=clear]]:absolute [&_[data-part=clear]]:right-2 [&_[data-part=clear]]:top-1.5 [&_[data-part=clear]]:text-[var(--c-base-content)]/40 [&_[data-part=clear]]:hover:text-[var(--c-base-content)] [&_[data-part=clear][data-hidden]]:hidden",
        "[&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:max-h-56 [&_[data-part=popup]]:w-64 [&_[data-part=popup]]:overflow-auto [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-[var(--c-base-300)] [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg",
        "[&_[data-part=group-label]]:block [&_[data-part=group-label]]:px-3 [&_[data-part=group-label]]:pb-1 [&_[data-part=group-label]]:pt-2 [&_[data-part=group-label]]:text-xs [&_[data-part=group-label]]:font-medium [&_[data-part=group-label]]:uppercase [&_[data-part=group-label]]:tracking-wide [&_[data-part=group-label]]:text-[var(--c-base-content)]/40",
        "[&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item][data-highlighted]]:bg-[var(--c-base-200)] [&_[data-part=item][aria-selected=true]]:font-semibold",
        "[&_[data-part=empty]]:px-3 [&_[data-part=empty]]:py-2 [&_[data-part=empty]]:text-sm [&_[data-part=empty]]:text-[var(--c-base-content)]/50"
      ]}
    >
      <:option value="Apple" group="Fruit">Apple</:option>
      <:option value="Banana" group="Fruit">Banana</:option>
      <:option value="Cherry" group="Fruit">Cherry</:option>
      <:option value="Carrot" group="Vegetable">Carrot</:option>
      <:option value="Potato" group="Vegetable">Potato</:option>
      <:empty>No matches.</:empty>
    </.autocomplete>
    """
  end

  def show(%{component: "avatar"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-4">
      <div class="flex flex-col items-center gap-1">
        <.avatar
          id={@id}
          src="https://avatars.githubusercontent.com/u/8722951?v=4"
          alt="User avatar"
          class={avatar_class()}
        >
          MC
        </.avatar>
        <span class="text-[0.7rem] text-[var(--c-base-content)]/40">loaded</span>
      </div>
      <div class="flex flex-col items-center gap-1">
        <.avatar
          id={"#{@id}-broken"}
          src="https://example.invalid/missing.png"
          alt="Jane Doe"
          class={avatar_class()}
        >
          JD
        </.avatar>
        <span class="text-[0.7rem] text-[var(--c-base-content)]/40">broken → fallback</span>
      </div>
      <div class="flex flex-col items-center gap-1">
        <.avatar id={"#{@id}-initials"} class={avatar_class()}>AB</.avatar>
        <span class="text-[0.7rem] text-[var(--c-base-content)]/40">no image</span>
      </div>
    </div>
    """
  end

  def show(%{component: "empty_state"} = assigns) do
    ~H"""
    <.empty_state
      id={@id}
      title="No results found"
      description="Try adjusting your search or filters to find what you're looking for."
      class={empty_state_class()}
    >
      <:indicator>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
          />
        </svg>
      </:indicator>
      <:actions>
        <button
          type="button"
          class="rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm hover:bg-[var(--c-base-200)]"
        >
          Clear filters
        </button>
      </:actions>
    </.empty_state>
    """
  end

  def show(%{component: "close_button"} = assigns) do
    ~H"""
    <div class="flex items-center gap-4">
      <.close_button
        id={@id}
        label="Close"
        class="inline-flex size-8 items-center justify-center rounded-md text-[var(--c-base-content)]/60 hover:bg-[var(--c-base-200)] hover:text-[var(--c-base-content)] data-[disabled]:opacity-40"
      />
      <.close_button
        id={"#{@id}-lg"}
        label="Dismiss"
        class="inline-flex size-10 items-center justify-center rounded-full text-lg text-[var(--c-base-content)]/60 hover:bg-[var(--c-base-200)] hover:text-[var(--c-base-content)]"
      />
      <.close_button
        id={"#{@id}-disabled"}
        label="Close"
        disabled
        class="inline-flex size-8 items-center justify-center rounded-md text-[var(--c-base-content)]/60 data-[disabled]:cursor-not-allowed data-[disabled]:opacity-40"
      />
    </div>
    """
  end

  def show(%{component: "checkbox"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.checkbox id={@id} name="terms" value="accepted" checked class={checkbox_class()}>
        I agree to the terms and conditions
      </.checkbox>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Indeterminate · disabled
        </p>
        <div class="flex flex-col gap-2">
          <.checkbox id={"#{@id}-ind"} indeterminate class={checkbox_class()}>
            Indeterminate (click → checks)
          </.checkbox>
          <.checkbox id={"#{@id}-dis"} checked disabled class={checkbox_class()}>
            Disabled (checked)
          </.checkbox>
        </div>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Parent "select all" — tristate group
        </p>
        <div id={"#{@id}-grp"} phx-hook="CheckboxGroup" role="group" aria-label="Fruit">
          <.checkbox id={"#{@id}-all"} parent indeterminate class={checkbox_class()}>
            Apples
          </.checkbox>
          <div class="ml-6 mt-1 flex flex-col gap-1.5">
            <.checkbox id={"#{@id}-fuji"} checked class={checkbox_class()}>Fuji</.checkbox>
            <.checkbox id={"#{@id}-gala"} class={checkbox_class()}>Gala</.checkbox>
            <.checkbox id={"#{@id}-gs"} class={checkbox_class()}>Granny Smith</.checkbox>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def show(%{component: "checkbox_group"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.checkbox_group id={@id} name="toppings" class={checkbox_group_class()}>
        <:label>Pizza toppings</:label>
        <:select_all>All toppings</:select_all>
        <:item value="cheese" checked>Cheese</:item>
        <:item value="mushroom">Mushroom</:item>
        <:item value="pepperoni" disabled>Pepperoni (sold out)</:item>
      </.checkbox_group>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Nested parents — each reflects + toggles its whole subtree
        </p>
        <div
          id={"#{@id}-tree"}
          phx-hook="CheckboxGroup"
          role="group"
          aria-label="User permissions"
          class="flex w-72 flex-col gap-1.5 rounded-md border border-[var(--c-base-300)] p-3 [&_[data-part=children]]:ml-6 [&_[data-part=children]]:mt-1.5 [&_[data-part=children]]:flex [&_[data-part=children]]:flex-col [&_[data-part=children]]:gap-1.5"
        >
          <.checkbox id={"#{@id}-perms"} parent indeterminate class={checkbox_class()}>
            User Permissions
          </.checkbox>
          <div data-part="children">
            <.checkbox id={"#{@id}-view"} value="view" class={checkbox_class()}>
              View Dashboard
            </.checkbox>
            <.checkbox id={"#{@id}-reports"} value="reports" class={checkbox_class()}>
              Access Reports
            </.checkbox>
            <.checkbox id={"#{@id}-manage"} parent checked class={checkbox_class()}>
              Manage Users
            </.checkbox>
            <div data-part="children">
              <.checkbox id={"#{@id}-create"} value="create" checked class={checkbox_class()}>
                Create User
              </.checkbox>
              <.checkbox id={"#{@id}-edit"} value="edit" checked class={checkbox_class()}>
                Edit User
              </.checkbox>
              <.checkbox id={"#{@id}-delete"} value="delete" checked class={checkbox_class()}>
                Delete User
              </.checkbox>
              <.checkbox id={"#{@id}-assign"} value="assign" checked class={checkbox_class()}>
                Assign Roles
              </.checkbox>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def show(%{component: "collapsible"} = assigns) do
    ~H"""
    <.collapsible
      id={@id}
      open
      class={
        [
          "w-72",
          # trigger: full-width header with a chevron that flips via data-panel-open
          "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-3 [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-left [&_[data-part=trigger]]:font-medium",
          "[&_[data-part=trigger]]:after:content-['▾'] [&_[data-part=trigger]]:after:text-[var(--c-base-content)]/40 [&_[data-part=trigger]]:after:transition-transform [&_[data-part=trigger][data-panel-open]]:after:rotate-180",
          # panel is a PURE height-animated wrapper — padding/borders live on the inner card, else
          # box-border + height:0 can't collapse past the padding and the transition breaks
          "[&_[data-part=panel]]:box-border [&_[data-part=panel]]:h-[var(--accordion-panel-height)] [&_[data-part=panel]]:overflow-hidden [&_[data-part=panel]]:transition-[height] [&_[data-part=panel]]:duration-200 [&_[data-part=panel]]:ease-out",
          "[&_[data-part=panel][data-starting-style]]:h-0 [&_[data-part=panel][data-ending-style]]:h-0"
        ]
      }
    >
      <:trigger>Shipping details</:trigger>
      <div class="mt-2 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-3 text-sm">
        <p>Orders ship within 2 business days via standard carrier.</p>
        <p class="mt-2 text-[var(--c-base-content)]/60">
          Tracking is emailed once the label is created.
        </p>
      </div>
    </.collapsible>
    """
  end

  def show(%{component: "combobox"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Single · trigger · clear · disabled item · ✓ on selected
        </p>
        <.combobox
          id={@id}
          name="fruit"
          value="banana"
          placeholder="Search fruit…"
          trigger
          clear
          auto_highlight
          class={combobox_class()}
        >
          <:option value="apple">Apple</:option>
          <:option value="banana">Banana</:option>
          <:option value="cherry">Cherry</:option>
          <:option value="durian" disabled>Durian (out of stock)</:option>
          <:empty>No fruit found.</:empty>
        </.combobox>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Multiple · chips · grouped · creatable
        </p>
        <.combobox
          id={"#{@id}-multi"}
          name="picks"
          multiple
          value={["apple", "carrot"]}
          placeholder="Add items…"
          clear
          creatable
          on_create="combobox_create"
          class={combobox_class()}
        >
          <:option value="apple" group="Fruit">Apple</:option>
          <:option value="banana" group="Fruit">Banana</:option>
          <:option value="cherry" group="Fruit">Cherry</:option>
          <:option value="carrot" group="Vegetable">Carrot</:option>
          <:option value="potato" group="Vegetable">Potato</:option>
          <:empty>No matches.</:empty>
        </.combobox>
      </div>
    </div>
    """
  end

  def show(%{component: "context_menu"} = assigns) do
    ~H"""
    <.context_menu id={@id} class={context_menu_class()}>
      <:trigger>Right click here</:trigger>
      <:item>Add to Library</:item>
      <:item type="separator" />
      <:item>Play Next</:item>
      <:item>Play Last</:item>
      <:item type="separator" />
      <:item type="checkbox" checked>Favorite</:item>
      <:item type="link" href="#share">Share</:item>
      <:item type="separator" />
      <:item type="label">Quality</:item>
      <:item type="radio" name="quality" value="auto" checked>Auto</:item>
      <:item type="radio" name="quality" value="high">High</:item>
      <:item type="separator" />
      <:item disabled>Delete</:item>
      <:submenu label="Add to Playlist">
        <.context_menu_item>Jazz Classics</.context_menu_item>
        <.context_menu_item>Deep Focus</.context_menu_item>
        <.context_menu_item>Late Night</.context_menu_item>
      </:submenu>
    </.context_menu>
    """
  end

  def show(%{component: "dialog"} = assigns) do
    ~H"""
    <.dialog
      id={@id}
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger][data-popup-open]]:bg-[var(--c-base-200)] [&_[data-part=backdrop]]:bg-black/40 [&_[data-part=backdrop]]:transition-opacity [&_[data-part=backdrop]]:duration-200 [&_[data-part=backdrop][data-starting-style]]:opacity-0 [&_[data-part=popup]]:w-80 [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl [&_[data-part=popup]]:transition [&_[data-part=popup]]:duration-200 [&_[data-part=popup]]:ease-out [&_[data-part=popup][data-starting-style]]:scale-95 [&_[data-part=popup][data-starting-style]]:opacity-0 [&_[data-part=title]]:text-base [&_[data-part=title]]:font-semibold [&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-[var(--c-base-content)]/70 [&_[data-part=footer]]:mt-4 [&_[data-part=footer]]:flex [&_[data-part=footer]]:justify-end [&_[data-part=footer]]:gap-2"
    >
      <:trigger>Open dialog</:trigger>
      <:title>Confirm action</:title>
      <:description>Focus-trapped, scroll-locked, with a scale+fade enter animation.</:description>
      <p class="mt-3 text-sm">
        Tab cycles inside; Escape, the backdrop, or the close button dismiss it.
      </p>
      <:close>
        <button
          type="button"
          class="rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm"
          data-close
        >
          Cancel
        </button>
        <button
          type="button"
          class="rounded-md bg-[var(--c-base-content)] px-3 py-1.5 text-sm text-[var(--c-base-100)]"
          data-close
        >
          Confirm
        </button>
      </:close>
    </.dialog>
    """
  end

  def show(%{component: "field"} = assigns) do
    ~H"""
    <.field
      :let={f}
      id={@id}
      name="email"
      label="Email address"
      class={
        [
          "w-80",
          "[&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium",
          "[&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-xs [&_[data-part=description]]:text-[var(--c-base-content)]/60",
          "[&_[data-part=error]]:mt-1 [&_[data-part=error]]:text-xs [&_[data-part=error]]:text-[var(--c-error)]",
          # State hooks set by the Field engine — focus the input for a ring, type to
          # turn the label primary (data-filled). Invalid/error styling is shown live in
          # the form under "Examples" below (this preview is a clean, valid field).
          "[&[data-invalid]_input]:border-[var(--c-error)]",
          "[&[data-valid]_input]:border-[var(--c-success)]",
          "[&[data-focused]_input]:ring-2 [&[data-focused]_input]:ring-[var(--c-primary)]/30",
          "[&[data-filled]_[data-part=label]]:text-[var(--c-primary)]",
          "[&[data-disabled]]:opacity-50"
        ]
      }
    >
      <input
        id={f.id}
        type="email"
        name={f.name}
        placeholder="you@example.com"
        aria-describedby={f.describedby}
        aria-invalid={f.invalid && "true"}
        disabled={f.disabled}
        class="w-full rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm outline-none"
      />
      <:description>We'll only use this to send account notifications.</:description>
    </.field>
    """
  end

  def show(%{component: "fieldset"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <.fieldset id={@id} class={fieldset_demo_class()}>
        <:legend>Shipping address</:legend>
        <div class="space-y-3">
          <label class="block text-sm">
            <span class="mb-1 block text-[var(--c-base-content)]/70">Street</span>
            <input
              type="text"
              name="street"
              value="123 Main St"
              class="w-full rounded-md border border-[var(--c-base-300)] px-3 py-1.5"
            />
          </label>
          <label class="block text-sm">
            <span class="mb-1 block text-[var(--c-base-content)]/70">City</span>
            <input
              type="text"
              name="city"
              value="Springfield"
              class="w-full rounded-md border border-[var(--c-base-300)] px-3 py-1.5"
            />
          </label>
        </div>
      </.fieldset>

      <.fieldset id={"#{@id}-off"} disabled class={fieldset_demo_class()}>
        <:legend>Billing address — disabled</:legend>
        <p class="mb-3 text-xs text-[var(--c-base-content)]/50">
          Native <code>&lt;fieldset disabled&gt;</code>
          disables every control inside (no JS); <code>data-disabled</code>
          dims the group.
        </p>
        <div class="space-y-3">
          <label class="block text-sm">
            <span class="mb-1 block text-[var(--c-base-content)]/70">Card number</span>
            <input
              type="text"
              name="card"
              value="4242 4242 4242 4242"
              class="w-full rounded-md border border-[var(--c-base-300)] px-3 py-1.5"
            />
          </label>
          <label class="block text-sm">
            <span class="mb-1 block text-[var(--c-base-content)]/70">CVC</span>
            <input
              type="text"
              name="cvc"
              value="123"
              class="w-full rounded-md border border-[var(--c-base-300)] px-3 py-1.5"
            />
          </label>
        </div>
      </.fieldset>
    </div>
    """
  end

  def show(%{component: "menu"} = assigns) do
    ~H"""
    <.menu id={@id} side="bottom" align="start" class={menu_class()}>
      <:trigger>Options ▾</:trigger>
      <:item>Edit</:item>
      <:item>Duplicate</:item>
      <:item type="separator" />
      <:item type="checkbox" checked>Show grid</:item>
      <:item type="link" href="#docs">Documentation</:item>
      <:item type="separator" />
      <:item type="label">Sort by</:item>
      <:item type="radio" name="sort" value="name" checked>Name</:item>
      <:item type="radio" name="sort" value="date">Date</:item>
      <:item type="separator" />
      <:item disabled>Archive</:item>
      <:submenu label="Share">
        <.menu_item>Copy link</.menu_item>
        <.menu_item>Email</.menu_item>
      </:submenu>
    </.menu>
    """
  end

  def show(%{component: "menubar"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
        Open one menu, then hover or arrow across — the open menu follows (menubar mode). Help is disabled.
      </p>
      <.menubar
        id={@id}
        class="inline-flex gap-1 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-1 [&_[data-part=trigger]]:rounded [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger][data-popup-open]]:bg-[var(--c-base-200)] [&_[data-part=trigger][data-disabled]]:opacity-40 [&_[data-part=trigger][data-disabled]]:cursor-not-allowed [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-[var(--c-base-300)] [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[role=menuitem]]:block [&_[role=menuitem]]:w-full [&_[role=menuitem]]:rounded [&_[role=menuitem]]:px-3 [&_[role=menuitem]]:py-1.5 [&_[role=menuitem]]:text-left [&_[role=menuitem]]:text-sm [&_[role=menuitem]]:outline-none [&_[role=menuitem][data-highlighted]]:bg-[var(--c-base-200)]"
      >
        <:menu label="File">
          <button type="button" role="menuitem">New file</button>
          <button type="button" role="menuitem">Open…</button>
          <button type="button" role="menuitem">Save</button>
        </:menu>
        <:menu label="Edit">
          <button type="button" role="menuitem">Undo</button>
          <button type="button" role="menuitem">Redo</button>
          <button type="button" role="menuitem">Cut</button>
        </:menu>
        <:menu label="View">
          <button type="button" role="menuitem">Zoom in</button>
          <button type="button" role="menuitem">Zoom out</button>
          <button type="button" role="menuitem">Full screen</button>
        </:menu>
        <:menu label="Help" disabled>
          <button type="button" role="menuitem">About</button>
        </:menu>
      </.menubar>
    </div>
    """
  end

  def show(%{component: "meter"} = assigns) do
    ~H"""
    <.meter
      id={@id}
      label="Disk usage"
      value={72}
      min={0}
      max={100}
      show_value
      class="flex w-72 flex-wrap items-center [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=value]]:ml-auto [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-[var(--c-base-content)]/60 [&_[data-part=track]]:mt-1.5 [&_[data-part=track]]:h-3 [&_[data-part=track]]:w-full [&_[data-part=track]]:overflow-hidden [&_[data-part=track]]:rounded-full [&_[data-part=track]]:border [&_[data-part=track]]:border-[var(--c-base-300)] [&_[data-part=track]]:bg-[var(--c-base-200)] [&_[data-part=indicator]]:h-full [&_[data-part=indicator]]:bg-[var(--c-primary)] [&_[data-part=indicator]]:[width:calc(var(--chelekom-meter)*100%)]"
    />
    """
  end

  def show(%{component: "navigation_menu"} = assigns) do
    ~H"""
    <div class="space-y-2 pb-44">
      <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
        Hover Products then Resources — the shared popup morphs its size and slides by direction.
      </p>
      <.navigation_menu id={@id} class={navigation_menu_class()}>
        <:item label="Home" href="#home" active />
        <:item label="Products">
          <div class="grid w-80 grid-cols-2 gap-1 p-2">
            <a href="#analytics">Analytics</a>
            <a href="#automation">Automation</a>
            <a href="#reports">Reports</a>
            <a href="#api">API access</a>
          </div>
        </:item>
        <:item label="Resources">
          <div class="flex w-52 flex-col gap-1 p-2">
            <a href="#docs">Documentation</a>
            <a href="#guides">Guides</a>
            <a href="#blog">Blog</a>
          </div>
        </:item>
      </.navigation_menu>
    </div>
    """
  end

  def show(%{component: "number_field"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Quantity · min/max/step · arrows · press-and-hold
        </p>
        <.number_field
          id={@id}
          name="quantity"
          value="3"
          min="0"
          max="10"
          step="1"
          class={number_field_class()}
        />
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Currency · Shift ⇒ ±100 · Alt ⇒ ±0.01 · wheel scrub
        </p>
        <.number_field
          id={"#{@id}-usd"}
          name="price"
          value="1999.99"
          step="1"
          large_step="100"
          small_step="0.01"
          allow_wheel_scrub
          format={%{style: "currency", currency: "USD"}}
          class={number_field_class()}
        />
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Percent · value 0.075 ⇒ "7.5%" · step 0.01 (1%)
        </p>
        <.number_field
          id={"#{@id}-pct"}
          name="rate"
          value="0.075"
          min="0"
          max="1"
          step="0.01"
          format={%{style: "percent"}}
          class={number_field_class()}
        />
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Scrub · drag the label ←→ to change (no buttons) · ring shows data-scrubbing
        </p>
        <.number_field
          id={"#{@id}-scrub"}
          name="opacity"
          value="50"
          min="0"
          max="100"
          buttons={false}
          class={scrub_number_class()}
        >
          <:scrub_area>Opacity</:scrub_area>
        </.number_field>
      </div>
    </div>
    """
  end

  def show(%{component: "popover"} = assigns) do
    ~H"""
    <.popover
      id={@id}
      side="bottom"
      align="start"
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger][data-popup-open]]:bg-[var(--c-base-200)] [&_[data-part=popup]]:w-72 [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:border [&_[data-part=popup]]:border-[var(--c-base-300)] [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-4 [&_[data-part=popup]]:shadow-xl [&_[data-part=popup]]:outline-none [&_[data-part=popup]]:transition [&_[data-part=popup]]:duration-150 [&_[data-part=popup][data-starting-style]]:opacity-0 [&_[data-part=popup][data-starting-style]]:scale-95 [&_[data-part=popup][data-side=bottom]]:origin-top [&_[data-part=popup][data-side=top]]:origin-bottom [&_[data-part=title]]:text-sm [&_[data-part=title]]:font-semibold [&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-[var(--c-base-content)]/70 [&_[data-part=footer]]:mt-3 [&_[data-part=footer]]:flex [&_[data-part=footer]]:justify-end"
    >
      <:trigger>Open popover</:trigger>
      <:title>Anchored popover</:title>
      <:description>
        Anchored to the trigger — it flips near the viewport edge and follows on scroll. Click
        outside or press Escape to dismiss.
      </:description>
      <label class="mt-3 block text-sm">
        Quick note
        <input
          type="text"
          placeholder="focus lands here…"
          class="mt-1 w-full rounded border border-[var(--c-base-300)] px-2 py-1 text-sm outline-none focus:border-[var(--c-primary)]"
        />
      </label>
      <:close>
        <button
          type="button"
          class="rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm"
          data-close
        >
          Close
        </button>
      </:close>
    </.popover>
    """
  end

  def show(%{component: "preview_card"} = assigns) do
    ~H"""
    <.preview_card
      id={@id}
      side="top"
      class="[&_[data-part=trigger]]:underline [&_[data-part=trigger]]:decoration-dotted [&_[data-part=trigger]]:cursor-pointer [&_[data-part=trigger]]:outline-none [&_[data-part=popup]]:w-72 [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:border [&_[data-part=popup]]:border-[var(--c-base-300)] [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-4 [&_[data-part=popup]]:shadow-xl [&_[data-part=popup]]:transition [&_[data-part=popup]]:duration-150 [&_[data-part=popup][data-starting-style]]:opacity-0 [&_[data-part=popup][data-starting-style]]:scale-95 [&_[data-part=popup][data-side=top]]:origin-bottom [&_[data-part=popup][data-side=bottom]]:origin-top"
    >
      <:trigger>@mishka_chelekom</:trigger>
      <div class="flex items-start gap-3">
        <div class="h-10 w-10 shrink-0 rounded-full bg-[var(--c-base-300)]"></div>
        <div>
          <p class="text-sm font-semibold">Mishka Chelekom</p>
          <p class="mt-1 text-sm text-[var(--c-base-content)]/70">
            Headless, accessible UI components for Phoenix LiveView.
          </p>
          <p class="mt-2 text-xs text-[var(--c-base-content)]/60">1.2k followers · 340 following</p>
        </div>
      </div>
    </.preview_card>
    """
  end

  def show(%{component: "progress"} = assigns) do
    ~H"""
    <.progress
      id={@id}
      value={20}
      max={100}
      label="Export data"
      show_value
      phx-hook="DemoProgress"
      class="grid w-72 grid-cols-2 items-center gap-y-2 [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=value]]:text-right [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-[var(--c-base-content)]/60 [&_[data-part=track]]:col-span-2 [&_[data-part=track]]:h-2.5 [&_[data-part=track]]:overflow-hidden [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-[var(--c-base-200)] [&_[data-part=track]]:border [&_[data-part=track]]:border-[var(--c-base-300)] [&_[data-part=indicator]]:h-full [&_[data-part=indicator]]:w-full [&_[data-part=indicator]]:origin-left [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-[var(--c-primary)] [&_[data-part=indicator]]:transition-transform [&_[data-part=indicator]]:duration-500 [&_[data-part=indicator]]:[transform:scaleX(var(--chelekom-progress,0))] [&_[data-part=indicator][data-complete]]:bg-[var(--c-success)]"
    />
    """
  end

  def show(%{component: "radio_group"} = assigns) do
    ~H"""
    <.radio_group id={@id} name="plan" value="pro" class={radio_group_class()}>
      <:option value="free">Free</:option>
      <:option value="pro">Pro</:option>
      <:option value="enterprise">Enterprise</:option>
      <:option value="legacy" disabled>Legacy (unavailable)</:option>
    </.radio_group>
    """
  end

  def show(%{component: "scroll_area"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-6">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Vertical · custom scrollbar fades in on hover / scroll
        </p>
        <.scroll_area id={@id} orientation="vertical" class={scroll_area_class()}>
          <p class="text-sm font-semibold">Scrollable region</p>
          <ul class="mt-2 space-y-2 text-sm">
            <li :for={n <- 1..20} class="rounded border border-[var(--c-base-200)] px-2 py-1.5">
              Item {n}
            </li>
          </ul>
        </.scroll_area>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Scroll fade · masks the edges via <code>--scroll-area-overflow-y-*</code>
        </p>
        <.scroll_area
          id={"#{@id}-fade"}
          orientation="vertical"
          class={[scroll_area_class(), scroll_fade()]}
        >
          <p :for={n <- 1..16} class="text-sm leading-relaxed">
            Line {n} — fades at the top/bottom while there's more to scroll.
          </p>
        </.scroll_area>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Both axes · + corner
        </p>
        <.scroll_area id={"#{@id}-both"} orientation="both" class={scroll_area_class()}>
          <table class="text-sm">
            <tr :for={r <- 1..16}>
              <td
                :for={c <- 1..8}
                class="whitespace-nowrap border border-[var(--c-base-200)] px-3 py-1.5"
              >
                R{r}C{c}
              </td>
            </tr>
          </table>
        </.scroll_area>
      </div>
    </div>
    """
  end

  def show(%{component: "select"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Single · ✓ on selected · typeahead · disabled option
        </p>
        <.select
          id={@id}
          name="fruit"
          value="banana"
          placeholder="Choose a fruit…"
          class={select_class()}
        >
          <:option value="apple">Apple</:option>
          <:option value="banana">Banana</:option>
          <:option value="cherry">Cherry</:option>
          <:option value="durian" disabled>Durian (out of stock)</:option>
        </.select>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Multiple · grouped · stays open · placeholder when empty
        </p>
        <.select
          id={"#{@id}-multi"}
          name="picks"
          multiple
          placeholder="Pick toppings…"
          class={select_class()}
        >
          <:option value="cheese" group="Classic">Cheese</:option>
          <:option value="pepperoni" group="Classic">Pepperoni</:option>
          <:option value="mushroom" group="Veggie">Mushroom</:option>
          <:option value="onion" group="Veggie">Onion</:option>
        </.select>
      </div>
    </div>
    """
  end

  def show(%{component: "separator"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Horizontal
        </p>
        <div class="w-72 text-sm text-[var(--c-base-content)]/70">
          <p>Account settings</p>
          <.separator id={"#{@id}-plain"} class="my-2.5 h-px w-full bg-[var(--c-base-300)]" />
          <p>Danger zone</p>
        </div>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">Labelled</p>
        <.separator
          id={"#{@id}-or"}
          class="flex w-72 items-center gap-3 text-xs uppercase tracking-wide text-[var(--c-base-content)]/60 before:h-px before:flex-1 before:bg-[var(--c-base-300)] after:h-px after:flex-1 after:bg-[var(--c-base-300)] [&_[data-part=label]]:shrink-0"
        >
          or continue with
        </.separator>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Vertical (in a nav)
        </p>
        <nav class="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-[var(--c-base-content)]/80">
          <a href="#" class="hover:text-[var(--c-base-content)]">Home</a>
          <a href="#" class="hover:text-[var(--c-base-content)]">Pricing</a>
          <a href="#" class="hover:text-[var(--c-base-content)]">Blog</a>
          <a href="#" class="hover:text-[var(--c-base-content)]">Support</a>
          <.separator
            id={"#{@id}-nav"}
            orientation="vertical"
            class="h-4 w-px bg-[var(--c-base-300)]"
          />
          <a href="#" class="hover:text-[var(--c-base-content)]">Log in</a>
          <a href="#" class="hover:text-[var(--c-base-content)]">Sign up</a>
        </nav>
      </div>
    </div>
    """
  end

  def show(%{component: "slider"} = assigns) do
    ~H"""
    <div class="space-y-7">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Single · value readout
        </p>
        <.slider id={@id} name="volume" value={25} show_value class={slider_class()} />
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Range · two thumbs · min gap 1 step · push collision
        </p>
        <.slider
          id={"#{@id}-range"}
          name="price"
          values={[25, 45]}
          min_steps_between_values={1}
          class={slider_class()}
        />
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Steps + format · step 10 · percent
        </p>
        <.slider
          id={"#{@id}-pct"}
          name="opacity"
          value={50}
          step={10}
          show_value
          format={%{style: "unit", unit: "percent"}}
          class={slider_class()}
        />
      </div>

      <div class="flex gap-10">
        <div class="space-y-1.5">
          <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
            Vertical
          </p>
          <.slider
            id={"#{@id}-vert"}
            name="bass"
            value={35}
            orientation="vertical"
            class={slider_class()}
          />
        </div>
        <div class="space-y-1.5">
          <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
            Disabled
          </p>
          <.slider id={"#{@id}-dis"} value={60} disabled class={slider_class()} />
        </div>
      </div>
    </div>
    """
  end

  def show(%{component: "switch"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <div class="flex items-center gap-3">
        <.switch id={@id} name="notifications" checked class={switch_class()} />
        <span class="text-sm">On — the thumb slides via its own <code>data-checked</code></span>
      </div>
      <div class="flex items-center gap-3">
        <.switch id={"#{@id}-off"} name="sound" class={switch_class()} />
        <span class="text-sm">Off</span>
      </div>
      <div class="flex items-center gap-3">
        <.switch id={"#{@id}-ro"} checked readonly class={switch_class()} />
        <span class="text-sm">Read-only — focusable, won't toggle</span>
      </div>
      <div class="flex items-center gap-3">
        <.switch id={"#{@id}-dis"} checked disabled class={switch_class()} />
        <span class="text-sm text-[var(--c-base-content)]/50">Disabled</span>
      </div>
    </div>
    """
  end

  def show(%{component: "tabs"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
        Arrow keys move + activate; the indicator slides under the active tab (Billing is disabled).
      </p>
      <.tabs id={@id} default_value="password" class={tabs_class()}>
        <:tab value="password">Password</:tab>
        <:tab value="team">Team</:tab>
        <:tab value="billing" disabled>Billing</:tab>
        <:panel value="password">Update your password and review recent sign-in activity.</:panel>
        <:panel value="team">Invite teammates and configure their roles.</:panel>
        <:panel value="billing">Plans and invoices.</:panel>
      </.tabs>
    </div>
    """
  end

  def show(%{component: "toast"} = assigns) do
    ~H"""
    <.toast id={"#{@id}-basic"} limit={3} class={toast_class(:bottom)}>
      <:trigger>Create toast</:trigger>
      <:template>
        <div class="min-w-0 flex-1">
          <p class="font-semibold">Toast <span data-toast-count>1</span> created</p>
          <p class="text-[var(--c-base-content)]/70">This is a toast notification.</p>
        </div>
      </:template>
    </.toast>
    """
  end

  def show(%{component: "toggle"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <.toggle id={@id} class={toggle_class()}>
        <span class="hidden data-[pressed]:inline">★ Favorited</span>
        <span class="data-[pressed]:hidden">☆ Favorite</span>
      </.toggle>
      <.toggle id={"#{@id}-on"} pressed class={toggle_class()}>Bold</.toggle>
      <.toggle id={"#{@id}-dis"} pressed disabled class={toggle_class()}>Disabled</.toggle>
    </div>
    """
  end

  def show(%{component: "toggle_group"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Single-select · arrow keys loop · click the pressed one to deselect
        </p>
        <.toggle_group id={@id} value="center" class={toggle_group_class()}>
          <:item value="left">Left</:item>
          <:item value="center">Center</:item>
          <:item value="right">Right</:item>
        </.toggle_group>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Multiple · several pressed at once · one disabled item
        </p>
        <.toggle_group
          id={"#{@id}-multi"}
          multiple
          value={["bold", "italic"]}
          class={toggle_group_class()}
        >
          <:item value="bold">Bold</:item>
          <:item value="italic">Italic</:item>
          <:item value="underline" disabled>Underline</:item>
        </.toggle_group>
      </div>

      <div class="flex gap-8">
        <div class="space-y-1.5">
          <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
            Vertical
          </p>
          <.toggle_group
            id={"#{@id}-vert"}
            orientation="vertical"
            value="grid"
            class={["w-28", toggle_group_class()]}
          >
            <:item value="list">List</:item>
            <:item value="grid">Grid</:item>
            <:item value="cards">Cards</:item>
          </.toggle_group>
        </div>
        <div class="space-y-1.5">
          <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
            Disabled group
          </p>
          <.toggle_group id={"#{@id}-dis"} disabled value="b" class={toggle_group_class()}>
            <:item value="a">A</:item>
            <:item value="b">B</:item>
          </.toggle_group>
        </div>
      </div>
    </div>
    """
  end

  def show(%{component: "toolbar"} = assigns) do
    ~H"""
    <div class="space-y-2">
      <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
        Buttons · groups · separators · an input · a link — arrow keys rove (Underline is disabled but
        still focusable).
      </p>
      <.toolbar id={@id} class={toolbar_class()}>
        <:item type="button" group="Format" label="Bold"><strong>B</strong></:item>
        <:item type="button" group="Format" label="Italic"><em>I</em></:item>
        <:item type="button" group="Format" label="Underline" disabled><u>U</u></:item>
        <:item type="separator" />
        <:item type="input" placeholder="Search…" label="Search" />
        <:item type="link" href="#help" label="Help">Help</:item>
      </.toolbar>
    </div>
    """
  end

  def show(%{component: "tooltip"} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-x-8 gap-y-4">
      <.tooltip id={"#{@id}-top"} side="top" group="demo" class={tooltip_class()}>
        <:trigger>Top · grouped</:trigger>
        Appears above. After one in the group opens, the rest open instantly for a moment.
      </.tooltip>
      <.tooltip id={"#{@id}-bottom"} side="bottom" group="demo" class={tooltip_class()}>
        <:trigger>Bottom · grouped</:trigger>
        Shares the open delay with the other grouped tooltips.
      </.tooltip>
      <.tooltip id={"#{@id}-track"} side="top" track_cursor_axis="x" class={tooltip_class()}>
        <:trigger>Follows cursor (x)</:trigger>
        Tracks the pointer horizontally as you move along the trigger.
      </.tooltip>
      <.tooltip id={"#{@id}-disabled"} disabled class={tooltip_class()}>
        <:trigger>Disabled</:trigger>
        You will never see this one.
      </.tooltip>
    </div>
    """
  end

  def show(%{component: "tree"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Files · click to select · ↑↓ to walk · ←→ to collapse/expand · the <code>:node</code>
          slot draws the icons
        </p>
        <.tree
          id={@id}
          aria_label="Project files"
          select_on_click
          expanded={["src"]}
          nodes={[
            %{
              label: "src",
              value: "src",
              children: [
                %{
                  label: "components",
                  value: "src/components",
                  children: [
                    %{label: "Accordion.tsx", value: "src/components/Accordion.tsx"},
                    %{label: "Tree.tsx", value: "src/components/Tree.tsx"}
                  ]
                },
                %{label: "app.tsx", value: "src/app.tsx"}
              ]
            },
            %{label: "package.json", value: "package.json"},
            %{label: "tsconfig.json", value: "tsconfig.json"}
          ]}
          class={tree_class()}
        >
          <:expand_icon>
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M6 12V4l4.5 4z" />
            </svg>
          </:expand_icon>
          <:node :let={n}>
            <svg
              :if={n.has_children}
              width="14"
              height="14"
              viewBox="0 0 16 16"
              fill="none"
              stroke="currentColor"
              class="shrink-0 opacity-60"
            >
              <path d="M1.5 12.5v-9h4l1.5 2h7.5v7z" />
            </svg>
            <svg
              :if={!n.has_children}
              width="14"
              height="14"
              viewBox="0 0 16 16"
              fill="none"
              stroke="currentColor"
              class="shrink-0 opacity-60"
            >
              <path d="M3.5 1.5h6l3 3v11h-9z" />
              <path d="M9.5 1.5v3.5h3" />
            </svg>
            {n.node.label}
          </:node>
        </.tree>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Multiple · shift-click a range · <code>expanded={:all}</code>
        </p>
        <.tree
          id={"#{@id}-multi"}
          aria_label="Team"
          multiple
          select_on_click
          allow_range_selection
          expanded={:all}
          selected={["ana", "cleo"]}
          nodes={[
            %{
              label: "Design",
              value: "design",
              children: [
                %{label: "Ana", value: "ana"},
                %{label: "Ben", value: "ben"}
              ]
            },
            %{
              label: "Engineering",
              value: "eng",
              children: [
                %{label: "Cleo", value: "cleo"},
                %{label: "Dev", value: "dev"}
              ]
            }
          ]}
          class={tree_class()}
        >
          <:expand_icon>
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M6 12V4l4.5 4z" />
            </svg>
          </:expand_icon>
        </.tree>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-[var(--c-base-content)]/40">
          Cascading checkboxes · a half-checked parent reports <code>aria-checked="mixed"</code>
          · <code>name</code>
          posts the leaves natively
        </p>
        <.tree
          id={"#{@id}-checks"}
          aria_label="Permissions"
          with_checkboxes
          name="permissions[]"
          expanded={:all}
          checked={["content:read", "billing:read", "billing:write"]}
          nodes={[
            %{
              label: "Content",
              value: "content",
              children: [
                %{label: "Read posts", value: "content:read"},
                %{label: "Write posts", value: "content:write"}
              ]
            },
            %{
              label: "Billing",
              value: "billing",
              children: [
                %{label: "View invoices", value: "billing:read"},
                %{label: "Change plan", value: "billing:write"}
              ]
            }
          ]}
          class={tree_class()}
        >
          <:expand_icon>
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M6 12V4l4.5 4z" />
            </svg>
          </:expand_icon>
        </.tree>
      </div>
    </div>
    """
  end

  def show(assigns) do
    ~H"""
    <p class="text-sm text-[var(--c-base-content)]/60">No example for <code>{@component}</code>.</p>
    """
  end

  # Shared toast stacking classes for the showcase (`:bottom` grows up, `:top` grows down — Base UI's
  # two viewport variants). Kept literal so Tailwind scans them.
  defp toast_class(anchor) do
    [
      "relative w-72 space-y-3",
      "[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:bg-[var(--c-base-100)] [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:hover:bg-[var(--c-base-200)]",
      "[&_[data-part=viewport]]:relative [&_[data-part=viewport]]:h-60 [&_[data-part=viewport]]:w-full [&_[data-part=viewport]]:overflow-hidden [&_[data-part=viewport]]:[list-style:none] [&_[data-part=viewport]]:[padding:0] [&_[data-part=viewport]]:[margin:0]",
      "[&_[data-part=toast]]:[--gap:0.6rem] [&_[data-part=toast]]:[--peek:0.6rem] [&_[data-part=toast]]:[--scale:calc(max(0,1-(var(--toast-index)*0.1)))] [&_[data-part=toast]]:[--shrink:calc(1-var(--scale))] [&_[data-part=toast]]:[--height:var(--toast-frontmost-height,var(--toast-height))] [&_[data-part=toast]]:absolute [&_[data-part=toast]]:inset-x-0 [&_[data-part=toast]]:z-[calc(1000-var(--toast-index))] [&_[data-part=toast]]:h-[var(--height)] [&_[data-part=toast]]:rounded-md [&_[data-part=toast]]:border [&_[data-part=toast]]:border-[var(--c-base-300)] [&_[data-part=toast]]:bg-[var(--c-base-100)] [&_[data-part=toast]]:shadow-lg [&_[data-part=toast]]:[transition:transform_0.5s_cubic-bezier(0.22,1,0.36,1),opacity_0.4s,height_0.15s]",
      "[&_[data-part=toast][data-expanded]]:[transform:translateY(var(--offset-y))] [&_[data-part=toast][data-expanded]]:h-[var(--toast-height)] [&_[data-part=toast][data-ending-style]]:opacity-0 [&_[data-part=toast][data-limited]]:opacity-0",
      "[&_[data-part=content]]:flex [&_[data-part=content]]:h-full [&_[data-part=content]]:items-start [&_[data-part=content]]:gap-3 [&_[data-part=content]]:overflow-hidden [&_[data-part=content]]:p-3 [&_[data-part=content]]:text-sm [&_[data-part=content]]:transition-opacity [&_[data-part=content][data-behind]]:opacity-0",
      "[&_[data-part=close]]:ml-auto [&_[data-part=close]]:shrink-0 [&_[data-part=close]]:rounded [&_[data-part=close]]:px-1.5 [&_[data-part=close]]:text-lg [&_[data-part=close]]:leading-none [&_[data-part=close]]:text-[var(--c-base-content)]/40 [&_[data-part=close]]:hover:text-[var(--c-base-content)]",
      toast_anchor(anchor)
    ]
  end

  defp toast_anchor(:bottom),
    do:
      "[&_[data-part=toast]]:bottom-0 [&_[data-part=toast]]:origin-bottom [&_[data-part=toast]]:[--offset-y:calc(var(--toast-offset-y)*-1+(var(--toast-index)*var(--gap)*-1)+var(--toast-swipe-movement-y))] [&_[data-part=toast]]:[transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--toast-swipe-movement-y)-(var(--toast-index)*var(--peek))-(var(--shrink)*var(--height))))_scale(var(--scale))] [&_[data-part=toast][data-starting-style]]:[transform:translateY(120%)] [&_[data-part=toast][data-ending-style]]:[transform:translateY(120%)] [&_[data-part=toast][data-expanded][data-starting-style]]:[transform:translateY(120%)] [&_[data-part=toast][data-expanded][data-ending-style]]:[transform:translateY(120%)]"

  defp toast_anchor(:top),
    do:
      "[&_[data-part=toast]]:top-0 [&_[data-part=toast]]:origin-top [&_[data-part=toast]]:[--offset-y:calc(var(--toast-offset-y)+(var(--toast-index)*var(--gap))+var(--toast-swipe-movement-y))] [&_[data-part=toast]]:[transform:translateX(var(--toast-swipe-movement-x))_translateY(calc(var(--toast-swipe-movement-y)+(var(--toast-index)*var(--peek))+(var(--shrink)*var(--height))))_scale(var(--scale))] [&_[data-part=toast][data-starting-style]]:[transform:translateY(-120%)] [&_[data-part=toast][data-ending-style]]:[transform:translateY(-120%)] [&_[data-part=toast][data-expanded][data-starting-style]]:[transform:translateY(-120%)] [&_[data-part=toast][data-expanded][data-ending-style]]:[transform:translateY(-120%)]"

  @doc "Extra worked examples shown in the bottom \"Examples\" section (only some components have them)."
  def has_examples?("toast"), do: true
  def has_examples?("field"), do: true
  def has_examples?("otp_field"), do: true
  def has_examples?("checkbox"), do: true
  def has_examples?("checkbox_group"), do: true
  def has_examples?("combobox"), do: true
  def has_examples?("number_field"), do: true
  def has_examples?("autocomplete"), do: true
  def has_examples?("fieldset"), do: true
  def has_examples?("radio"), do: true
  def has_examples?("radio_group"), do: true
  def has_examples?("select"), do: true
  def has_examples?("slider"), do: true
  def has_examples?("switch"), do: true
  def has_examples?("toggle"), do: true
  def has_examples?("toggle_group"), do: true
  def has_examples?("navigation_menu"), do: true
  def has_examples?("tabs"), do: true
  def has_examples?("alert_dialog"), do: true
  def has_examples?("tree"), do: true
  def has_examples?("empty_state"), do: true
  def has_examples?(_), do: false

  def examples(%{component: "empty_state"} = assigns) do
    ~H"""
    <div class="grid gap-3 sm:grid-cols-2">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">Left &amp; right alignment</summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          <code>data-align</code> flips the whole layout — indicator, text and actions — from CSS, with
          no change to the markup.
        </p>
        <div class="mt-4 space-y-6">
          <.empty_state
            id={"#{@id}-left"}
            align="left"
            title="No messages"
            description="Your inbox is empty."
            class={empty_state_class()}
          >
            <:indicator>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="size-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75"
                />
              </svg>
            </:indicator>
          </.empty_state>
          <.empty_state
            id={"#{@id}-right"}
            align="right"
            title="No messages"
            description="Your inbox is empty."
            class={empty_state_class()}
          >
            <:indicator>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="size-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75"
                />
              </svg>
            </:indicator>
          </.empty_state>
        </div>
      </details>

      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">Filled indicator</summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A colored circular background behind the icon (Mantine's <code>filled</code>/<code>light</code>
          variants) — pure CSS on the <code>indicator</code> part.
        </p>
        <div class="mt-4">
          <.empty_state
            id={"#{@id}-filled"}
            title="All caught up"
            description="You've read every notification."
            class={empty_state_filled_class()}
          >
            <:indicator>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="size-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
                />
              </svg>
            </:indicator>
          </.empty_state>
        </div>
      </details>

      <details class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">Error state with retry</summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The same component doubles as a failure view — swap the icon and add a retry action.
        </p>
        <div class="mt-4">
          <.empty_state
            id={"#{@id}-error"}
            title="Couldn't load data"
            description="Something went wrong. Check your connection and try again."
            class={empty_state_class()}
          >
            <:indicator>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="size-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
                />
              </svg>
            </:indicator>
            <:actions>
              <button
                type="button"
                class="rounded-md border border-[var(--c-base-300)] px-3 py-1.5 text-sm hover:bg-[var(--c-base-200)]"
              >
                Retry
              </button>
            </:actions>
          </.empty_state>
        </div>
      </details>

      <details class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">Announced dynamically</summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          When the empty state appears after a user action, pass <code>role="status"</code>
          through <code>rest</code> so assistive tech announces it politely.
        </p>
        <div class="mt-4">
          <.empty_state
            id={"#{@id}-status"}
            role="status"
            title="No results"
            description="No items match this filter."
            class={empty_state_class()}
          >
            <:indicator>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="size-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
                />
              </svg>
            </:indicator>
          </.empty_state>
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "toast"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">Top placement</summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          Position is pure CSS on the viewport. Here the stack anchors at the top and grows downward;
          in a real app add <code>fixed left-4 top-4</code> to the viewport.
        </p>
        <div class="mt-4">
          <.toast id={"#{@id}-top"} limit={5} duration={2000} class={toast_class(:top)}>
            <:trigger>Create toast</:trigger>
            <:template>
              <div class="min-w-0 flex-1">
                <p class="font-semibold">Toast <span data-toast-count>1</span> created</p>
                <p class="text-[var(--c-base-content)]/70">Auto-dismisses in 2 seconds.</p>
              </div>
            </:template>
          </.toast>
        </div>
        <.code_block code={example_code("Top placement")} class="mt-3" />
      </details>

      <details class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">Deduplicated</summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          With <code>dedup_key</code>, clicking repeatedly refreshes the same toast (resets its timer,
          pops it to the front) instead of stacking duplicates.
        </p>
        <div class="mt-4">
          <.toast id={"#{@id}-dedup"} dedup_key="saved" class={toast_class(:bottom)}>
            <:trigger>Save (click repeatedly)</:trigger>
            <:template>
              <div class="min-w-0 flex-1">
                <p class="font-semibold">Saved</p>
                <p class="text-[var(--c-base-content)]/70">
                  Re-clicking just refreshes this one toast.
                </p>
              </div>
            </:template>
          </.toast>
        </div>
        <.code_block code={example_code("Deduplicated")} class="mt-3" />
      </details>

      <details class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">Varying heights</summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          Toasts of different heights stack correctly — the engine measures each one and offsets the
          stack accordingly. Hover to fan them out (these are sticky, no auto-dismiss).
        </p>
        <div class="mt-4">
          <.toast id={"#{@id}-vary"} class={toast_class(:bottom)}>
            <:toast duration={0}>
              <div class="min-w-0 flex-1">
                <p class="font-semibold">Short</p>
              </div>
            </:toast>
            <:toast duration={0}>
              <div class="min-w-0 flex-1">
                <p class="font-semibold">Medium</p>
                <p class="text-[var(--c-base-content)]/70">A second line of detail.</p>
              </div>
            </:toast>
            <:toast duration={0}>
              <div class="min-w-0 flex-1">
                <p class="font-semibold">Tall</p>
                <p class="text-[var(--c-base-content)]/70">
                  This one runs to three lines so the stack has to account for different heights when
                  it expands on hover.
                </p>
              </div>
            </:toast>
          </.toast>
        </div>
        <.code_block code={example_code("Varying heights")} class="mt-3" />
      </details>
    </div>
    """
  end

  def examples(%{component: "field"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          Full form — realtime + submit validation (Ecto, not persisted)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A real <code>&lt;.form&gt;</code>
          backed by an Ecto <code>embedded_schema</code>
          changeset — no database, nothing is saved. The stateless <code>&lt;.field&gt;</code>
          auto-wires <code>for</code>
          / <code>aria-describedby</code>
          (description + every error) / <code>aria-invalid</code>, and hands <code>id</code>/<code>name</code>/<code>describedby</code>
          back through <code>:let</code>. Errors appear per-field once you touch it
          (<code>used_input?</code>) and on submit; the <code>Field</code>
          hook adds <code>data-focused</code>/<code>-touched</code>/<code>-dirty</code>/<code>-filled</code>.
        </p>
        <div class="mt-4 max-w-md">
          <.live_component module={DevelopmentWeb.Showcase.FieldFormDemo} id={"#{@id}-form"} />
        </div>
      </details>

      <details class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          State attributes — at a glance
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The same field rendered in four server-known states. Focus or type in the first one to also
          see <code>data-focused</code> / <code>data-filled</code> toggle live.
        </p>
        <div class="mt-4 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <.field :let={f} id={"#{@id}-st-ok"} name="ok" label="Pristine" class={field_state_class()}>
            <input
              id={f.id}
              name={f.name}
              aria-describedby={f.describedby}
              placeholder="type here…"
              class="w-full rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm outline-none"
            />
            <:description>Untouched — neither attribute.</:description>
          </.field>

          <.field
            :let={f}
            id={"#{@id}-st-good"}
            name="good"
            label="Valid"
            valid={true}
            class={field_state_class()}
          >
            <input
              id={f.id}
              name={f.name}
              value="ada@example.com"
              aria-describedby={f.describedby}
              class="w-full rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm outline-none"
            />
            <:description>Passes — <code>data-valid</code> (green + ✓).</:description>
          </.field>

          <.field
            :let={f}
            id={"#{@id}-st-bad"}
            name="bad"
            label="Invalid"
            errors={["This field is required"]}
            class={field_state_class()}
          >
            <input
              id={f.id}
              name={f.name}
              value=""
              aria-describedby={f.describedby}
              aria-invalid={f.invalid && "true"}
              class="w-full rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm outline-none"
            />
            <:description>Errors drive <code>data-invalid</code> + the red control.</:description>
          </.field>

          <.field
            :let={f}
            id={"#{@id}-st-off"}
            name="off"
            label="Disabled"
            disabled
            class={field_state_class()}
          >
            <input
              id={f.id}
              name={f.name}
              value="Read only"
              disabled={f.disabled}
              aria-describedby={f.describedby}
              class="w-full rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm outline-none"
            />
            <:description>Dimmed via <code>data-disabled</code>.</:description>
          </.field>
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "otp_field"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          Verify a code — submitted to the server &amp; validated in a form
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The <code>&lt;.otp_field&gt;</code>
          carries its value in a hidden input (<code>name="code"</code>), so it submits like any field.
          With <code>auto_submit</code>
          the form's <code>phx-submit</code>
          fires the moment the last digit lands; the LiveView validates <code>params["code"]</code>
          server-side. Nothing is saved — the expected code is <code>123456</code>.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.OtpFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "tree"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <p class="text-sm text-[var(--c-base-content)]/60">
        Every server-driven situation, live. The tree only reports what happened — moving a node,
        loading children and filtering are all the server's job.
      </p>
      <.live_component module={DevelopmentWeb.Showcase.TreeDemos} id={"#{@id}-demos"} />
    </div>
    """
  end

  def examples(%{component: "checkbox"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — accept terms (Ecto changeset, not persisted)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A boolean checkbox submitted with <code>&lt;.form&gt;</code>
          and validated by <code>validate_acceptance</code>. A hidden <code>false</code>
          input supplies the unchecked value (the same trick
          <code>&lt;.input type="checkbox"&gt;</code>
          uses).
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.CheckboxFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "checkbox_group"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — pick toppings (submits a list, validated)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The checked items submit as <code>name[]</code>, cast to an <code>array of strings</code>
          changeset field and validated to require at least one.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.CheckboxGroupFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "combobox"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — select a value (required, validated)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The selection submits via the combobox's hidden value input (<code>name</code>) and is
          validated <code>required</code> on submit.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.ComboboxFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "number_field"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — quantity with range validation
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The raw number submits via the hidden <code>type="number"</code>
          input and is validated with <code>validate_number</code>
          (1–10) on submit.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.NumberFieldFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "autocomplete"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — pick a city (required, validated)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The selection submits via the autocomplete's hidden value input (<code>name</code>) and is
          validated <code>required</code> on submit.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.AutocompleteFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "fieldset"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — group inputs (realtime + submit validation)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The fieldset groups native inputs that submit normally; the changeset validates them on
          <code>phx-change</code>
          and <code>phx-submit</code>.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.FieldsetFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "radio"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — choose a plan (required, validated)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A native radio group (shared <code>name</code>) submitted with <code>&lt;.form&gt;</code>
          and validated <code>required</code>. The <code>Radio</code>
          hook keeps <code>data-checked</code>
          live on each radio as the selection moves.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.RadioFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "radio_group"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — choose a plan (required, validated)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The roving group's hidden input carries the selection (<code>name</code>); the
          <code>RadioGroup</code>
          hook keeps it (and <code>data-checked</code>) in sync as you arrow/click, so it submits with
          <code>&lt;.form&gt;</code>
          and is validated <code>required</code>
          on submit.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.RadioGroupFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "select"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — choose a country (required, validated)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The listbox's hidden input carries the selection (<code>name</code>); the
          <code>Select</code>
          hook keeps it in sync as you pick, so it submits with <code>&lt;.form&gt;</code>
          and is validated <code>required</code>
          on submit.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.SelectFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "slider"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — set a budget (range-validated)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The thumb's hidden input carries the value (<code>name</code>); the <code>Slider</code>
          hook keeps it in sync and dispatches on commit, so it submits with
          <code>&lt;.form&gt;</code>
          and is validated with <code>validate_number</code>
          (10–80) on submit. On success the handler assigns a fresh changeset, so the slider
          <strong>resets back to the default (40)</strong>
          — the usual "form clears after save".
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.SliderFormDemo} id={"#{@id}-form"} />
        </div>
      </details>

      <details class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — a range (two thumbs → an array)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A two-thumb range submits both values as an array (<code>name[]</code>); pass the field's
          list straight through with <code>values={"{f[:price].value}"}</code>
          — no conversion. On submit the form re-renders with the saved values and the hook
          repositions both thumbs; <strong>Reset</strong>
          assigns a fresh changeset to snap it back.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component
            module={DevelopmentWeb.Showcase.SliderRangeFormDemo}
            id={"#{@id}-range-form"}
          />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "switch"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — settings with a required toggle
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          Each switch carries a hidden checkbox; <code>value</code>
          / <code>unchecked_value</code>
          submit a boolean either way (on → <code>"true"</code>, off → <code>"false"</code>), so
          <code>&lt;.form&gt;</code>
          always gets a value. The terms switch is validated with <code>validate_acceptance</code>
          on submit.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.SwitchFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "toggle"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — submit a toggle as a boolean
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A pressed button isn't a form control in Base UI, but giving it a <code>name</code>
          opts into form submission: it renders a hidden checkbox the engine keeps in sync, so
          <code>value</code>
          / <code>unchecked_value</code>
          submit a boolean either way and it works with <code>&lt;.form&gt;</code>
          (cast to <code>:boolean</code>).
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.ToggleFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "toggle_group"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          In a form — single + multiple selection
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A single-select group submits one value (<code>name</code>, validated <code>required</code>); a multiple group submits an array (<code>name[]</code>, cast to <code>{"{:array, :string}"}</code>). The hook mirrors the pressed values into hidden inputs,
          so both work with <code>&lt;.form&gt;</code>.
        </p>
        <div class="mt-4 max-w-sm">
          <.live_component module={DevelopmentWeb.Showcase.ToggleGroupFormDemo} id={"#{@id}-form"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "navigation_menu"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          Base-UI-style — rich content panels with titles + descriptions
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          Like the Base UI site: each menu opens a panel of cards (title + description). Hover across
          the triggers and watch the shared popup morph its size + slide.
        </p>
        <div class="mt-4 pb-56">
          <.navigation_menu id={"#{@id}-ex"} class={nav_ex_class()}>
            <:item label="Overview" href="#overview" active />
            <:item label="Handbook">
              <ul class="grid w-[28rem] grid-cols-2 gap-1 p-2">
                <li :for={c <- nav_handbook()}>
                  <a href={c.href}>
                    <h3 class="text-sm font-medium">{c.title}</h3>
                    <p class="mt-0.5 text-xs text-[var(--c-base-content)]/60">{c.desc}</p>
                  </a>
                </li>
              </ul>
            </:item>
            <:item label="Resources">
              <ul class="flex w-72 flex-col gap-1 p-2">
                <li :for={c <- nav_resources()}>
                  <a href={c.href}>
                    <h3 class="text-sm font-medium">{c.title}</h3>
                    <p class="mt-0.5 text-xs text-[var(--c-base-content)]/60">{c.desc}</p>
                  </a>
                </li>
              </ul>
            </:item>
            <:item label="GitHub" href="https://github.com" />
          </.navigation_menu>
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "tabs"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          Push to the server — controlled tabs (on_change + value)
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          Switching a tab pushes <code>{"%{value}"}</code>
          to the LiveComponent via <code>on_change</code>
          / <code>on_change_target</code>; the server stores it and feeds it
          back through <code>value</code>
          — so it stays in sync, and the server can drive the tab itself (the button).
        </p>
        <div class="mt-4 max-w-md">
          <.live_component module={DevelopmentWeb.Showcase.TabsServerDemo} id={"#{@id}-srv"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(%{component: "alert_dialog"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details open class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4">
        <summary class="cursor-pointer select-none font-medium">
          Confirm a destructive action — drives the server
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The alert never dismisses on an outside click — only the buttons (or Escape) close it. The
          <strong>Delete</strong>
          button has <code>data-close</code>
          (closes) plus <code>phx-click</code>
          (deletes server-side), and <code>on_open_change</code>
          reports each open/close.
        </p>
        <div class="mt-4">
          <.live_component module={DevelopmentWeb.Showcase.AlertDialogDemo} id={"#{@id}-demo"} />
        </div>
      </details>
    </div>
    """
  end

  def examples(assigns), do: ~H""

  defp nav_handbook do
    [
      %{
        title: "Styling",
        href: "#styling",
        desc: "Plain CSS, Tailwind, CSS-in-JS, or CSS Modules."
      },
      %{
        title: "Animation",
        href: "#animation",
        desc: "CSS transitions, animations, or JS libraries."
      },
      %{
        title: "Composition",
        href: "#composition",
        desc: "Replace and compose with your own elements."
      },
      %{
        title: "Accessibility",
        href: "#a11y",
        desc: "ARIA, focus management and keyboard built in."
      }
    ]
  end

  defp nav_resources do
    [
      %{title: "Documentation", href: "#docs", desc: "Guides and the full API reference."},
      %{title: "Changelog", href: "#changelog", desc: "What shipped in each release."},
      %{title: "Community", href: "#community", desc: "Discord, discussions and showcases."}
    ]
  end

  # Base-UI-style nav menu: cards (title + desc) inside the morphing popup.
  defp nav_ex_class do
    [
      "flex gap-1",
      "[&_[data-part=link]]:flex [&_[data-part=link]]:items-center [&_[data-part=link]]:rounded-md [&_[data-part=link]]:px-3 [&_[data-part=link]]:py-2 [&_[data-part=link]]:text-sm [&_[data-part=link]]:font-medium [&_[data-part=link]]:hover:bg-[var(--c-base-200)] [&_[data-part=link][data-active]]:text-[var(--c-primary)]",
      "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:gap-1 [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-2 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:hover:bg-[var(--c-base-200)] [&_[data-part=trigger][data-popup-open]]:bg-[var(--c-base-200)]",
      "[&_[data-part=icon]]:text-[0.6rem] [&_[data-part=icon]]:transition-transform [&_[data-part=icon][data-open]]:rotate-180",
      "[&_[data-part=popup]]:rounded-xl [&_[data-part=popup]]:border [&_[data-part=popup]]:border-[var(--c-base-300)] [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:shadow-xl",
      "[&_[data-part=content]_a]:block [&_[data-part=content]_a]:rounded-lg [&_[data-part=content]_a]:p-3 [&_[data-part=content]_a]:hover:bg-[var(--c-base-200)]",
      "[&_[data-part=arrow]]:absolute [&_[data-part=arrow]]:-top-1 [&_[data-part=arrow]]:-ml-1.5 [&_[data-part=arrow]]:size-2.5 [&_[data-part=arrow]]:rotate-45 [&_[data-part=arrow]]:border-l [&_[data-part=arrow]]:border-t [&_[data-part=arrow]]:border-[var(--c-base-300)] [&_[data-part=arrow]]:bg-[var(--c-base-100)]"
    ]
  end

  # Radio group: each option is a card with a leading dot drawn by ::before that fills via data-checked
  # (set live by the RadioGroup hook). data-highlighted = focus ring; data-disabled dims + blocks.
  # Context menu: a right-click area + a cursor-positioned menu. All rows are role=menuitem*
  # so one [role^=menuitem] variant styles items/checkbox/radio/link/submenu-trigger together.
  defp context_menu_class do
    [
      "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:h-48 [&_[data-part=trigger]]:w-64 [&_[data-part=trigger]]:select-none [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-center [&_[data-part=trigger]]:rounded-lg [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-dashed [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:text-[var(--c-base-content)]/60",
      "[&_[role=menu]]:min-w-52 [&_[role=menu]]:rounded-lg [&_[role=menu]]:border [&_[role=menu]]:border-[var(--c-base-300)] [&_[role=menu]]:bg-[var(--c-base-100)] [&_[role=menu]]:p-1 [&_[role=menu]]:text-sm [&_[role=menu]]:shadow-lg [&_[role=menu]]:outline-none [&_[role=menu]]:origin-top-left [&_[role=menu]]:transition [&_[role=menu]]:duration-150 [&_[role=menu][data-starting-style]]:scale-95 [&_[role=menu][data-starting-style]]:opacity-0",
      "[&_[role^=menuitem]]:flex [&_[role^=menuitem]]:w-full [&_[role^=menuitem]]:cursor-default [&_[role^=menuitem]]:select-none [&_[role^=menuitem]]:items-center [&_[role^=menuitem]]:gap-2 [&_[role^=menuitem]]:rounded [&_[role^=menuitem]]:px-2 [&_[role^=menuitem]]:py-1.5 [&_[role^=menuitem]]:text-left [&_[role^=menuitem]]:text-[var(--c-base-content)] [&_[role^=menuitem]]:no-underline [&_[role^=menuitem]]:outline-none",
      "[&_[role^=menuitem][data-highlighted]]:bg-[var(--c-base-200)] [&_[role^=menuitem][data-disabled]]:opacity-40",
      "[&_[data-part$=indicator]]:inline-flex [&_[data-part$=indicator]]:w-4 [&_[data-part$=indicator]]:shrink-0 [&_[data-part$=indicator]]:justify-center [&_[data-part$=indicator]]:text-xs [&_[data-part$=indicator]]:text-[var(--c-primary)]",
      "[&_[data-part=submenu-chevron]]:ml-auto [&_[data-part=submenu-chevron]]:text-[var(--c-base-content)]/40",
      "[&_[data-part=separator]]:my-1 [&_[data-part=separator]]:h-px [&_[data-part=separator]]:bg-[var(--c-base-300)]",
      "[&_[data-part=group-label]]:px-2 [&_[data-part=group-label]]:py-1 [&_[data-part=group-label]]:text-xs [&_[data-part=group-label]]:font-medium [&_[data-part=group-label]]:uppercase [&_[data-part=group-label]]:tracking-wide [&_[data-part=group-label]]:text-[var(--c-base-content)]/40"
    ]
  end

  defp tooltip_class do
    [
      "[&_[data-part=trigger]]:cursor-help [&_[data-part=trigger]]:underline [&_[data-part=trigger]]:decoration-dotted [&_[data-part=trigger]]:underline-offset-4 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:outline-none",
      "[&_[data-part=popup]]:max-w-48 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:bg-[var(--c-base-content)] [&_[data-part=popup]]:px-2 [&_[data-part=popup]]:py-1 [&_[data-part=popup]]:text-xs [&_[data-part=popup]]:text-[var(--c-base-100)] [&_[data-part=popup]]:shadow-lg [&_[data-part=popup]]:transition [&_[data-part=popup]]:duration-100 [&_[data-part=popup][data-starting-style]]:opacity-0 [&_[data-part=popup][data-starting-style]]:scale-95 [&_[data-part=popup][data-side=top]]:origin-bottom [&_[data-part=popup][data-side=bottom]]:origin-top"
    ]
  end

  # File-explorer look. The indent is the component's only structural style: every node publishes
  # `--label-offset`, and nothing consumes it until the label pads itself by it. A collapsed subtree
  # is hidden by the `hidden` attribute the hook toggles, so the subtree must never take a display
  # utility. The chevron reads its own node's state — matching on `[data-expanded=true] >` and not a
  # descendant keeps a leaf's chevron from rotating inside an open parent.
  @doc "Showcase skin for the headless tree — shared with `TreeDemos`."
  def tree_class do
    [
      "w-64 select-none text-sm",
      "[&_[data-part=label]]:flex [&_[data-part=label]]:items-center [&_[data-part=label]]:gap-1.5 [&_[data-part=label]]:rounded [&_[data-part=label]]:py-1 [&_[data-part=label]]:pr-2 [&_[data-part=label]]:pl-[calc(var(--label-offset)+0.375rem)] [&_[data-part=label]:hover]:bg-[var(--c-base-200)]",
      "[&_[data-part=label][data-selected]]:bg-[var(--c-primary)]/15 [&_[data-part=label][data-selected]]:font-medium",
      "[&_[data-part=expand-icon]]:grid [&_[data-part=expand-icon]]:size-4 [&_[data-part=expand-icon]]:shrink-0 [&_[data-part=expand-icon]]:place-items-center [&_[data-part=expand-icon]]:text-[var(--c-base-content)]/40 [&_[data-part=expand-icon]]:transition-transform [&_[data-part=expand-icon]]:duration-100",
      "[&_[data-expanded=true]>[data-part=label]>[data-part=expand-icon]]:rotate-90",
      "[&_[data-part=label-text]]:inline-flex [&_[data-part=label-text]]:items-center [&_[data-part=label-text]]:gap-1.5",
      "[&_[data-part=checkbox]]:size-3.5 [&_[data-part=checkbox]]:shrink-0 [&_[data-part=checkbox]]:accent-[var(--c-primary)]",
      "[&_li]:outline-none [&_li:focus-visible>[data-part=label]]:ring-2 [&_li:focus-visible>[data-part=label]]:ring-[var(--c-primary)]/40",
      "[&_li[data-disabled]]:opacity-40",
      # Drag & drop feedback. The hook only sets `data-dragging` / `data-drag-over=before|after|
      # inside`; headless ships no CSS, so without these the drop is invisible and you cannot
      # tell whether you are landing above, below, or inside a row.
      "[&_[data-part=label]]:relative",
      "[&_[data-part=label][data-dragging]]:opacity-40",
      "[&_[data-part=label][data-drag-over=inside]]:bg-[var(--c-primary)]/25",
      "[&_[data-part=label][data-drag-over=inside]]:ring-1 [&_[data-part=label][data-drag-over=inside]]:ring-[var(--c-primary)]",
      # before/after are a 2px insertion line at the row's edge, inset to the node's own depth so
      # it reads as "between these two siblings" rather than spanning the whole tree.
      "[&_[data-part=label][data-drag-over=before]]:before:content-['']",
      "[&_[data-part=label][data-drag-over=before]]:before:absolute",
      "[&_[data-part=label][data-drag-over=before]]:before:-top-px",
      "[&_[data-part=label][data-drag-over=before]]:before:left-[var(--label-offset)]",
      "[&_[data-part=label][data-drag-over=before]]:before:right-0",
      "[&_[data-part=label][data-drag-over=before]]:before:h-0.5",
      "[&_[data-part=label][data-drag-over=before]]:before:rounded-full",
      "[&_[data-part=label][data-drag-over=before]]:before:bg-[var(--c-primary)]",
      "[&_[data-part=label][data-drag-over=after]]:after:content-['']",
      "[&_[data-part=label][data-drag-over=after]]:after:absolute",
      "[&_[data-part=label][data-drag-over=after]]:after:-bottom-px",
      "[&_[data-part=label][data-drag-over=after]]:after:left-[var(--label-offset)]",
      "[&_[data-part=label][data-drag-over=after]]:after:right-0",
      "[&_[data-part=label][data-drag-over=after]]:after:h-0.5",
      "[&_[data-part=label][data-drag-over=after]]:after:rounded-full",
      "[&_[data-part=label][data-drag-over=after]]:after:bg-[var(--c-primary)]",
      "[&_[data-part=drag-handle]]:cursor-grab [&_[data-part=drag-handle]]:opacity-40",
      "[&_[data-part=drag-handle]:hover]:opacity-100"
    ]
  end

  # Menu button: a trigger + an anchored dropdown. Rows share one [role^=menuitem] variant.
  defp menu_class do
    [
      "[&_[data-part=trigger]]:inline-flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:gap-1 [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger][data-popup-open]]:bg-[var(--c-base-200)]",
      "[&_[role=menu]]:min-w-52 [&_[role=menu]]:rounded-lg [&_[role=menu]]:border [&_[role=menu]]:border-[var(--c-base-300)] [&_[role=menu]]:bg-[var(--c-base-100)] [&_[role=menu]]:p-1 [&_[role=menu]]:text-sm [&_[role=menu]]:shadow-lg [&_[role=menu]]:outline-none [&_[role=menu]]:transition [&_[role=menu]]:duration-150 [&_[role=menu][data-starting-style]]:opacity-0 [&_[role=menu][data-starting-style]]:scale-95 [&_[role=menu]]:origin-top",
      "[&_[role^=menuitem]]:flex [&_[role^=menuitem]]:w-full [&_[role^=menuitem]]:cursor-default [&_[role^=menuitem]]:select-none [&_[role^=menuitem]]:items-center [&_[role^=menuitem]]:gap-2 [&_[role^=menuitem]]:rounded [&_[role^=menuitem]]:px-2 [&_[role^=menuitem]]:py-1.5 [&_[role^=menuitem]]:text-left [&_[role^=menuitem]]:text-[var(--c-base-content)] [&_[role^=menuitem]]:no-underline [&_[role^=menuitem]]:outline-none",
      "[&_[role^=menuitem][data-highlighted]]:bg-[var(--c-base-200)] [&_[role^=menuitem][data-disabled]]:opacity-40",
      "[&_[data-part$=indicator]]:inline-flex [&_[data-part$=indicator]]:w-4 [&_[data-part$=indicator]]:shrink-0 [&_[data-part$=indicator]]:justify-center [&_[data-part$=indicator]]:text-xs [&_[data-part$=indicator]]:text-[var(--c-primary)]",
      "[&_[data-part=submenu-chevron]]:ml-auto [&_[data-part=submenu-chevron]]:text-[var(--c-base-content)]/40",
      "[&_[data-part=separator]]:my-1 [&_[data-part=separator]]:h-px [&_[data-part=separator]]:bg-[var(--c-base-300)]",
      "[&_[data-part=group-label]]:px-2 [&_[data-part=group-label]]:py-1 [&_[data-part=group-label]]:text-xs [&_[data-part=group-label]]:font-medium [&_[data-part=group-label]]:uppercase [&_[data-part=group-label]]:tracking-wide [&_[data-part=group-label]]:text-[var(--c-base-content)]/40"
    ]
  end

  defp radio_group_class do
    [
      "w-72 space-y-2",
      "[&_[data-part=item]]:flex [&_[data-part=item]]:w-full [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded-md [&_[data-part=item]]:border [&_[data-part=item]]:border-[var(--c-base-300)] [&_[data-part=item]]:bg-[var(--c-base-100)] [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-2 [&_[data-part=item]]:text-left",
      # leading radio dot
      "[&_[data-part=item]]:before:size-4 [&_[data-part=item]]:before:shrink-0 [&_[data-part=item]]:before:rounded-full [&_[data-part=item]]:before:border [&_[data-part=item]]:before:border-[var(--c-base-300)] [&_[data-part=item]]:before:content-['']",
      "[&_[data-part=item][data-checked]]:border-[var(--c-primary)] [&_[data-part=item][data-checked]]:font-semibold [&_[data-part=item][data-checked]]:before:border-[5px] [&_[data-part=item][data-checked]]:before:border-[var(--c-primary)]",
      "[&_[data-part=item][data-highlighted]]:outline-none [&_[data-part=item][data-highlighted]]:ring-2 [&_[data-part=item][data-highlighted]]:ring-[var(--c-primary)]/40",
      "[&_[data-part=item][data-disabled]]:cursor-not-allowed [&_[data-part=item][data-disabled]]:opacity-40"
    ]
  end

  # Toolbar: heterogeneous controls with roving focus. Buttons/links/inputs are the focusable items;
  # disabled items stay focusable (just dimmed). Separators divide; groups cluster.
  defp toolbar_class do
    [
      "flex max-w-full flex-wrap items-center gap-1 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-1",
      "[&_[data-part=group]]:flex [&_[data-part=group]]:gap-1",
      "[&_[data-part=button]]:rounded [&_[data-part=button]]:px-2.5 [&_[data-part=button]]:py-1.5 [&_[data-part=button]]:text-sm [&_[data-part=button]]:outline-none [&_[data-part=button]:hover]:bg-[var(--c-base-200)] focus-visible:[&_[data-part=button]]:ring-2 focus-visible:[&_[data-part=button]]:ring-[var(--c-primary)]/40 [&_[data-part=button][data-disabled]]:opacity-40 [&_[data-part=button][data-disabled]]:cursor-not-allowed",
      "[&_[data-part=separator]]:mx-1 [&_[data-part=separator][data-orientation=horizontal]]:h-5 [&_[data-part=separator][data-orientation=horizontal]]:w-px [&_[data-part=separator][data-orientation=vertical]]:h-px [&_[data-part=separator][data-orientation=vertical]]:w-5 [&_[data-part=separator]]:bg-[var(--c-base-300)]",
      "[&_[data-part=input]]:w-24 [&_[data-part=input]]:min-w-0 [&_[data-part=input]]:rounded [&_[data-part=input]]:border [&_[data-part=input]]:border-[var(--c-base-300)] [&_[data-part=input]]:bg-[var(--c-base-100)] [&_[data-part=input]]:px-2 [&_[data-part=input]]:py-1 [&_[data-part=input]]:text-sm [&_[data-part=input]]:outline-none focus-visible:[&_[data-part=input]]:ring-2 focus-visible:[&_[data-part=input]]:ring-[var(--c-primary)]/40",
      "[&_[data-part=link]]:ml-auto [&_[data-part=link]]:px-2 [&_[data-part=link]]:text-sm [&_[data-part=link]]:text-[var(--c-primary)] [&_[data-part=link]]:underline-offset-2 [&_[data-part=link]:hover]:underline [&_[data-part=link]]:outline-none focus-visible:[&_[data-part=link]]:ring-2 focus-visible:[&_[data-part=link]]:ring-[var(--c-primary)]/40"
    ]
  end

  # Tabs: the hook publishes --active-tab-left/width on the indicator; it slides + resizes under the
  # active tab. data-active styles the selected tab, data-disabled dims it.
  defp tabs_class do
    [
      "w-full max-w-sm",
      "[&_[data-part=tablist]]:relative [&_[data-part=tablist]]:flex [&_[data-part=tablist]]:gap-1 [&_[data-part=tablist]]:border-b [&_[data-part=tablist]]:border-[var(--c-base-300)]",
      "[&_[data-part=tab]]:px-3 [&_[data-part=tab]]:py-1.5 [&_[data-part=tab]]:text-sm [&_[data-part=tab]]:text-[var(--c-base-content)]/60 [&_[data-part=tab]]:outline-none [&_[data-part=tab]]:hover:text-[var(--c-base-content)] [&_[data-part=tab][data-active]]:text-[var(--c-base-content)] [&_[data-part=tab][data-active]]:font-semibold [&_[data-part=tab][data-disabled]]:opacity-40 [&_[data-part=tab][data-disabled]]:cursor-not-allowed focus-visible:[&_[data-part=tab]]:ring-2 focus-visible:[&_[data-part=tab]]:ring-[var(--c-primary)]/40",
      "[&_[data-part=indicator]]:absolute [&_[data-part=indicator]]:-bottom-px [&_[data-part=indicator]]:left-0 [&_[data-part=indicator]]:h-0.5 [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-[var(--c-primary)] [&_[data-part=indicator]]:[width:var(--active-tab-width)] [&_[data-part=indicator]]:[translate:var(--active-tab-left)_0] [&_[data-part=indicator]]:transition-[translate,width] [&_[data-part=indicator]]:duration-200 [&_[data-part=indicator]]:ease-out",
      "[&_[data-part=panel]]:rounded-b-md [&_[data-part=panel]]:bg-[var(--c-base-100)] [&_[data-part=panel]]:p-3 [&_[data-part=panel]]:text-sm [&_[data-part=panel]]:outline-none"
    ]
  end

  # Navigation menu: a bar of links + dropdown triggers sharing one MORPHING popup. The hook moves the
  # active content into the viewport and animates --popup-width/height; the icon flips on data-open, the
  # active trigger gets data-popup-open. Positioning/morph/slide come from the base CSS.
  defp navigation_menu_class do
    [
      "flex gap-1 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-1",
      "[&_[data-part=link]]:block [&_[data-part=link]]:rounded [&_[data-part=link]]:px-3 [&_[data-part=link]]:py-1.5 [&_[data-part=link]]:text-sm [&_[data-part=link]]:hover:bg-[var(--c-base-200)] [&_[data-part=link][data-active]]:font-semibold",
      "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:gap-1 [&_[data-part=trigger]]:rounded [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:hover:bg-[var(--c-base-200)] [&_[data-part=trigger][data-popup-open]]:bg-[var(--c-base-200)]",
      "[&_[data-part=icon]]:text-[0.6rem] [&_[data-part=icon]]:transition-transform [&_[data-part=icon][data-open]]:rotate-180",
      "[&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-[var(--c-base-300)] [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:shadow-lg",
      "[&_[data-part=content]_a]:block [&_[data-part=content]_a]:rounded [&_[data-part=content]_a]:px-3 [&_[data-part=content]_a]:py-1.5 [&_[data-part=content]_a]:text-sm [&_[data-part=content]_a]:hover:bg-[var(--c-base-200)]",
      "[&_[data-part=arrow]]:absolute [&_[data-part=arrow]]:-top-1 [&_[data-part=arrow]]:-ml-1.5 [&_[data-part=arrow]]:size-2.5 [&_[data-part=arrow]]:rotate-45 [&_[data-part=arrow]]:border-l [&_[data-part=arrow]]:border-t [&_[data-part=arrow]]:border-[var(--c-base-300)] [&_[data-part=arrow]]:bg-[var(--c-base-100)]"
    ]
  end

  # Scroll area: the hook hides the native scrollbar and drives the custom scrollbar/thumb. The
  # scrollbar overlays the edge and fades in on data-hovering / data-scrolling (Base UI); the thumb is
  # sized by --scroll-area-thumb-* (base CSS) and positioned by the hook.
  defp scroll_area_class do
    [
      "h-48 w-72 rounded-md border border-[var(--c-base-300)]",
      "[&_[data-part=viewport]]:p-3 [&_[data-part=viewport]]:focus:outline-none",
      "[&_[data-part=scrollbar]]:flex [&_[data-part=scrollbar]]:justify-center [&_[data-part=scrollbar]]:bg-[var(--c-base-200)]/70 [&_[data-part=scrollbar]]:opacity-0 [&_[data-part=scrollbar]]:transition-opacity [&_[data-part=scrollbar][data-hovering]]:opacity-100 [&_[data-part=scrollbar][data-scrolling]]:opacity-100",
      "[&_[data-part=scrollbar][data-orientation=vertical]]:w-2.5 [&_[data-part=scrollbar][data-orientation=horizontal]]:h-2.5 [&_[data-part=scrollbar][data-orientation=horizontal]]:flex-col",
      "[&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:bg-[var(--c-base-content)]/40 hover:[&_[data-part=thumb]]:bg-[var(--c-base-content)]/60",
      "[&_[data-part=thumb][data-orientation=vertical]]:w-full [&_[data-part=thumb][data-orientation=horizontal]]:h-full",
      "[&_[data-part=corner]]:bg-[var(--c-base-200)]/70"
    ]
  end

  # Scroll-fade: a top/bottom mask keyed off the px distance from each edge the hook publishes.
  defp scroll_fade do
    "[&_[data-part=viewport]]:[mask-image:linear-gradient(to_bottom,transparent_0,black_min(2rem,var(--scroll-area-overflow-y-start,0))," <>
      "black_calc(100%-min(2rem,var(--scroll-area-overflow-y-end,0))),transparent_100%)]"
  end

  # Avatar: the hook owns visibility (image `hidden` until loaded; fallback inline display), so these
  # classes only style appearance — no `:has` hiding needed.
  defp avatar_class do
    [
      "relative inline-flex size-12 items-center justify-center overflow-hidden rounded-full border border-[var(--c-base-300)] bg-[var(--c-base-200)] text-sm font-semibold text-[var(--c-base-content)]",
      "[&_[data-part=image]]:size-full [&_[data-part=image]]:object-cover",
      "[&_[data-part=fallback]]:absolute [&_[data-part=fallback]]:inset-0 [&_[data-part=fallback]]:flex [&_[data-part=fallback]]:items-center [&_[data-part=fallback]]:justify-center"
    ]
  end

  # Empty state: a centered column — indicator (circle), title, description, then actions. data-align
  # flips it to start/end (incl. the actions row). Appearance only; the component ships no layout.
  defp empty_state_class do
    [
      "flex max-w-xs flex-col items-center gap-3 text-center",
      "[&[data-align=left]]:items-start [&[data-align=left]]:text-left [&[data-align=right]]:items-end [&[data-align=right]]:text-right",
      "[&_[data-part=indicator]]:flex [&_[data-part=indicator]]:size-12 [&_[data-part=indicator]]:items-center [&_[data-part=indicator]]:justify-center [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-[var(--c-base-200)] [&_[data-part=indicator]]:text-[var(--c-base-content)]/60",
      "[&_[data-part=body]]:flex [&_[data-part=body]]:flex-col [&_[data-part=body]]:gap-1",
      "[&_[data-part=title]]:text-sm [&_[data-part=title]]:font-semibold",
      "[&_[data-part=description]]:text-xs [&_[data-part=description]]:text-[var(--c-base-content)]/60",
      "[&_[data-part=actions]]:mt-2 [&_[data-part=actions]]:flex [&_[data-part=actions]]:justify-center [&_[data-part=actions]]:gap-2 [&[data-align=left]_[data-part=actions]]:justify-start [&[data-align=right]_[data-part=actions]]:justify-end"
    ]
  end

  # Empty state, "filled" variant: a tinted circular indicator (Mantine's filled/light look). Only the
  # indicator background/color differs from empty_state_class.
  defp empty_state_filled_class do
    [
      "flex max-w-xs flex-col items-center gap-3 text-center",
      "[&_[data-part=indicator]]:flex [&_[data-part=indicator]]:size-12 [&_[data-part=indicator]]:items-center [&_[data-part=indicator]]:justify-center [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-[var(--c-primary)]/15 [&_[data-part=indicator]]:text-[var(--c-primary)]",
      "[&_[data-part=body]]:flex [&_[data-part=body]]:flex-col [&_[data-part=body]]:gap-1",
      "[&_[data-part=title]]:text-sm [&_[data-part=title]]:font-semibold",
      "[&_[data-part=description]]:text-xs [&_[data-part=description]]:text-[var(--c-base-content)]/60"
    ]
  end

  # Toggle group: a row (or column, data-orientation=vertical) of pressed buttons. data-pressed is the
  # selected look; data-disabled dims the group/item. The hook owns roving focus + selection.
  defp toggle_group_class do
    [
      "inline-flex gap-1 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-1 data-[orientation=vertical]:flex-col data-[disabled]:opacity-60",
      "[&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:text-[var(--c-base-content)] [&_[data-part=item]]:transition-colors [&_[data-part=item]]:outline-none",
      "[&_[data-part=item]]:not-data-disabled:hover:bg-[var(--c-base-200)]",
      "[&_[data-part=item][data-pressed]]:bg-[var(--c-base-content)] [&_[data-part=item][data-pressed]]:text-[var(--c-base-100)]",
      "[&_[data-part=item]]:focus-visible:ring-2 [&_[data-part=item]]:focus-visible:ring-[var(--c-primary)]/40",
      "[&_[data-part=item][data-disabled]]:opacity-40 [&_[data-part=item][data-disabled]]:cursor-not-allowed"
    ]
  end

  # Toggle: a pressed-state button. Base UI exposes only data-pressed (present when on), so the "off"
  # look is the base style and data-[pressed]: is the on look. data-disabled dims + blocks.
  defp toggle_class do
    [
      "inline-flex items-center gap-2 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5 text-sm transition-colors",
      "data-[pressed]:border-[var(--c-primary)] data-[pressed]:bg-[var(--c-primary)] data-[pressed]:text-primary-content",
      "data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--c-primary)]/40"
    ]
  end

  # Switch: the root button IS the track; the thumb is the knob and slides on its OWN data-checked
  # (Base UI style). Presence selectors ([data-checked], not =true) match the bare attrs the server
  # renders and the Toggle hook toggles. data-disabled/-readonly dim/lock.
  defp switch_class do
    [
      "group inline-flex items-center gap-3 cursor-pointer focus-visible:outline-none [&[data-disabled]]:cursor-not-allowed [&[data-disabled]]:opacity-50 [&[data-readonly]]:cursor-default",
      "[&_[data-part=track]]:inline-flex [&_[data-part=track]]:h-6 [&_[data-part=track]]:w-11 [&_[data-part=track]]:shrink-0 [&_[data-part=track]]:items-center [&_[data-part=track]]:rounded-full [&_[data-part=track]]:border [&_[data-part=track]]:border-[var(--c-base-300)] [&_[data-part=track]]:p-0.5 [&_[data-part=track]]:transition-colors",
      "[&_[data-part=track][data-checked]]:bg-[var(--c-primary)] [&_[data-part=track][data-unchecked]]:bg-[var(--c-base-300)]",
      "[&:focus-visible_[data-part=track]]:ring-2 [&:focus-visible_[data-part=track]]:ring-[var(--c-primary)]/40",
      "[&_[data-part=thumb]]:block [&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:bg-[var(--c-base-100)] [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:transition-transform [&_[data-part=thumb][data-checked]]:translate-x-5"
    ]
  end

  # Slider: the hook owns all positioning of the indicator + thumbs (like Base UI); these classes only
  # size/colour the control + track (orientation-aware) and style the indicator/thumb appearance.
  defp slider_class do
    [
      "inline-block [&[data-disabled]]:opacity-50",
      "[&_[data-part=value]]:mb-1 [&_[data-part=value]]:block [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-[var(--c-base-content)]/70",
      "[&_[data-part=control]]:flex [&_[data-part=control]]:touch-none [&_[data-part=control]]:select-none [&_[data-part=control][data-orientation=horizontal]]:w-56 [&_[data-part=control][data-orientation=horizontal]]:items-center [&_[data-part=control][data-orientation=horizontal]]:py-3 [&_[data-part=control][data-orientation=vertical]]:h-40 [&_[data-part=control][data-orientation=vertical]]:justify-center [&_[data-part=control][data-orientation=vertical]]:px-3",
      "[&_[data-part=track]]:relative [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-[var(--c-base-300)] [&_[data-part=track][data-orientation=horizontal]]:h-1.5 [&_[data-part=track][data-orientation=horizontal]]:w-full [&_[data-part=track][data-orientation=vertical]]:w-1.5 [&_[data-part=track][data-orientation=vertical]]:h-full",
      "[&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-[var(--c-primary)]",
      "[&_[data-part=thumb]]:block [&_[data-part=thumb]]:size-4 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border [&_[data-part=thumb]]:border-[var(--c-base-300)] [&_[data-part=thumb]]:bg-[var(--c-base-100)] [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:cursor-grab [&_[data-part=thumb]]:outline-none focus:[&_[data-part=thumb]]:ring-2 focus:[&_[data-part=thumb]]:ring-[var(--c-primary)]",
      "[&_[data-part=thumb][data-dragging]]:cursor-grabbing"
    ]
  end

  # Select: a trigger button + an absolutely-positioned listbox. data-placeholder dims the empty
  # value; data-highlighted = keyboard/hover row; data-selected shows the ✓ and bolds; the icon flips
  # on data-popup-open; disabled options dim. The indicator is hidden until the item is selected.
  defp select_class do
    [
      "relative inline-block",
      "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:min-w-52 [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-2 [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-[var(--c-base-300)] [&_[data-part=trigger]]:bg-[var(--c-base-100)] [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-left [&_[data-part=trigger][data-disabled]]:opacity-50",
      "[&_[data-part=value][data-placeholder]]:text-[var(--c-base-content)]/40",
      "[&_[data-part=icon]]:text-[var(--c-base-content)]/50 [&_[data-part=icon]]:transition-transform [&_[data-part=icon][data-popup-open]]:rotate-180",
      "[&_[data-part=positioner]]:relative",
      "[&_[data-part=popup]]:absolute [&_[data-part=popup]]:left-0 [&_[data-part=popup]]:right-0 [&_[data-part=popup]]:top-full [&_[data-part=popup]]:z-10 [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:max-h-60 [&_[data-part=popup]]:overflow-auto [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-[var(--c-base-300)] [&_[data-part=popup]]:bg-[var(--c-base-100)] [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup][data-closed]]:hidden",
      "[&_[data-part=group-label]]:block [&_[data-part=group-label]]:px-2 [&_[data-part=group-label]]:pb-1 [&_[data-part=group-label]]:pt-2 [&_[data-part=group-label]]:text-xs [&_[data-part=group-label]]:font-medium [&_[data-part=group-label]]:uppercase [&_[data-part=group-label]]:tracking-wide [&_[data-part=group-label]]:text-[var(--c-base-content)]/40",
      "[&_[data-part=item]]:flex [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded [&_[data-part=item]]:px-2 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:outline-none [&_[data-part=item][data-highlighted]]:bg-[var(--c-base-200)] [&_[data-part=item][data-selected]]:font-semibold [&_[data-part=item][data-disabled]]:cursor-not-allowed [&_[data-part=item][data-disabled]]:opacity-40",
      "[&_[data-part=item-indicator]]:w-4 [&_[data-part=item-indicator]]:shrink-0 [&_[data-part=item-indicator]]:text-xs [&_[data-part=item-indicator]]:opacity-0 [&_[data-part=item][data-selected]_[data-part=item-indicator]]:opacity-100"
    ]
  end

  # Base-UI-style radio: a ring that fills with a dot when the root carries data-checked (set live by
  # the Radio hook). Hides the native input; disabled dims the row.
  defp radio_class do
    [
      "inline-flex cursor-pointer items-center gap-2 [&[data-disabled]]:cursor-not-allowed [&[data-disabled]]:opacity-50",
      "[&_[data-part=input]]:sr-only",
      "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-4 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-[var(--c-base-300)] [&_[data-part=indicator]]:bg-[var(--c-base-100)]",
      "[&_[data-part=indicator][data-checked]]:border-[var(--c-primary)] [&_[data-part=indicator][data-checked]]:after:size-2 [&_[data-part=indicator][data-checked]]:after:rounded-full [&_[data-part=indicator][data-checked]]:after:bg-[var(--c-primary)] [&_[data-part=indicator][data-checked]]:after:content-['']",
      "[&_[data-part=label]]:text-sm [&[data-checked]_[data-part=label]]:font-medium"
    ]
  end

  defp otp_field_class do
    [
      "flex items-center gap-2",
      "[&_[data-part=input]]:size-10 [&_[data-part=input]]:rounded-md [&_[data-part=input]]:border [&_[data-part=input]]:border-[var(--c-base-300)] [&_[data-part=input]]:bg-[var(--c-base-100)] [&_[data-part=input]]:text-center [&_[data-part=input]]:text-lg [&_[data-part=input]]:tabular-nums [&_[data-part=input]]:outline-none",
      "[&_[data-part=input]:focus]:border-[var(--c-primary)] [&_[data-part=input]:focus]:ring-2 [&_[data-part=input]:focus]:ring-[var(--c-primary)]/30",
      "[&_[data-part=input][data-filled]]:border-[var(--c-base-content)]/40",
      # the engine sets data-complete on the root when every slot is filled
      "[&[data-complete]_[data-part=input]]:border-[var(--c-success)]",
      "[&_[data-part=separator]]:text-lg [&_[data-part=separator]]:text-[var(--c-base-content)]/40",
      "[&[data-disabled]]:opacity-60"
    ]
  end

  defp number_field_class do
    [
      "inline-flex items-center rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)]",
      "[&_[data-part=decrement]]:px-3 [&_[data-part=decrement]]:py-1.5 [&_[data-part=decrement]]:text-lg [&_[data-part=decrement]]:leading-none [&_[data-part=decrement]]:hover:bg-[var(--c-base-200)] [&_[data-part=decrement]:disabled]:opacity-40",
      "[&_[data-part=increment]]:px-3 [&_[data-part=increment]]:py-1.5 [&_[data-part=increment]]:text-lg [&_[data-part=increment]]:leading-none [&_[data-part=increment]]:hover:bg-[var(--c-base-200)] [&_[data-part=increment]:disabled]:opacity-40",
      "[&_[data-part=input]]:w-28 [&_[data-part=input]]:border-x [&_[data-part=input]]:border-[var(--c-base-300)] [&_[data-part=input]]:bg-[var(--c-base-100)] [&_[data-part=input]]:px-2 [&_[data-part=input]]:py-1.5 [&_[data-part=input]]:text-center [&_[data-part=input]]:tabular-nums [&_[data-part=input]]:outline-none [&_[data-part=input]]:focus:bg-[var(--c-base-200)]/40",
      "[&[data-disabled]]:opacity-60 [&[data-readonly]_[data-part=input]]:cursor-default"
    ]
  end

  defp scrub_number_class do
    [
      "inline-flex items-center gap-2 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-3 py-1.5",
      "[&_[data-part=scrub-area]]:cursor-ew-resize [&_[data-part=scrub-area]]:select-none [&_[data-part=scrub-area]]:text-sm [&_[data-part=scrub-area]]:font-medium [&_[data-part=scrub-area]]:text-[var(--c-base-content)]/70",
      "[&_[data-part=input]]:w-16 [&_[data-part=input]]:bg-transparent [&_[data-part=input]]:text-center [&_[data-part=input]]:tabular-nums [&_[data-part=input]]:outline-none",
      "[&[data-scrubbing]]:ring-2 [&[data-scrubbing]]:ring-[var(--c-primary)]/40"
    ]
  end

  defp fieldset_demo_class do
    [
      "w-80 rounded-md border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4",
      # the legend is a styleable <div> (not a native <legend>) — give it a header look
      "[&_[data-part=legend]]:mb-3 [&_[data-part=legend]]:border-b [&_[data-part=legend]]:border-[var(--c-base-300)] [&_[data-part=legend]]:pb-1.5 [&_[data-part=legend]]:text-sm [&_[data-part=legend]]:font-semibold",
      # dim the whole group when disabled (native disabled greys the controls themselves)
      "[&[data-disabled]]:opacity-60"
    ]
  end

  defp field_state_class do
    [
      "[&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium",
      "[&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-xs [&_[data-part=description]]:text-[var(--c-base-content)]/60",
      "[&_[data-part=error]]:mt-1 [&_[data-part=error]]:text-xs [&_[data-part=error]]:text-[var(--c-error)]",
      "[&[data-invalid]_input]:border-[var(--c-error)]",
      "[&[data-valid]_input]:border-[var(--c-success)]",
      "[&[data-valid]_[data-part=label]]:after:content-['_✓'] [&[data-valid]_[data-part=label]]:after:text-[var(--c-success)]",
      "[&[data-focused]_input]:ring-2 [&[data-focused]_input]:ring-[var(--c-primary)]/30",
      "[&[data-filled]_[data-part=label]]:text-[var(--c-primary)]",
      "[&[data-disabled]]:opacity-60"
    ]
  end
end
