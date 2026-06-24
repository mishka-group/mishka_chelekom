defmodule DevelopmentWeb.Showcase.HeadlessKitDemo do
  @moduledoc """
  Renders the live RESULT of skinning a headless component with a real `MishkaChelekom.Kit` — the
  `part` rules generate a styled wrapper (e.g. `my_accordion`) that delegates to the untouched
  headless component. Powers the "Customize it" section of the headless showcase, mirroring the
  styled `DevelopmentWeb.Showcase.KitDemo`.
  """
  use DevelopmentWeb, :html

  # Row components for the context_menu macro demo (the Kit wraps only the root).
  import DevelopmentWeb.Components.Headless.ContextMenu,
    only: [context_menu_item: 1, context_menu_separator: 1]

  import DevelopmentWeb.Kit,
    only: [
      my_accordion: 1,
      my_collapsible: 1,
      my_meter: 1,
      my_alert_dialog: 1,
      my_autocomplete: 1,
      my_avatar: 1,
      my_checkbox: 1,
      my_checkbox_group: 1,
      my_combobox: 1,
      my_context_menu: 1,
      my_dialog: 1,
      my_drawer: 1,
      my_field: 1,
      my_fieldset: 1,
      my_menu: 1,
      my_menubar: 1,
      my_navigation_menu: 1,
      my_number_field: 1,
      my_otp_field: 1,
      my_popover: 1,
      my_preview_card: 1,
      my_progress: 1,
      my_radio: 1,
      my_radio_group: 1,
      my_scroll_area: 1,
      my_select: 1,
      my_separator: 1,
      my_slider: 1,
      my_switch: 1,
      my_tabs: 1,
      my_toast: 1,
      my_toggle: 1,
      my_toggle_group: 1,
      my_toolbar: 1,
      my_tooltip: 1
    ]

  @available ~w(accordion collapsible meter alert_dialog autocomplete avatar checkbox checkbox_group combobox context_menu dialog drawer field fieldset menu menubar navigation_menu number_field otp_field popover preview_card progress radio radio_group scroll_area select separator slider switch tabs toast toggle toggle_group toolbar tooltip)
  def available?(name), do: name in @available

  # The REAL `customize` blocks that produce the live results, lifted verbatim from `kit.ex` so the
  # snippet and the rendered skin can never drift apart.
  @kit_path Path.expand("../../kit.ex", __DIR__)
  @external_resource @kit_path
  @kit_source File.read!(@kit_path)

  @doc "The actual Kit `customize :my_<name>` source for a skinned component (nil → fall back)."
  def code(name) when name in @available do
    case Regex.run(~r/  customize :my_#{name} do.*?\n  end/s, @kit_source) do
      [block] -> block |> String.replace(~r/^  /m, "") |> String.trim_trailing()
      _ -> nil
    end
  end

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

  def demo(%{component: "meter"} = assigns) do
    ~H"""
    <.my_meter id="hl-meter-skin" label="Disk usage" value={72} show_value class="w-full max-w-md" />
    """
  end

  def demo(%{component: "alert_dialog"} = assigns) do
    ~H"""
    <.my_alert_dialog id="hl-alert_dialog-skin" class="w-full max-w-md">
      <:trigger>Delete account</:trigger>
      <:title>Delete account?</:title>
      <:description>This permanently removes your account and cannot be undone.</:description>
      <:actions>
        <button
          class="rounded-md border border-amber-200 bg-amber-50 px-3 py-1.5 text-sm font-medium text-amber-950 hover:bg-amber-100 dark:border-amber-900 dark:bg-amber-950/30 dark:text-amber-50 dark:hover:bg-amber-900/40"
          data-close
        >
          Cancel
        </button>
        <button
          class="rounded-md bg-amber-500 px-3 py-1.5 text-sm font-medium text-white hover:bg-amber-600 dark:bg-amber-400 dark:text-amber-950 dark:hover:bg-amber-300"
          data-close
        >
          Delete
        </button>
      </:actions>
    </.my_alert_dialog>
    """
  end

  def demo(%{component: "autocomplete"} = assigns) do
    ~H"""
    <.my_autocomplete
      id="hl-autocomplete-skin"
      name="food"
      placeholder="Search food…"
      auto_highlight
      clear
    >
      <:option value="Apple" group="Fruit">Apple</:option>
      <:option value="Banana" group="Fruit">Banana</:option>
      <:option value="Carrot" group="Vegetable">Carrot</:option>
      <:option value="Potato" group="Vegetable">Potato</:option>
      <:empty>No matches.</:empty>
    </.my_autocomplete>
    """
  end

  def demo(%{component: "avatar"} = assigns) do
    ~H"""
    <.my_avatar
      id="hl-avatar-skin"
      src="https://avatars.githubusercontent.com/u/8722951?v=4"
      alt="User avatar"
    >
      MC
    </.my_avatar>
    """
  end

  def demo(%{component: "checkbox"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.my_checkbox id="hl-checkbox-skin" name="terms" value="accepted" checked>
        I agree to the terms and conditions
      </.my_checkbox>
      <div id="hl-checkbox-grp" phx-hook="CheckboxGroup" role="group" aria-label="Fruit">
        <.my_checkbox id="hl-cb-all" parent indeterminate>Apples</.my_checkbox>
        <div class="ml-6 mt-1 flex flex-col gap-1.5">
          <.my_checkbox id="hl-cb-fuji" checked>Fuji</.my_checkbox>
          <.my_checkbox id="hl-cb-gala">Gala</.my_checkbox>
          <.my_checkbox id="hl-cb-gs">Granny Smith</.my_checkbox>
        </div>
      </div>
    </div>
    """
  end

  def demo(%{component: "checkbox_group"} = assigns) do
    ~H"""
    <.my_checkbox_group id="hl-checkbox_group-skin" name="toppings">
      <:label>Pizza toppings</:label>
      <:select_all>All toppings</:select_all>
      <:item value="cheese" checked>Cheese</:item>
      <:item value="mushroom">Mushroom</:item>
      <:item value="pepperoni" disabled>Pepperoni (sold out)</:item>
    </.my_checkbox_group>
    """
  end

  def demo(%{component: "combobox"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.my_combobox
        id="hl-combobox-skin"
        name="fruit"
        value="banana"
        placeholder="Search fruit…"
        trigger
        clear
      >
        <:option value="apple">Apple</:option>
        <:option value="banana">Banana</:option>
        <:option value="cherry">Cherry</:option>
        <:option value="durian" disabled>Durian (out of stock)</:option>
        <:empty>No fruit found.</:empty>
      </.my_combobox>
      <.my_combobox
        id="hl-combobox-multi-skin"
        name="picks"
        multiple
        value={["apple"]}
        placeholder="Add items…"
        clear
      >
        <:option value="apple" group="Fruit">Apple</:option>
        <:option value="banana" group="Fruit">Banana</:option>
        <:option value="carrot" group="Vegetable">Carrot</:option>
        <:option value="potato" group="Vegetable">Potato</:option>
        <:empty>No matches.</:empty>
      </.my_combobox>
    </div>
    """
  end

  def demo(%{component: "context_menu"} = assigns) do
    ~H"""
    <.my_context_menu id="hl-context_menu-skin" class="w-full max-w-md">
      <:trigger>Right-click inside this area</:trigger>
      <.context_menu_item>Cut</.context_menu_item>
      <.context_menu_item>Copy</.context_menu_item>
      <.context_menu_item>Paste</.context_menu_item>
      <.context_menu_separator />
      <.context_menu_item disabled>Delete</.context_menu_item>
    </.my_context_menu>
    """
  end

  def demo(%{component: "dialog"} = assigns) do
    ~H"""
    <.my_dialog id="hl-dialog-skin" class="w-full max-w-md">
      <:trigger>Open dialog</:trigger>
      <:title>Confirm action</:title>
      <:description>This is a fully headless, focus-trapped dialog.</:description>
      <p>
        Tab cycles inside; Escape, the backdrop, or the close button dismiss it.
      </p>
      <:close>
        <button type="button" data-close>Cancel</button>
        <button type="button" data-close>Confirm</button>
      </:close>
    </.my_dialog>
    """
  end

  def demo(%{component: "drawer"} = assigns) do
    ~H"""
    <.my_drawer id="hl-drawer-skin" side="right" class="w-full max-w-md">
      <:trigger>Open drawer</:trigger>
      <:title>Filters</:title>
      <:description>A focus-trapped panel that slides in from the edge.</:description>
      <p class="mt-2 text-sm">Drawer body — same behavior as dialog, with a side.</p>
      <:close>
        <button data-close>Close</button>
      </:close>
    </.my_drawer>
    """
  end

  def demo(%{component: "field"} = assigns) do
    ~H"""
    <.my_field
      id="hl-field-skin"
      for="hl-field-skin-email"
      label="Email address"
      errors={["Email is required", "Must be a valid address"]}
      class="w-full max-w-md"
    >
      <input
        id="hl-field-skin-email"
        type="email"
        name="email"
        placeholder="you@example.com"
        aria-describedby="hl-field-skin-desc"
      />
      <:description>We'll only use this to send account notifications.</:description>
    </.my_field>
    """
  end

  def demo(%{component: "fieldset"} = assigns) do
    ~H"""
    <.my_fieldset id="hl-fieldset-skin" class="w-full max-w-md">
      <:legend>Shipping address</:legend>
      <div class="mt-2 space-y-3">
        <label class="block text-sm">
          <span class="mb-1 block text-amber-700 dark:text-amber-300/80">Street</span>
          <input
            type="text"
            name="street"
            value="123 Main St"
            class="w-full rounded-md border border-amber-200 bg-amber-50/50 px-3 py-1.5 text-amber-950 dark:border-amber-900/50 dark:bg-amber-950/20 dark:text-amber-50"
          />
        </label>
        <label class="block text-sm">
          <span class="mb-1 block text-amber-700 dark:text-amber-300/80">City</span>
          <input
            type="text"
            name="city"
            value="Springfield"
            class="w-full rounded-md border border-amber-200 bg-amber-50/50 px-3 py-1.5 text-amber-950 dark:border-amber-900/50 dark:bg-amber-950/20 dark:text-amber-50"
          />
        </label>
        <label class="block text-sm">
          <span class="mb-1 block text-amber-700 dark:text-amber-300/80">Postal code</span>
          <input
            type="text"
            name="zip"
            value="12345"
            class="w-full rounded-md border border-amber-200 bg-amber-50/50 px-3 py-1.5 text-amber-950 dark:border-amber-900/50 dark:bg-amber-950/20 dark:text-amber-50"
          />
        </label>
      </div>
    </.my_fieldset>
    """
  end

  def demo(%{component: "menu"} = assigns) do
    ~H"""
    <.my_menu id="hl-menu-skin" class="w-full max-w-md">
      <:trigger>Options ▾</:trigger>
      <:item>Edit</:item>
      <:item>Duplicate</:item>
      <:item separator />
      <:item disabled>Archive</:item>
      <:submenu label="Share ▸">
        <button type="button" role="menuitem" data-part="item" tabindex="-1">
          Copy link
        </button>
        <button type="button" role="menuitem" data-part="item" tabindex="-1">
          Email
        </button>
      </:submenu>
    </.my_menu>
    """
  end

  def demo(%{component: "menubar"} = assigns) do
    ~H"""
    <.my_menubar id="hl-menubar-skin" class="w-full max-w-md">
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
    </.my_menubar>
    """
  end

  def demo(%{component: "navigation_menu"} = assigns) do
    ~H"""
    <.my_navigation_menu id="hl-navigation_menu-skin" class="w-full max-w-md">
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
    </.my_navigation_menu>
    """
  end

  def demo(%{component: "number_field"} = assigns) do
    ~H"""
    <.my_number_field
      id="hl-number_field-skin"
      name="quantity"
      value="3"
      min="0"
      max="10"
      step="1"
      class="w-full max-w-md"
    />
    """
  end

  def demo(%{component: "otp_field"} = assigns) do
    ~H"""
    <.my_otp_field id="hl-otp_field-skin" name="code" length={6} class="w-full max-w-md" />
    """
  end

  def demo(%{component: "popover"} = assigns) do
    ~H"""
    <.my_popover id="hl-popover-skin" side="bottom" align="start" class="w-full max-w-md">
      <:trigger>Open popover</:trigger>
      <p class="text-sm font-semibold text-amber-950 dark:text-amber-50">Anchored popover</p>
      <p class="mt-1 text-sm text-amber-700 dark:text-amber-300">
        Click the trigger to toggle. Click outside or press Escape to dismiss.
      </p>
    </.my_popover>
    """
  end

  def demo(%{component: "preview_card"} = assigns) do
    ~H"""
    <.my_preview_card id="hl-preview_card-skin" side="top" class="w-full max-w-md">
      <:trigger>@mishka_chelekom</:trigger>
      <div class="flex items-start gap-3">
        <div class="h-10 w-10 shrink-0 rounded-full bg-amber-200 dark:bg-amber-900"></div>
        <div>
          <p class="text-sm font-semibold text-amber-950 dark:text-amber-50">Mishka Chelekom</p>
          <p class="mt-1 text-sm text-amber-900/70 dark:text-amber-100/70">
            Headless, accessible UI components for Phoenix LiveView.
          </p>
          <p class="mt-2 text-xs text-amber-700/70 dark:text-amber-300/70">
            1.2k followers · 340 following
          </p>
        </div>
      </div>
    </.my_preview_card>
    """
  end

  def demo(%{component: "progress"} = assigns) do
    ~H"""
    <.my_progress
      id="hl-progress-skin"
      value={65}
      max={100}
      label="Upload progress"
      show_value
      class="w-full max-w-md"
    />
    """
  end

  def demo(%{component: "radio"} = assigns) do
    ~H"""
    <div class="flex w-full max-w-md flex-col gap-2">
      <.my_radio
        :for={{label, v} <- [{"Email", "email"}, {"SMS", "sms"}, {"Push", "push"}]}
        id={"hl-radio-skin-#{v}"}
        name="notify"
        value={v}
        checked={v == "email"}
      >
        {label}
      </.my_radio>
    </div>
    """
  end

  def demo(%{component: "radio_group"} = assigns) do
    ~H"""
    <.my_radio_group id="hl-radio_group-skin" name="plan" value="pro" class="w-full max-w-md">
      <:option value="free">Free</:option>
      <:option value="pro">Pro</:option>
      <:option value="enterprise">Enterprise</:option>
    </.my_radio_group>
    """
  end

  def demo(%{component: "scroll_area"} = assigns) do
    ~H"""
    <.my_scroll_area id="hl-scroll_area-skin" orientation="vertical" class="w-full max-w-md">
      <p class="text-sm font-semibold text-amber-950 dark:text-amber-50">Scrollable region</p>
      <p class="mt-2 text-sm text-amber-700 dark:text-amber-300">
        Focus the viewport and use the arrow keys, Page Up/Down, or Home/End to scroll.
        It is a plain overflow container with no custom scrollbar styling.
      </p>
      <ul class="mt-3 space-y-2 text-sm">
        <li
          :for={n <- 1..20}
          class="rounded-lg border border-amber-200 bg-amber-100/60 px-2 py-1.5 text-amber-900 dark:border-amber-900/50 dark:bg-amber-900/30 dark:text-amber-100"
        >
          Item {n}
        </li>
      </ul>
    </.my_scroll_area>
    """
  end

  def demo(%{component: "select"} = assigns) do
    ~H"""
    <.my_select
      id="hl-select-skin"
      name="fruit"
      value="Banana"
      placeholder="Choose a fruit…"
      class="w-full max-w-md"
    >
      <:option value="Apple">Apple</:option>
      <:option value="Banana">Banana</:option>
      <:option value="Cherry">Cherry</:option>
    </.my_select>
    """
  end

  def demo(%{component: "separator"} = assigns) do
    ~H"""
    <.my_separator id="hl-separator-skin" orientation="horizontal" class="w-full max-w-md">
      or continue with
    </.my_separator>
    """
  end

  def demo(%{component: "slider"} = assigns) do
    ~H"""
    <.my_slider
      id="hl-slider-skin"
      name="price"
      min={0}
      max={100}
      step={5}
      values={[20, 70]}
      show_value
      class="w-full max-w-md"
    />
    """
  end

  def demo(%{component: "switch"} = assigns) do
    ~H"""
    <.my_switch id="hl-switch-skin" name="notifications" checked class="w-full max-w-md">
      Enable notifications
    </.my_switch>
    """
  end

  def demo(%{component: "tabs"} = assigns) do
    ~H"""
    <.my_tabs id="hl-tabs-skin" class="w-full max-w-md">
      <:tab>Account</:tab>
      <:tab>Password</:tab>
      <:tab>Team</:tab>
      <:panel>Manage your account details and profile information.</:panel>
      <:panel>Update your password and review recent sign-in activity.</:panel>
      <:panel>Invite teammates and configure their roles.</:panel>
    </.my_tabs>
    """
  end

  def demo(%{component: "toast"} = assigns) do
    ~H"""
    <.my_toast id="hl-toast-skin">
      <:trigger>Create toast</:trigger>
      <:template>
        <div class="min-w-0 flex-1">
          <p class="font-semibold text-amber-900 dark:text-amber-100">
            Toast <span data-toast-count>1</span> created
          </p>
          <p class="text-amber-700 dark:text-amber-300">This is a toast notification.</p>
        </div>
      </:template>
    </.my_toast>
    """
  end

  def demo(%{component: "toggle"} = assigns) do
    ~H"""
    <.my_toggle id="hl-toggle-skin" pressed={false} class="w-full max-w-md justify-center">
      <span class="hidden data-[pressed]:inline">Bold: on</span>
      <span class="data-[pressed]:hidden">Bold: off</span>
    </.my_toggle>
    """
  end

  def demo(%{component: "toggle_group"} = assigns) do
    ~H"""
    <.my_toggle_group id="hl-toggle_group-skin" class="w-full max-w-md">
      <:item value="bold">Bold</:item>
      <:item value="italic">Italic</:item>
      <:item value="underline" disabled>Underline</:item>
    </.my_toggle_group>
    """
  end

  def demo(%{component: "toolbar"} = assigns) do
    ~H"""
    <.my_toolbar id="hl-toolbar-skin" orientation="horizontal" class="w-full max-w-md">
      <:item>Bold</:item>
      <:item>Italic</:item>
      <:item disabled>Underline</:item>
    </.my_toolbar>
    """
  end

  def demo(%{component: "tooltip"} = assigns) do
    ~H"""
    <.my_tooltip id="hl-tooltip-skin" side="top" class="w-full max-w-md">
      <:trigger>hover or focus me</:trigger>
      Helpful hint shown on hover/focus; press Escape to dismiss.
    </.my_tooltip>
    """
  end

  def demo(assigns), do: ~H""
end
