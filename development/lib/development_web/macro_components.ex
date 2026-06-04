defmodule DevelopmentWeb.MacroComponents do
  @moduledoc """
  Components declared with the `MishkaChelekom.Component` macro — both a styled button
  (variants + overrides + merge) and a headless disclosure (parts + ARIA + hook), to show the
  one macro covering both. Used by the `/showcase/macro` page.
  """
  use MishkaChelekom.Component

  # styled
  component :m_button,
    tag: :button,
    base: "inline-flex items-center justify-center font-medium rounded-md transition",
    variants: [
      color: [
        primary: "bg-primary text-primary-content hover:bg-primary/90",
        ghost: "bg-transparent text-base-content hover:bg-base-200",
        danger: "bg-error text-error-content hover:bg-error/90"
      ],
      size: [sm: "h-8 px-3 text-xs", md: "h-9 px-4 text-sm", lg: "h-11 px-6 text-base"]
    ],
    defaults: [color: :primary, size: :md]

  # headless
  component :m_disclosure,
    headless: true,
    hook: "Disclosure",
    parts: [
      trigger: [
        tag: :button,
        id: true,
        slot: true,
        aria: [controls: {:ref, :panel}, expanded: "false"]
      ],
      panel: [
        tag: :div,
        id: true,
        role: "region",
        state: true,
        aria: [labelledby: {:ref, :trigger}],
        slot: :inner_block
      ]
    ]
end
