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
  import DevelopmentWeb.Components.Headless.Collapsible
  import DevelopmentWeb.Components.Headless.Combobox
  import DevelopmentWeb.Components.Headless.ContextMenu
  import DevelopmentWeb.Components.Headless.Dialog
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
  import DevelopmentWeb.Components.Headless.Drawer
  import DevelopmentWeb.Components.Headless.Radio
  import DevelopmentWeb.Components.Headless.OtpField
  import DevelopmentWeb.Showcase.UI, only: [code_block: 1]

  @btn "rounded-md border border-base-300 px-3 py-1.5 text-sm"

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
      "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-base-300 [&_[data-part=indicator]]:bg-base-100 [&_[data-part=indicator]]:text-xs [&_[data-part=indicator]]:leading-none [&_[data-part=indicator]]:text-base-100 " <>
      "[&_[data-part=indicator][data-checked]]:border-base-content [&_[data-part=indicator][data-checked]]:bg-base-content [&_[data-part=indicator][data-checked]]:after:content-['✓'] " <>
      "[&_[data-part=indicator][data-indeterminate]]:border-base-content [&_[data-part=indicator][data-indeterminate]]:bg-base-content [&_[data-part=indicator][data-indeterminate]]:after:content-['–'] " <>
      "[&_[data-part=label]]:text-sm"
  end

  # The group: a bordered card; each item is a Base-UI checkbox row (box ✓ / dash via the indicator),
  # with the select_all parent set apart by a divider.
  defp checkbox_group_class do
    "flex w-64 flex-col gap-0.5 rounded-md border border-base-300 p-3 " <>
      "[&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-semibold " <>
      "[&_[data-part=item]]:flex [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded [&_[data-part=item]]:px-2 [&_[data-part=item]]:py-1 [&_[data-part=item]]:text-sm [&_[data-part=item]:hover]:bg-base-200 [&_[data-part=item][data-disabled]]:cursor-not-allowed [&_[data-part=item][data-disabled]]:opacity-50 " <>
      "[&_[data-part=item][data-parent]]:mb-1 [&_[data-part=item][data-parent]]:border-b [&_[data-part=item][data-parent]]:border-base-300 [&_[data-part=item][data-parent]]:pb-1.5 [&_[data-part=item][data-parent]]:font-medium " <>
      "[&_[data-part=indicator]]:grid [&_[data-part=indicator]]:size-5 [&_[data-part=indicator]]:shrink-0 [&_[data-part=indicator]]:place-items-center [&_[data-part=indicator]]:rounded [&_[data-part=indicator]]:border [&_[data-part=indicator]]:border-base-300 [&_[data-part=indicator]]:bg-base-100 [&_[data-part=indicator]]:text-xs [&_[data-part=indicator]]:leading-none [&_[data-part=indicator]]:text-base-100 " <>
      "[&_[data-part=indicator][data-checked]]:border-base-content [&_[data-part=indicator][data-checked]]:bg-base-content [&_[data-part=indicator][data-checked]]:after:content-['✓'] " <>
      "[&_[data-part=indicator][data-indeterminate]]:border-base-content [&_[data-part=indicator][data-indeterminate]]:bg-base-content [&_[data-part=indicator][data-indeterminate]]:after:content-['–']"
  end

  def show(%{component: "drawer"} = assigns) do
    ~H"""
    <.drawer
      id={@id}
      side="right"
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=backdrop]]:bg-black/40 [&_[data-part=popup]]:fixed [&_[data-part=popup]]:right-0 [&_[data-part=popup]]:top-0 [&_[data-part=popup]]:h-full [&_[data-part=popup]]:w-72 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl [&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold"
    >
      <:trigger>Open drawer</:trigger>
      <:title>Filters</:title>
      <:description>A focus-trapped panel that slides in from the edge.</:description>
      <p class="mt-2 text-sm">Drawer body — same behavior as dialog, with a side.</p>
      <:close>
        <button class="rounded-md border border-base-300 px-3 py-1.5 text-sm" data-close>
          Close
        </button>
      </:close>
    </.drawer>
    """
  end

  def show(%{component: "radio"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.radio
        :for={{label, v} <- [{"Email", "email"}, {"SMS", "sms"}, {"Push", "push"}]}
        id={"#{@id}-#{v}"}
        name="notify"
        value={v}
        checked={v == "email"}
        class="inline-flex cursor-pointer items-center gap-2 [&_input]:size-4"
      >
        {label}
      </.radio>
    </div>
    """
  end

  def show(%{component: "otp_field"} = assigns) do
    ~H"""
    <.otp_field
      id={@id}
      name="code"
      length={6}
      class="flex gap-2 [&_[data-part=input]]:size-10 [&_[data-part=input]]:rounded-md [&_[data-part=input]]:border [&_[data-part=input]]:border-base-300 [&_[data-part=input]]:text-center [&_[data-part=input]]:text-lg"
    />
    """
  end

  def show(%{component: "accordion"} = assigns) do
    ~H"""
    <.accordion
      id={@id}
      class={
        [
          "w-80 divide-y divide-base-300 rounded-md border border-base-300",
          # trigger: full-width header with a chevron that flips via data-panel-open
          "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-3 [&_[data-part=trigger]]:p-3 [&_[data-part=trigger]]:text-left [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:outline-none focus-visible:[&_[data-part=trigger]]:bg-base-200",
          "[&_[data-part=trigger][data-disabled]]:cursor-not-allowed [&_[data-part=trigger][data-disabled]]:opacity-40",
          "[&_[data-part=trigger]]:after:content-['▾'] [&_[data-part=trigger]]:after:text-base-content/40 [&_[data-part=trigger]]:after:transition-transform [&_[data-part=trigger][data-panel-open]]:after:rotate-180",
          # panel is a PURE height-animated wrapper — NO padding on it (padding goes on the inner
          # content), else box-border + height:0 can't collapse past the padding and the transition breaks
          "[&_[data-part=panel]]:box-border [&_[data-part=panel]]:h-[var(--accordion-panel-height)] [&_[data-part=panel]]:overflow-hidden [&_[data-part=panel]]:transition-[height] [&_[data-part=panel]]:duration-200 [&_[data-part=panel]]:ease-out",
          "[&_[data-part=panel][data-starting-style]]:h-0 [&_[data-part=panel][data-ending-style]]:h-0"
        ]
      }
    >
      <:item title="What is a headless component?" open>
        <div class="px-3 pb-3 text-sm text-base-content/70">
          It ships behavior, ARIA wiring, and keyboard support — but no styling. You bring the classes.
        </div>
      </:item>
      <:item title="How does keyboard navigation work?">
        <div class="px-3 pb-3 text-sm text-base-content/70">
          Arrow keys move focus between headers, Home/End jump to the ends, Enter/Space toggles.
        </div>
      </:item>
      <:item title="This header is disabled" disabled>
        <div class="px-3 pb-3 text-sm text-base-content/70">
          Disabled headers are skipped by arrow-key navigation and can't be toggled.
        </div>
      </:item>
      <:item title="Can panels animate?">
        <div class="px-3 pb-3 text-sm text-base-content/70">
          Yes — the panel exposes <code>--accordion-panel-height</code>
          plus <code>data-starting-style</code>/<code>data-ending-style</code> so your CSS transitions height.
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
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=backdrop]]:bg-black/40 [&_[data-part=popup]]:w-80 [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl [&_[data-part=title]]:text-lg [&_[data-part=title]]:font-semibold [&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-base-content/70 [&_[data-part=actions]]:mt-4 [&_[data-part=actions]]:flex [&_[data-part=actions]]:justify-end [&_[data-part=actions]]:gap-2"
    >
      <:trigger>Delete account</:trigger>
      <:title>Delete account?</:title>
      <:description>This permanently removes your account and cannot be undone.</:description>
      <:actions>
        <button class={@btn} data-close>Cancel</button>
        <button class={[@btn, "bg-error text-error-content"]} data-close>Delete</button>
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
      class={
        [
          "relative w-64",
          "[&_[data-part=input]]:w-full [&_[data-part=input]]:rounded-md [&_[data-part=input]]:border [&_[data-part=input]]:border-base-300 [&_[data-part=input]]:px-3 [&_[data-part=input]]:py-1.5 [&_[data-part=input]]:pr-8",
          "[&_[data-part=clear]]:absolute [&_[data-part=clear]]:right-2 [&_[data-part=clear]]:top-1.5 [&_[data-part=clear]]:text-base-content/40 [&_[data-part=clear]]:hover:text-base-content [&_[data-part=clear][data-hidden]]:hidden",
          "[&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:max-h-56 [&_[data-part=popup]]:w-64 [&_[data-part=popup]]:overflow-auto [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg",
          "[&_[data-part=group-label]]:block [&_[data-part=group-label]]:px-3 [&_[data-part=group-label]]:pb-1 [&_[data-part=group-label]]:pt-2 [&_[data-part=group-label]]:text-xs [&_[data-part=group-label]]:font-medium [&_[data-part=group-label]]:uppercase [&_[data-part=group-label]]:tracking-wide [&_[data-part=group-label]]:text-base-content/40",
          "[&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item][data-highlighted]]:bg-base-200 [&_[data-part=item][aria-selected=true]]:font-semibold",
          "[&_[data-part=empty]]:px-3 [&_[data-part=empty]]:py-2 [&_[data-part=empty]]:text-sm [&_[data-part=empty]]:text-base-content/50"
        ]
      }
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
    <.avatar
      id={@id}
      src="https://avatars.githubusercontent.com/u/8722951?v=4"
      alt="User avatar"
      class="relative inline-flex h-12 w-12 items-center justify-center overflow-hidden rounded-full border border-base-300 bg-base-200 text-sm font-semibold text-base-content [&_[data-part=image]]:h-full [&_[data-part=image]]:w-full [&_[data-part=image]]:object-cover [&_[data-part=fallback]]:absolute [&_[data-part=fallback]]:inset-0 [&_[data-part=fallback]]:flex [&_[data-part=fallback]]:items-center [&_[data-part=fallback]]:justify-center [&:has([data-part=image])_[data-part=fallback]]:hidden"
    >
      MC
    </.avatar>
    """
  end

  def show(%{component: "checkbox"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.checkbox id={@id} name="terms" value="accepted" checked class={checkbox_class()}>
        I agree to the terms and conditions
      </.checkbox>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-base-content/40">
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
        <p class="text-[0.7rem] uppercase tracking-wide text-base-content/40">
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
        <p class="text-[0.7rem] uppercase tracking-wide text-base-content/40">
          Nested parents — each reflects + toggles its whole subtree
        </p>
        <div
          id={"#{@id}-tree"}
          phx-hook="CheckboxGroup"
          role="group"
          aria-label="User permissions"
          class="flex w-72 flex-col gap-1.5 rounded-md border border-base-300 p-3 [&_[data-part=children]]:ml-6 [&_[data-part=children]]:mt-1.5 [&_[data-part=children]]:flex [&_[data-part=children]]:flex-col [&_[data-part=children]]:gap-1.5"
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
          "[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:w-full [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-between [&_[data-part=trigger]]:gap-3 [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-left [&_[data-part=trigger]]:font-medium",
          "[&_[data-part=trigger]]:after:content-['▾'] [&_[data-part=trigger]]:after:text-base-content/40 [&_[data-part=trigger]]:after:transition-transform [&_[data-part=trigger][data-panel-open]]:after:rotate-180",
          # panel is a PURE height-animated wrapper — padding/borders live on the inner card, else
          # box-border + height:0 can't collapse past the padding and the transition breaks
          "[&_[data-part=panel]]:box-border [&_[data-part=panel]]:h-[var(--accordion-panel-height)] [&_[data-part=panel]]:overflow-hidden [&_[data-part=panel]]:transition-[height] [&_[data-part=panel]]:duration-200 [&_[data-part=panel]]:ease-out",
          "[&_[data-part=panel][data-starting-style]]:h-0 [&_[data-part=panel][data-ending-style]]:h-0"
        ]
      }
    >
      <:trigger>Shipping details</:trigger>
      <div class="mt-2 rounded-md border border-base-300 bg-base-100 p-3 text-sm">
        <p>Orders ship within 2 business days via standard carrier.</p>
        <p class="mt-2 text-base-content/60">Tracking is emailed once the label is created.</p>
      </div>
    </.collapsible>
    """
  end

  def show(%{component: "combobox"} = assigns) do
    ~H"""
    <.combobox
      id={@id}
      name="fruit"
      value="Banana"
      placeholder="Search fruit…"
      class="[&_[data-part=input]]:min-w-56 [&_[data-part=input]]:rounded-md [&_[data-part=input]]:border [&_[data-part=input]]:border-base-300 [&_[data-part=input]]:px-3 [&_[data-part=input]]:py-1.5 [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:min-w-56 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item][data-hidden]]:hidden [&_[data-highlighted]]:bg-base-200 [&_[aria-selected=true]]:font-semibold"
    >
      <:option value="Apple">Apple</:option>
      <:option value="Banana">Banana</:option>
      <:option value="Cherry">Cherry</:option>
    </.combobox>
    """
  end

  def show(%{component: "context_menu"} = assigns) do
    ~H"""
    <.context_menu
      id={@id}
      class="[&_[data-part=trigger]]:flex [&_[data-part=trigger]]:h-32 [&_[data-part=trigger]]:w-72 [&_[data-part=trigger]]:items-center [&_[data-part=trigger]]:justify-center [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-dashed [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:text-base-content/60 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[role=menuitem]]:block [&_[role=menuitem]]:w-full [&_[role=menuitem]]:px-3 [&_[role=menuitem]]:py-1.5 [&_[role=menuitem]]:text-left [&_[data-highlighted]]:bg-base-200 [&_[data-disabled]]:opacity-50"
    >
      <:trigger>Right-click inside this area</:trigger>
      <:item>Cut</:item>
      <:item>Copy</:item>
      <:item>Paste</:item>
      <:item disabled>Delete</:item>
    </.context_menu>
    """
  end

  def show(%{component: "dialog"} = assigns) do
    ~H"""
    <.dialog
      id={@id}
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=backdrop]]:bg-black/40 [&_[data-part=popup]]:w-80 [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-6 [&_[data-part=popup]]:shadow-xl [&_[data-part=title]]:text-base [&_[data-part=title]]:font-semibold [&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-sm [&_[data-part=description]]:text-base-content/70 [&_[data-part=footer]]:mt-4 [&_[data-part=footer]]:flex [&_[data-part=footer]]:justify-end [&_[data-part=footer]]:gap-2"
    >
      <:trigger>Open dialog</:trigger>
      <:title>Confirm action</:title>
      <:description>This is a fully headless, focus-trapped dialog.</:description>
      <p class="mt-3 text-sm">
        Tab cycles inside; Escape, the backdrop, or the close button dismiss it.
      </p>
      <:close>
        <button type="button" class="rounded-md border border-base-300 px-3 py-1.5 text-sm" data-close>
          Cancel
        </button>
        <button
          type="button"
          class="rounded-md bg-base-content px-3 py-1.5 text-sm text-base-100"
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
      id={@id}
      for={"#{@id}-email"}
      label="Email address"
      errors={["Email is required", "Must be a valid address"]}
      class="w-80 [&_[data-part=label]]:mb-1 [&_[data-part=label]]:block [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=description]]:mt-1 [&_[data-part=description]]:text-xs [&_[data-part=description]]:text-base-content/60 [&_[data-part=error]]:mt-1 [&_[data-part=error]]:text-xs [&_[data-part=error]]:text-error"
    >
      <input
        id={"#{@id}-email"}
        type="email"
        name="email"
        placeholder="you@example.com"
        aria-describedby={"#{@id}-desc"}
        class="w-full rounded-md border border-base-300 bg-base-100 px-3 py-1.5 text-sm"
      />
      <:description>We'll only use this to send account notifications.</:description>
    </.field>
    """
  end

  def show(%{component: "fieldset"} = assigns) do
    ~H"""
    <.fieldset
      id={@id}
      class="w-80 rounded-md border border-base-300 bg-base-100 p-4 [&_[data-part=legend]]:px-1 [&_[data-part=legend]]:text-sm [&_[data-part=legend]]:font-semibold"
    >
      <:legend>Shipping address</:legend>
      <div class="mt-2 space-y-3">
        <label class="block text-sm">
          <span class="mb-1 block text-base-content/70">Street</span>
          <input
            type="text"
            name="street"
            value="123 Main St"
            class="w-full rounded-md border border-base-300 px-3 py-1.5"
          />
        </label>
        <label class="block text-sm">
          <span class="mb-1 block text-base-content/70">City</span>
          <input
            type="text"
            name="city"
            value="Springfield"
            class="w-full rounded-md border border-base-300 px-3 py-1.5"
          />
        </label>
        <label class="block text-sm">
          <span class="mb-1 block text-base-content/70">Postal code</span>
          <input
            type="text"
            name="zip"
            value="12345"
            class="w-full rounded-md border border-base-300 px-3 py-1.5"
          />
        </label>
      </div>
    </.fieldset>
    """
  end

  def show(%{component: "menu"} = assigns) do
    ~H"""
    <.menu
      id={@id}
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=popup]]:mt-2 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[role=menuitem]]:block [&_[role=menuitem]]:w-full [&_[role=menuitem]]:px-3 [&_[role=menuitem]]:py-1.5 [&_[role=menuitem]]:text-left [&_[data-highlighted]]:bg-base-200 [&_[data-disabled]]:opacity-50"
    >
      <:trigger>Options ▾</:trigger>
      <:item>Edit</:item>
      <:item>Duplicate</:item>
      <:item separator />
      <:item disabled>Archive</:item>
      <:submenu label="Share ▸">
        <button
          type="button"
          role="menuitem"
          data-part="item"
          tabindex="-1"
          class="block w-full px-3 py-1.5 text-left hover:bg-base-200"
        >
          Copy link
        </button>
        <button
          type="button"
          role="menuitem"
          data-part="item"
          tabindex="-1"
          class="block w-full px-3 py-1.5 text-left hover:bg-base-200"
        >
          Email
        </button>
      </:submenu>
    </.menu>
    """
  end

  def show(%{component: "menubar"} = assigns) do
    ~H"""
    <.menubar
      id={@id}
      class="inline-flex gap-1 rounded-md border border-base-300 bg-base-100 p-1 [&_[data-part=trigger]]:rounded [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger][aria-expanded=true]]:bg-base-200 [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[role=menuitem]]:block [&_[role=menuitem]]:w-full [&_[role=menuitem]]:rounded [&_[role=menuitem]]:px-3 [&_[role=menuitem]]:py-1.5 [&_[role=menuitem]]:text-left [&_[role=menuitem]]:text-sm [&_[data-highlighted]]:bg-base-200"
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
    </.menubar>
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
      class="flex w-72 flex-wrap items-center [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=value]]:ml-auto [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-base-content/60 [&_[data-part=track]]:mt-1.5 [&_[data-part=track]]:h-3 [&_[data-part=track]]:w-full [&_[data-part=track]]:overflow-hidden [&_[data-part=track]]:rounded-full [&_[data-part=track]]:border [&_[data-part=track]]:border-base-300 [&_[data-part=track]]:bg-base-200 [&_[data-part=indicator]]:h-full [&_[data-part=indicator]]:bg-primary [&_[data-part=indicator]]:[width:calc(var(--chelekom-meter)*100%)]"
    />
    """
  end

  def show(%{component: "navigation_menu"} = assigns) do
    ~H"""
    <.navigation_menu
      id={@id}
      class="flex gap-1 rounded-md border border-base-300 bg-base-100 p-1 [&_[data-part=link]]:block [&_[data-part=link]]:rounded [&_[data-part=link]]:px-3 [&_[data-part=link]]:py-1.5 [&_[data-part=link]]:text-sm [&_[data-part=link]]:hover:bg-base-200 [&_[data-part=trigger]]:rounded [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:hover:bg-base-200 [&_[data-part=popup]]:mt-2 [&_[data-part=popup]]:min-w-48 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-2 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup][data-closed]]:hidden [&_[data-part=popup]_a]:block [&_[data-part=popup]_a]:rounded [&_[data-part=popup]_a]:px-3 [&_[data-part=popup]_a]:py-1.5 [&_[data-part=popup]_a]:text-sm [&_[data-part=popup]_a]:hover:bg-base-200"
    >
      <:item label="Home" href="#home" />
      <:item label="Products">
        <a href="#analytics" role="menuitem">Analytics</a>
        <a href="#automation" role="menuitem">Automation</a>
        <a href="#reports" role="menuitem">Reports</a>
      </:item>
      <:item label="Resources">
        <a href="#docs" role="menuitem">Documentation</a>
        <a href="#guides" role="menuitem">Guides</a>
      </:item>
      <:item label="Contact" href="#contact" />
    </.navigation_menu>
    """
  end

  def show(%{component: "number_field"} = assigns) do
    ~H"""
    <.number_field
      id={@id}
      name="quantity"
      value="3"
      min="0"
      max="10"
      step="1"
      class="inline-flex items-center rounded-md border border-base-300 [&_[data-part=decrement]]:px-3 [&_[data-part=decrement]]:py-1.5 [&_[data-part=decrement]]:text-lg [&_[data-part=decrement]]:leading-none [&_[data-part=decrement]]:hover:bg-base-200 [&_[data-part=increment]]:px-3 [&_[data-part=increment]]:py-1.5 [&_[data-part=increment]]:text-lg [&_[data-part=increment]]:leading-none [&_[data-part=increment]]:hover:bg-base-200 [&_[data-part=input]]:w-16 [&_[data-part=input]]:border-x [&_[data-part=input]]:border-base-300 [&_[data-part=input]]:bg-base-100 [&_[data-part=input]]:px-2 [&_[data-part=input]]:py-1.5 [&_[data-part=input]]:text-center [&_[data-part=input]]:[appearance:textfield] [&_[data-part=input]::-webkit-inner-spin-button]:appearance-none"
    />
    """
  end

  def show(%{component: "popover"} = assigns) do
    ~H"""
    <.popover
      id={@id}
      side="bottom"
      align="start"
      class="[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=popup]]:mt-2 [&_[data-part=popup]]:w-64 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-4 [&_[data-part=popup]]:shadow-lg"
    >
      <:trigger>Open popover</:trigger>
      <p class="text-sm font-semibold">Anchored popover</p>
      <p class="mt-1 text-sm text-base-content/70">
        Click the trigger to toggle. Click outside or press Escape to dismiss.
      </p>
    </.popover>
    """
  end

  def show(%{component: "preview_card"} = assigns) do
    ~H"""
    <.preview_card
      id={@id}
      side="top"
      class="[&_[data-part=trigger]]:underline [&_[data-part=trigger]]:decoration-dotted [&_[data-part=trigger]]:cursor-pointer [&_[data-part=popup]]:mb-2 [&_[data-part=popup]]:w-72 [&_[data-part=popup]]:rounded-lg [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-4 [&_[data-part=popup]]:shadow-lg"
    >
      <:trigger>@mishka_chelekom</:trigger>
      <div class="flex items-start gap-3">
        <div class="h-10 w-10 shrink-0 rounded-full bg-base-300"></div>
        <div>
          <p class="text-sm font-semibold">Mishka Chelekom</p>
          <p class="mt-1 text-sm text-base-content/70">
            Headless, accessible UI components for Phoenix LiveView.
          </p>
          <p class="mt-2 text-xs text-base-content/60">1.2k followers · 340 following</p>
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
      class="grid w-72 grid-cols-2 items-center gap-y-2 [&_[data-part=label]]:text-sm [&_[data-part=label]]:font-medium [&_[data-part=value]]:text-right [&_[data-part=value]]:text-sm [&_[data-part=value]]:tabular-nums [&_[data-part=value]]:text-base-content/60 [&_[data-part=track]]:col-span-2 [&_[data-part=track]]:h-2.5 [&_[data-part=track]]:overflow-hidden [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-base-200 [&_[data-part=track]]:border [&_[data-part=track]]:border-base-300 [&_[data-part=indicator]]:h-full [&_[data-part=indicator]]:w-full [&_[data-part=indicator]]:origin-left [&_[data-part=indicator]]:rounded-full [&_[data-part=indicator]]:bg-primary [&_[data-part=indicator]]:transition-transform [&_[data-part=indicator]]:duration-500 [&_[data-part=indicator]]:[transform:scaleX(var(--chelekom-progress,0))] [&_[data-part=indicator][data-complete]]:bg-success"
    />
    """
  end

  def show(%{component: "radio_group"} = assigns) do
    ~H"""
    <.radio_group
      id={@id}
      name="plan"
      value="pro"
      class="w-72 space-y-2 [&_[data-part=item]]:flex [&_[data-part=item]]:w-full [&_[data-part=item]]:cursor-pointer [&_[data-part=item]]:items-center [&_[data-part=item]]:gap-2 [&_[data-part=item]]:rounded-md [&_[data-part=item]]:border [&_[data-part=item]]:border-base-300 [&_[data-part=item]]:bg-base-100 [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-2 [&_[data-part=item]]:text-left [&_[data-part=item][aria-checked=true]]:border-primary [&_[data-part=item][aria-checked=true]]:font-semibold"
    >
      <:option value="free">Free</:option>
      <:option value="pro">Pro</:option>
      <:option value="enterprise">Enterprise</:option>
    </.radio_group>
    """
  end

  def show(%{component: "scroll_area"} = assigns) do
    ~H"""
    <.scroll_area
      id={@id}
      orientation="vertical"
      class="h-48 w-72 rounded-md border border-base-300 [&_[data-part=viewport]]:h-full [&_[data-part=viewport]]:overflow-auto [&_[data-part=viewport]]:p-3 [&_[data-part=viewport]]:focus:outline-none"
    >
      <p class="text-sm font-semibold">Scrollable region</p>
      <p class="mt-2 text-sm text-base-content/70">
        Focus the viewport and use the arrow keys, Page Up/Down, or Home/End to scroll.
        It is a plain overflow container with no custom scrollbar styling.
      </p>
      <ul class="mt-3 space-y-2 text-sm">
        <li :for={n <- 1..20} class="rounded border border-base-200 px-2 py-1.5">
          Item {n}
        </li>
      </ul>
    </.scroll_area>
    """
  end

  def show(%{component: "select"} = assigns) do
    ~H"""
    <.select
      id={@id}
      name="fruit"
      value="Banana"
      placeholder="Choose a fruit…"
      class="[&_[data-part=trigger]]:min-w-44 [&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:bg-base-100 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-left [&_[data-part=popup]]:mt-1 [&_[data-part=popup]]:min-w-44 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:border [&_[data-part=popup]]:border-base-300 [&_[data-part=popup]]:bg-base-100 [&_[data-part=popup]]:p-1 [&_[data-part=popup]]:shadow-lg [&_[role=option]]:cursor-pointer [&_[role=option]]:px-3 [&_[role=option]]:py-1.5 [&_[data-highlighted]]:bg-base-200 [&_[aria-selected=true]]:font-semibold"
    >
      <:option value="Apple">Apple</:option>
      <:option value="Banana">Banana</:option>
      <:option value="Cherry">Cherry</:option>
    </.select>
    """
  end

  def show(%{component: "separator"} = assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-base-content/40">Horizontal</p>
        <div class="w-72 text-sm text-base-content/70">
          <p>Account settings</p>
          <.separator id={"#{@id}-plain"} class="my-2.5 h-px w-full bg-base-300" />
          <p>Danger zone</p>
        </div>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-base-content/40">Labelled</p>
        <.separator
          id={"#{@id}-or"}
          class="flex w-72 items-center gap-3 text-xs uppercase tracking-wide text-base-content/60 before:h-px before:flex-1 before:bg-base-300 after:h-px after:flex-1 after:bg-base-300 [&_[data-part=label]]:shrink-0"
        >
          or continue with
        </.separator>
      </div>

      <div class="space-y-1.5">
        <p class="text-[0.7rem] uppercase tracking-wide text-base-content/40">Vertical (in a nav)</p>
        <nav class="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-base-content/80">
          <a href="#" class="hover:text-base-content">Home</a>
          <a href="#" class="hover:text-base-content">Pricing</a>
          <a href="#" class="hover:text-base-content">Blog</a>
          <a href="#" class="hover:text-base-content">Support</a>
          <.separator id={"#{@id}-nav"} orientation="vertical" class="h-4 w-px bg-base-300" />
          <a href="#" class="hover:text-base-content">Log in</a>
          <a href="#" class="hover:text-base-content">Sign up</a>
        </nav>
      </div>
    </div>
    """
  end

  def show(%{component: "slider"} = assigns) do
    ~H"""
    <.slider
      id={@id}
      name="price"
      min={0}
      max={100}
      step={5}
      values={[20, 70]}
      class="relative flex w-72 items-center [&_[data-part=track]]:relative [&_[data-part=track]]:h-2 [&_[data-part=track]]:w-full [&_[data-part=track]]:rounded-full [&_[data-part=track]]:bg-base-300 [&_[data-part=range]]:absolute [&_[data-part=range]]:inset-y-0 [&_[data-part=range]]:left-0 [&_[data-part=range]]:rounded-full [&_[data-part=range]]:bg-primary [&_[data-part=range]]:[width:calc(var(--chelekom-slider,0)*100%)] [&_[data-part=thumb]]:absolute [&_[data-part=thumb]]:top-1/2 [&_[data-part=thumb]]:h-4 [&_[data-part=thumb]]:w-4 [&_[data-part=thumb]]:-translate-x-1/2 [&_[data-part=thumb]]:-translate-y-1/2 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:border [&_[data-part=thumb]]:border-base-300 [&_[data-part=thumb]]:bg-base-100 [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:[left:calc(var(--chelekom-slider,0)*100%)] [&_[data-part=thumb]]:cursor-grab [&_[data-part=thumb]]:focus:outline-none [&_[data-part=thumb]]:focus:ring-2 [&_[data-part=thumb]]:focus:ring-primary"
    />
    """
  end

  def show(%{component: "switch"} = assigns) do
    ~H"""
    <.switch
      id={@id}
      name="notifications"
      checked
      class="inline-flex items-center gap-3 [&[data-checked=true]_[data-part=thumb]]:translate-x-5 [&[data-checked=true]>span:first-of-type]:bg-primary [&[data-unchecked=true]>span:first-of-type]:bg-base-300 [&>span:first-of-type]:relative [&>span:first-of-type]:inline-flex [&>span:first-of-type]:h-6 [&>span:first-of-type]:w-11 [&>span:first-of-type]:rounded-full [&>span:first-of-type]:transition-colors [&_[data-part=thumb]]:inline-block [&_[data-part=thumb]]:h-5 [&_[data-part=thumb]]:w-5 [&_[data-part=thumb]]:translate-x-0.5 [&_[data-part=thumb]]:translate-y-0.5 [&_[data-part=thumb]]:rounded-full [&_[data-part=thumb]]:bg-base-100 [&_[data-part=thumb]]:shadow [&_[data-part=thumb]]:transition-transform [&_[data-part=label]]:text-sm"
    >
      Enable notifications
    </.switch>
    """
  end

  def show(%{component: "tabs"} = assigns) do
    ~H"""
    <.tabs
      id={@id}
      class="w-96 [&_[data-part=tablist]]:flex [&_[data-part=tablist]]:gap-1 [&_[data-part=tablist]]:border-b [&_[data-part=tablist]]:border-base-300 [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]]:-mb-px [&_[data-part=item]]:border-b-2 [&_[data-part=item]]:border-transparent [&_[data-part=item][aria-selected=true]]:border-base-content [&_[data-part=item][aria-selected=true]]:font-semibold [&_[data-part=panel]]:rounded-b-md [&_[data-part=panel]]:bg-base-100 [&_[data-part=panel]]:p-3 [&_[data-part=panel]]:text-sm [&_[data-part=panel][data-closed=true]]:hidden"
    >
      <:tab>Account</:tab>
      <:tab>Password</:tab>
      <:tab>Team</:tab>
      <:panel>Manage your account details and profile information.</:panel>
      <:panel>Update your password and review recent sign-in activity.</:panel>
      <:panel>Invite teammates and configure their roles.</:panel>
    </.tabs>
    """
  end

  def show(%{component: "toast"} = assigns) do
    ~H"""
    <.toast id={"#{@id}-basic"} limit={3} class={toast_class(:bottom)}>
      <:trigger>Create toast</:trigger>
      <:template>
        <div class="min-w-0 flex-1">
          <p class="font-semibold">Toast <span data-toast-count>1</span> created</p>
          <p class="text-base-content/70">This is a toast notification.</p>
        </div>
      </:template>
    </.toast>
    """
  end

  def show(%{component: "toggle"} = assigns) do
    ~H"""
    <.toggle
      id={@id}
      pressed={false}
      class="inline-flex items-center gap-2 rounded-md border border-base-300 bg-base-100 px-3 py-1.5 text-sm data-[on]:border-primary data-[on]:bg-primary data-[on]:text-primary-content"
    >
      <span class="hidden data-[on]:inline">Bold: on</span>
      <span class="data-[on]:hidden">Bold: off</span>
    </.toggle>
    """
  end

  def show(%{component: "toggle_group"} = assigns) do
    ~H"""
    <.toggle_group
      id={@id}
      class="inline-flex gap-1 rounded-md border border-base-300 bg-base-100 p-1 [&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item][data-on]]:bg-base-content [&_[data-part=item][data-on]]:text-base-100 [&_[data-part=item][data-off]]:text-base-content [&_[data-part=item][data-disabled]]:opacity-40 [&_[data-part=item][data-disabled]]:cursor-not-allowed"
    >
      <:item value="bold">Bold</:item>
      <:item value="italic">Italic</:item>
      <:item value="underline" disabled>Underline</:item>
    </.toggle_group>
    """
  end

  def show(%{component: "toolbar"} = assigns) do
    ~H"""
    <.toolbar
      id={@id}
      orientation="horizontal"
      class="inline-flex gap-1 rounded-md border border-base-300 bg-base-100 p-1 [&_[data-part=item]]:rounded [&_[data-part=item]]:px-3 [&_[data-part=item]]:py-1.5 [&_[data-part=item]]:text-sm [&_[data-part=item]:hover]:bg-base-200 [&_[data-part=item]:focus]:outline [&_[data-part=item]:focus]:outline-2 [&_[data-part=item]:focus]:outline-primary [&_[data-part=item][data-disabled]]:opacity-40 [&_[data-part=item][data-disabled]]:pointer-events-none"
    >
      <:item>Bold</:item>
      <:item>Italic</:item>
      <:item disabled>Underline</:item>
    </.toolbar>
    """
  end

  def show(%{component: "tooltip"} = assigns) do
    ~H"""
    <.tooltip
      id={@id}
      side="top"
      class="[&_[data-part=trigger]]:cursor-help [&_[data-part=trigger]]:underline [&_[data-part=trigger]]:decoration-dotted [&_[data-part=trigger]]:underline-offset-4 [&_[data-part=popup]]:mb-1 [&_[data-part=popup]]:rounded-md [&_[data-part=popup]]:bg-base-content [&_[data-part=popup]]:px-2 [&_[data-part=popup]]:py-1 [&_[data-part=popup]]:text-xs [&_[data-part=popup]]:text-base-100 [&_[data-part=popup]]:shadow-lg [&_[data-part=popup]]:max-w-48"
    >
      <:trigger>hover or focus me</:trigger>
      Helpful hint shown on hover/focus; press Escape to dismiss.
    </.tooltip>
    """
  end

  def show(assigns) do
    ~H"""
    <p class="text-sm text-base-content/60">No example for <code>{@component}</code>.</p>
    """
  end

  # Shared toast stacking classes for the showcase (`:bottom` grows up, `:top` grows down — Base UI's
  # two viewport variants). Kept literal so Tailwind scans them.
  defp toast_class(anchor) do
    [
      "relative w-72 space-y-3",
      "[&_[data-part=trigger]]:rounded-md [&_[data-part=trigger]]:border [&_[data-part=trigger]]:border-base-300 [&_[data-part=trigger]]:bg-base-100 [&_[data-part=trigger]]:px-3 [&_[data-part=trigger]]:py-1.5 [&_[data-part=trigger]]:text-sm [&_[data-part=trigger]]:font-medium [&_[data-part=trigger]]:hover:bg-base-200",
      "[&_[data-part=viewport]]:relative [&_[data-part=viewport]]:h-60 [&_[data-part=viewport]]:w-full [&_[data-part=viewport]]:overflow-hidden [&_[data-part=viewport]]:[list-style:none] [&_[data-part=viewport]]:[padding:0] [&_[data-part=viewport]]:[margin:0]",
      "[&_[data-part=toast]]:[--gap:0.6rem] [&_[data-part=toast]]:[--peek:0.6rem] [&_[data-part=toast]]:[--scale:calc(max(0,1-(var(--toast-index)*0.1)))] [&_[data-part=toast]]:[--shrink:calc(1-var(--scale))] [&_[data-part=toast]]:[--height:var(--toast-frontmost-height,var(--toast-height))] [&_[data-part=toast]]:absolute [&_[data-part=toast]]:inset-x-0 [&_[data-part=toast]]:z-[calc(1000-var(--toast-index))] [&_[data-part=toast]]:h-[var(--height)] [&_[data-part=toast]]:rounded-md [&_[data-part=toast]]:border [&_[data-part=toast]]:border-base-300 [&_[data-part=toast]]:bg-base-100 [&_[data-part=toast]]:shadow-lg [&_[data-part=toast]]:[transition:transform_0.5s_cubic-bezier(0.22,1,0.36,1),opacity_0.4s,height_0.15s]",
      "[&_[data-part=toast][data-expanded]]:[transform:translateY(var(--offset-y))] [&_[data-part=toast][data-expanded]]:h-[var(--toast-height)] [&_[data-part=toast][data-ending-style]]:opacity-0 [&_[data-part=toast][data-limited]]:opacity-0",
      "[&_[data-part=content]]:flex [&_[data-part=content]]:h-full [&_[data-part=content]]:items-start [&_[data-part=content]]:gap-3 [&_[data-part=content]]:overflow-hidden [&_[data-part=content]]:p-3 [&_[data-part=content]]:text-sm [&_[data-part=content]]:transition-opacity [&_[data-part=content][data-behind]]:opacity-0",
      "[&_[data-part=close]]:ml-auto [&_[data-part=close]]:shrink-0 [&_[data-part=close]]:rounded [&_[data-part=close]]:px-1.5 [&_[data-part=close]]:text-lg [&_[data-part=close]]:leading-none [&_[data-part=close]]:text-base-content/40 [&_[data-part=close]]:hover:text-base-content",
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
  def has_examples?(_), do: false

  def examples(%{component: "toast"} = assigns) do
    ~H"""
    <div class="space-y-3">
      <details class="rounded-box border border-base-300 bg-base-100 p-4">
        <summary class="cursor-pointer select-none font-medium">Top placement</summary>
        <p class="mt-1 text-sm text-base-content/60">
          Position is pure CSS on the viewport. Here the stack anchors at the top and grows downward;
          in a real app add <code>fixed left-4 top-4</code> to the viewport.
        </p>
        <div class="mt-4">
          <.toast id={"#{@id}-top"} limit={5} duration={2000} class={toast_class(:top)}>
            <:trigger>Create toast</:trigger>
            <:template>
              <div class="min-w-0 flex-1">
                <p class="font-semibold">Toast <span data-toast-count>1</span> created</p>
                <p class="text-base-content/70">Auto-dismisses in 2 seconds.</p>
              </div>
            </:template>
          </.toast>
        </div>
        <.code_block code={example_code("Top placement")} class="mt-3" />
      </details>

      <details class="rounded-box border border-base-300 bg-base-100 p-4">
        <summary class="cursor-pointer select-none font-medium">Deduplicated</summary>
        <p class="mt-1 text-sm text-base-content/60">
          With <code>dedup_key</code>, clicking repeatedly refreshes the same toast (resets its timer,
          pops it to the front) instead of stacking duplicates.
        </p>
        <div class="mt-4">
          <.toast id={"#{@id}-dedup"} dedup_key="saved" class={toast_class(:bottom)}>
            <:trigger>Save (click repeatedly)</:trigger>
            <:template>
              <div class="min-w-0 flex-1">
                <p class="font-semibold">Saved</p>
                <p class="text-base-content/70">Re-clicking just refreshes this one toast.</p>
              </div>
            </:template>
          </.toast>
        </div>
        <.code_block code={example_code("Deduplicated")} class="mt-3" />
      </details>

      <details class="rounded-box border border-base-300 bg-base-100 p-4">
        <summary class="cursor-pointer select-none font-medium">Varying heights</summary>
        <p class="mt-1 text-sm text-base-content/60">
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
                <p class="text-base-content/70">A second line of detail.</p>
              </div>
            </:toast>
            <:toast duration={0}>
              <div class="min-w-0 flex-1">
                <p class="font-semibold">Tall</p>
                <p class="text-base-content/70">
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

  def examples(assigns), do: ~H""
end
