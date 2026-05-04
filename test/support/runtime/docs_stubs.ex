defmodule MishkaChelekom.Test.Runtime.DemoHarness.DocsStubs do
  @moduledoc """
  No-op implementations of the docs-page helpers (`<.cp>`, `<.heading2>`,
  `<.custom_inline_code>`, etc.) that mishka.tools' chelekom showcase
  uses to wrap each component example with explanatory copy.

  When the harness extracts a top-level chelekom invocation from a
  demo, the captured snippet may reference these wrappers in passing —
  e.g., `<.card><.cp>This is a card</.cp></.card>` puts a `<.cp>`
  inside a chelekom block. Without stubs, EEx compile fails with
  "function cp/1 is undefined".

  We don't try to FAITHFULLY reproduce the docs site's rendering — we
  just need each helper to exist with the right arity and accept a
  slot, returning either the inner_block content or empty. The render
  output isn't asserted on; only "does it explode" is.

  Add a new helper here when the harness reports `function X/N is
  undefined (there is no such import)` and X looks like a docs-page
  wrapper rather than a real chelekom component.
  """

  use Phoenix.Component

  attr(:rest, :global)
  slot(:inner_block)

  def cp(assigns) do
    ~H"""
    <p {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  attr(:rest, :global)
  slot(:inner_block)

  def heading2(assigns) do
    ~H"""
    <h2 {@rest}>{render_slot(@inner_block)}</h2>
    """
  end

  attr(:rest, :global)
  slot(:inner_block)

  def heading3(assigns) do
    ~H"""
    <h3 {@rest}>{render_slot(@inner_block)}</h3>
    """
  end

  attr(:rest, :global)
  slot(:inner_block)

  def custom_inline_code(assigns) do
    ~H"""
    <code {@rest}>{render_slot(@inner_block)}</code>
    """
  end

  attr(:rest, :global)
  slot(:inner_block)

  def custom_code_wrapper(assigns) do
    ~H"""
    <div {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  attr(:rest, :global)
  slot(:inner_block)

  def custom_info(assigns) do
    ~H"""
    <div {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  attr(:rest, :global)
  slot(:inner_block)

  def custom_nav(assigns) do
    ~H"""
    <nav {@rest}>{render_slot(@inner_block)}</nav>
    """
  end

  attr(:rest, :global)
  slot(:inner_block)
  slot(:documentation_panel)
  slot(:props_panel)

  def custom_tab(assigns) do
    ~H"""
    <div {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  attr(:rest, :global)

  def custom_separator(assigns), do: ~H|<hr {@rest} />|
end
