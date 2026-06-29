defmodule DevelopmentWeb.Widgets do
  @moduledoc """
  A bespoke, hand-written component that deliberately does NOT follow the Mishka
  `<Web>.Components.<Name>.<name>` naming convention — it lives here under an arbitrary module and a
  `ribbon/1` function. Used by `/showcase/kit` to demonstrate the Kit's `from {Module, :function}`
  form, which delegates to an exact target with no convention and no `components` namespace.
  """
  use Phoenix.Component

  # `:any` — the Kit's `safe/2` preserves atom type, so the wrapper may hand us `:plain` (atom),
  # while a direct call passes a "string". color_class/1 normalises both.
  attr :color, :any, default: "plain", doc: "Color theme (atom or string)"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def ribbon(assigns) do
    ~H"""
    <span
      class={[
        "inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold ring-1 ring-inset",
        color_class(@color),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp color_class(c) when is_atom(c) and not is_nil(c), do: color_class(to_string(c))

  defp color_class("plain"),
    do: "bg-[var(--c-base-200)] text-[var(--c-base-content)] ring-[var(--c-base-300)]"

  defp color_class(_),
    do: "bg-[var(--c-base-200)] text-[var(--c-base-content)] ring-[var(--c-base-300)]"
end
