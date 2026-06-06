defmodule MishkaChelekom.MCP.Resources.ListHeadlessComponents do
  @moduledoc """
  List the headless (unstyled + ARIA) Mishka Chelekom components, read dynamically from
  `priv/headless/*.exs`. Each entry includes its WAI-ARIA pattern, the JS behavior hooks it
  uses, its named-slot anatomy, and the `data-*` state attributes.
  """

  use Anubis.Server.Component,
    type: :resource,
    uri: "mishka_chelekom://headless",
    name: "list_headless_components",
    description:
      "List headless (unstyled + ARIA) components with their WAI-ARIA pattern, JS hooks, anatomy and data-* state",
    mime_type: "text/plain"

  alias Anubis.Server.Response
  alias MishkaChelekom.Generators.Core

  @impl true
  def read(_params, frame) do
    {:reply, Response.resource() |> Response.text(summary()), frame}
  end

  @doc false
  def summary do
    components = load_all()

    sections =
      components
      |> Enum.sort_by(& &1.name)
      |> Enum.map(&render_component/1)
      |> Enum.join("\n")

    """
    # Mishka Chelekom — Headless components (#{length(components)})

    Unstyled markup + full WAI-ARIA wiring + a shared JS behavior core. They ship **no** colors
    or spacing — style the `chelekom-<comp>__<part>` classes and `data-*` state.

    Generate: `mix mishka.ui.gen.headless <name>` (or `mix mishka.ui.gen.headless.components` for all).
    Output:   `lib/<app>_web/components/headless/<name>.ex`

    #{sections}
    ---
    JS engines live in `priv/assets/js/` (FocusTrap, Disclosure, RovingTabindex, Popup) and are
    wired automatically by the generator. State uses paired-presence attributes
    (`data-open`/`data-closed`, `data-highlighted`, …) — never `data-state="open"`.
    """
  end

  defp render_component(c) do
    hooks = c.hooks |> Enum.join(", ")
    states = c.state_attributes |> Enum.join(", ")

    """
    ## #{c.name}
    - Pattern: #{c.pattern}
    - JS hooks: #{hooks}
    - State: #{states}
    - Parts: #{c.parts}
    - Docs: #{c.doc_url}
    """
  end

  defp load_all do
    Core.template_dir(:headless)
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.map(&load/1)
    |> Enum.reject(&is_nil/1)
  end

  defp load(path) do
    name = Path.basename(path, ".exs")
    {term, _} = Code.eval_file(path)
    cfg = term[String.to_atom(name)]

    if cfg do
      aria = cfg[:aria_pattern] || []
      anatomy = cfg[:anatomy] || []

      parts =
        (anatomy[:parts] || []) |> Keyword.keys() |> Enum.map(&to_string/1) |> Enum.join(", ")

      %{
        name: name,
        doc_url: cfg[:doc_url],
        pattern: aria[:pattern] || "—",
        hooks: cfg[:hooks] || [],
        state_attributes: cfg[:state_attributes] || [],
        parts: parts
      }
    end
  rescue
    _ -> nil
  end
end
