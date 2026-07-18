defmodule DevelopmentWeb.Components.Headless.TreeSelect do
  @moduledoc """
  Headless **tree select** — a disclosure that shows a selected value and opens a `tree` in a popover
  (Mantine TreeSelect parity).

  This is a thin shell: it renders a `trigger` (showing `label` or `placeholder`) that toggles the
  `panel` with JS commands (no hook), and a default slot where you drop a `<.tree>`. Wire the tree's
  `on_select` to your LiveView to update the shown label and a hidden form field — the tree owns all
  of its own keyboard and selection behaviour. Pass `open` to render the panel expanded.

  Ships **no** styling — style via `chelekom-tree-select*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/tree_select
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id"
  attr :label, :string, default: nil, doc: "Currently selected label"
  attr :placeholder, :string, default: "Select…", doc: "Shown when nothing is selected"
  attr :open, :boolean, default: false, doc: "Render the panel expanded"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :trigger_class, :any, default: nil, doc: "Extra classes for the trigger"
  attr :value_class, :any, default: nil, doc: "Extra classes for the value label"
  attr :panel_class, :any, default: nil, doc: "Extra classes for the panel"
  attr :rest, :global

  slot :inner_block, required: true, doc: "The tree (and anything else) to show in the panel"

  def tree_select(assigns) do
    ~H"""
    <div id={@id} data-part="root" class={["chelekom-tree-select", @class]} {@rest}>
      <button
        type="button"
        data-part="trigger"
        phx-click={JS.toggle(to: "##{@id}-panel")}
        aria-haspopup="tree"
        aria-expanded={to_string(@open)}
        aria-controls={"#{@id}-panel"}
        class={["chelekom-tree-select__trigger", @trigger_class]}
      >
        <span data-part="value" data-placeholder={@label in [nil, ""] && "true"} class={["chelekom-tree-select__value", @value_class]}>
          {(@label not in [nil, ""] && @label) || @placeholder}
        </span>
        <span data-part="caret" aria-hidden="true">▾</span>
      </button>
      <div
        id={"#{@id}-panel"}
        data-part="panel"
        role="dialog"
        style={!@open && "display:none"}
        class={["chelekom-tree-select__panel", @panel_class]}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
