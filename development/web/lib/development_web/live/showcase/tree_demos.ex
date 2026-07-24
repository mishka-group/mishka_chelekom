defmodule DevelopmentWeb.Showcase.TreeDemos do
  @moduledoc """
  Every server-driven situation for the headless `tree`, in one LiveComponent so the examples
  section of `/showcase/headless/tree` can render them live rather than describe them.

  Covers: a controller (the server driving expansion/checked state), a permissions **form** that
  posts natively, a single **click → one handle_event**, async child loading, drag & drop, and
  search. Every tree is scoped to this component's own DOM id, so several can coexist on the page
  without their events colliding.

  Headless ships no CSS — every class here is showcase-only.
  """
  use DevelopmentWeb, :live_component

  alias DevelopmentWeb.Components.Headless.Tree

  # One showcase skin, shared with the preview above — headless ships no CSS.
  defdelegate tree_class(), to: DevelopmentWeb.Showcase.HeadlessPreview

  @data [
    %{
      label: "src",
      value: "src",
      children: [
        %{
          label: "components",
          value: "src/components",
          children: [
            %{label: "Accordion.tsx", value: "src/components/Accordion.tsx"},
            %{label: "Tree.tsx", value: "src/components/Tree.tsx"},
            %{label: "Button.tsx", value: "src/components/Button.tsx"}
          ]
        }
      ]
    },
    %{
      label: "node_modules",
      value: "node_modules",
      children: [
        %{
          label: "react",
          value: "node_modules/react",
          children: [
            %{label: "index.d.ts", value: "node_modules/react/index.d.ts"},
            %{label: "package.json", value: "node_modules/react/package.json"}
          ]
        }
      ]
    },
    %{label: "package.json", value: "package.json"},
    %{label: "tsconfig.json", value: "tsconfig.json"}
  ]

  @permissions [
    %{
      label: "Content",
      value: "content",
      children: [
        %{label: "Read posts", value: "content:read"},
        %{label: "Write posts", value: "content:write"},
        %{label: "Delete posts", value: "content:delete", disabled: true}
      ]
    },
    %{
      label: "Users",
      value: "users",
      children: [
        %{label: "Invite users", value: "users:invite"},
        %{label: "Edit roles", value: "users:roles"}
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
  ]

  @async [
    %{label: "Lazy folder", value: "async/lazy", has_children: true},
    %{label: "Another lazy folder", value: "async/lazy-2", has_children: true},
    %{label: "readme.md", value: "async/readme.md"}
  ]

  # A LiveComponent cannot receive messages, so the delayed "fetch" comes back through
  # `send_update/3` rather than a `handle_info` the parent LiveView would have to know about.
  @impl true
  def update(%{async_loaded: value}, socket) do
    children = [
      %{label: "loaded-a.txt", value: "#{value}/a.txt"},
      %{label: "loaded-b.txt", value: "#{value}/b.txt"},
      %{label: "nested", value: "#{value}/nested", has_children: true}
    ]

    {:ok,
     socket
     |> assign(async: put_children(socket.assigns.async, value, children))
     |> log("loaded #{value}")
     |> push_event("tree:#{socket.assigns.id}-async:children", %{value: value})}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:data, fn -> @data end)
     |> assign_new(:permissions, fn -> @permissions end)
     |> assign_new(:async, fn -> @async end)
     |> assign_new(:dnd, fn -> @data end)
     |> assign_new(:expanded, fn -> ["src"] end)
     |> assign_new(:checked, fn -> [] end)
     |> assign_new(:form_checked, fn -> ["content:read", "billing:read"] end)
     |> assign_new(:saved, fn -> nil end)
     |> assign_new(:opened, fn -> nil end)
     |> assign_new(:opened_at, fn -> nil end)
     |> assign_new(:query, fn -> "" end)
     |> assign_new(:filtered, fn -> @data end)
     |> assign_new(:log, fn -> [] end)
     |> assign_new(:open, fn -> MapSet.new(["controller"]) end)}
  end

  # `<details open>` is uncontrolled DOM state: the browser sets it, the server never renders it,
  # so morphdom strips it on the next patch and every section slams shut the moment any button is
  # clicked. Track it instead — the native toggle and this event agree, so they never fight.
  @impl true
  def handle_event("toggle_section", %{"key" => key}, socket) do
    open = socket.assigns.open

    {:noreply,
     assign(socket,
       open:
         if(MapSet.member?(open, key), do: MapSet.delete(open, key), else: MapSet.put(open, key))
     )}
  end

  def handle_event("expand_all", _params, socket), do: {:noreply, assign(socket, expanded: :all)}
  def handle_event("collapse_all", _params, socket), do: {:noreply, assign(socket, expanded: [])}

  def handle_event("check_all", _params, socket),
    do: {:noreply, assign(socket, checked: leaf_values(@data))}

  def handle_event("uncheck_all", _params, socket), do: {:noreply, assign(socket, checked: [])}

  def handle_event("expanded", %{"value" => value}, socket),
    do: {:noreply, log(socket, "expand: #{value}")}

  def handle_event("collapsed", %{"value" => value}, socket),
    do: {:noreply, log(socket, "collapse: #{value}")}

  def handle_event("checked", %{"values" => values}, socket),
    do: {:noreply, socket |> assign(checked: values) |> log("check: #{length(values)} node(s)")}

  def handle_event("form_checked", %{"values" => values}, socket),
    do: {:noreply, assign(socket, form_checked: values)}

  # The checkboxes carry `name="permissions[]"`, so this is an ordinary form submit — the values
  # arrive in params with no JS involvement.
  def handle_event("save", params, socket) do
    {:noreply,
     socket
     |> assign(saved: params["permissions"] || [])
     |> log("submit: #{length(params["permissions"] || [])} permission(s)")}
  end

  def handle_event("form_changed", params, socket),
    do: {:noreply, assign(socket, form_checked: params["permissions"] || [])}

  def handle_event("opened", %{"values" => [value | _]}, socket) do
    {:noreply,
     socket
     |> assign(opened: value, opened_at: Time.utc_now() |> Time.truncate(:second))
     |> log("opened: #{value}")}
  end

  def handle_event("opened", %{"values" => []}, socket),
    do: {:noreply, assign(socket, opened: nil, opened_at: nil)}

  def handle_event("load_children", %{"value" => value}, socket) do
    id = socket.assigns.id
    parent = self()

    # The delay is what makes the loading state visible; a real app would query here.
    Task.start(fn ->
      Process.sleep(700)
      send_update(parent, __MODULE__, id: id, async_loaded: value)
    end)

    {:noreply, log(socket, "loading #{value}…")}
  end

  def handle_event("dropped", %{"dragged" => d, "target" => t, "position" => p}, socket) do
    {:noreply,
     socket |> assign(dnd: move_node(socket.assigns.dnd, d, t, p)) |> log("moved #{d} #{p} #{t}")}
  end

  def handle_event("search", %{"query" => query}, socket),
    do: {:noreply, assign(socket, query: query, filtered: filter_tree(@data, query))}

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="space-y-3">
      <details
        open={MapSet.member?(@open, "controller")}
        class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4"
      >
        <summary
          phx-click="toggle_section"
          phx-value-key="controller"
          phx-target={@myself}
          class="cursor-pointer select-none font-medium"
        >
          Controller — the server drives expansion and checked state
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          <code>expanded</code>
          and <code>checked</code>
          are just assigns. The tree publishes what the server asked for, and the hook hands control
          back whenever the server changes its mind.
        </p>
        <div class="mt-3 flex flex-wrap gap-2">
          <button
            :for={
              {event, label} <- [
                {"expand_all", "Expand all"},
                {"collapse_all", "Collapse all"},
                {"check_all", "Check all"},
                {"uncheck_all", "Uncheck all"}
              ]
            }
            phx-click={event}
            phx-target={@myself}
            class="rounded border border-[var(--c-base-300)] px-2 py-1 text-xs hover:bg-[var(--c-base-200)]"
          >
            {label}
          </button>
        </div>
        <div class="mt-3">
          <Tree.tree
            id={"#{@id}-controller"}
            nodes={@data}
            expanded={@expanded}
            checked={@checked}
            with_checkboxes
            aria_label="Controlled file tree"
            on_expand="expanded"
            on_collapse="collapsed"
            on_check="checked"
            on_target={"##{@id}"}
            class={tree_class()}
          >
            <:expand_icon>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M6 12V4l4.5 4z" />
              </svg>
            </:expand_icon>
          </Tree.tree>
        </div>
      </details>

      <details
        open={MapSet.member?(@open, "form")}
        class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4"
      >
        <summary
          phx-click="toggle_section"
          phx-value-key="form"
          phx-target={@myself}
          class="cursor-pointer select-none font-medium"
        >
          In a form — pre-checked, cascade, submits natively
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          Each node's checkbox carries <code>name="permissions[]"</code>, so a plain
          <code>phx-submit</code>
          receives them — no JS glue. Ticking a group cascades to its children; a partly-ticked group
          shows the indeterminate state and is never submitted itself. "Delete posts" is <code>disabled</code>: the cascade skips it.
        </p>
        <form
          id={"#{@id}-permissions-form"}
          phx-submit="save"
          phx-change="form_changed"
          phx-target={@myself}
          class="mt-3 space-y-3"
        >
          <Tree.tree
            id={"#{@id}-form"}
            nodes={@permissions}
            expanded={:all}
            with_checkboxes
            name="permissions[]"
            checked={@form_checked}
            aria_label="Permissions"
            on_check="form_checked"
            on_target={"##{@id}"}
            class={tree_class()}
          >
            <:expand_icon>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M6 12V4l4.5 4z" />
              </svg>
            </:expand_icon>
          </Tree.tree>
          <div class="flex items-center gap-3 border-t border-[var(--c-base-300)] pt-3">
            <button
              type="submit"
              class="rounded bg-[var(--c-primary)] px-3 py-1 text-xs font-medium text-white"
            >
              Save permissions
            </button>
            <span class="text-xs text-[var(--c-base-content)]/50">
              {length(@form_checked)} selected
            </span>
          </div>
        </form>
        <div :if={@saved} class="mt-3 rounded bg-[var(--c-base-200)] p-3 text-xs">
          <div class="mb-1 font-semibold">params["permissions"]</div>
          <pre class="whitespace-pre-wrap break-all">{inspect(@saved, pretty: true)}</pre>
        </div>
      </details>

      <details
        open={MapSet.member?(@open, "click")}
        class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4"
      >
        <summary
          phx-click="toggle_section"
          phx-value-key="click"
          phx-target={@myself}
          class="cursor-pointer select-none font-medium"
        >
          One click → one handle_event
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          The smallest wiring there is: <code>select_on_click</code>
          + <code>on_select</code>. Click a file and watch what the server receives.
        </p>
        <div class="mt-3 grid gap-3 sm:grid-cols-2">
          <Tree.tree
            id={"#{@id}-click"}
            nodes={@data}
            expanded={:all}
            select_on_click
            aria_label="Open a file"
            on_select="opened"
            on_target={"##{@id}"}
            class={tree_class()}
          >
            <:expand_icon>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M6 12V4l4.5 4z" />
              </svg>
            </:expand_icon>
          </Tree.tree>
          <div class="rounded bg-[var(--c-base-200)] p-3 text-xs">
            <div class="mb-1 font-semibold text-[var(--c-base-content)]/60">Server received</div>
            <div :if={!@opened} class="text-[var(--c-base-content)]/40">Click a file…</div>
            <div :if={@opened} class="space-y-1">
              <div>event: <code>opened</code></div>
              <div>value: <code>{@opened}</code></div>
              <div>at: {@opened_at}</div>
            </div>
          </div>
        </div>
      </details>

      <details
        open={MapSet.member?(@open, "async")}
        class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4"
      >
        <summary
          phx-click="toggle_section"
          phx-value-key="async"
          phx-target={@myself}
          class="cursor-pointer select-none font-medium"
        >
          Async children — loaded on first expand
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A node with <code>has_children: true</code>
          and no children asks the server once, then the server pushes
          <code>tree:&lt;id&gt;:children</code>
          back.
        </p>
        <div class="mt-3">
          <Tree.tree
            id={"#{@id}-async"}
            nodes={@async}
            aria_label="Lazy tree"
            on_load_children="load_children"
            on_target={"##{@id}"}
            class={tree_class()}
          >
            <:expand_icon>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M6 12V4l4.5 4z" />
              </svg>
            </:expand_icon>
          </Tree.tree>
        </div>
      </details>

      <details
        open={MapSet.member?(@open, "dnd")}
        class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4"
      >
        <summary
          phx-click="toggle_section"
          phx-value-key="dnd"
          phx-target={@myself}
          class="cursor-pointer select-none font-medium"
        >
          Drag &amp; drop — the server owns the data
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          A line between two rows means <em>reorder</em>; a filled row means <em>drop inside</em>.
          The hook only reports <code>dragged</code>, <code>target</code>
          and <code>position</code>; moving the node — and refusing to drop one into its own
          descendant — is the server's job.
        </p>
        <p class="mt-1 text-xs text-[var(--c-base-content)]/40">
          Zones follow Mantine: a leaf splits in half (above / below); a collapsed folder gets three
          (above / inside / below); an <strong>expanded</strong>
          folder gets only two (above / inside) — its children already sit below it, so a line there
          would be ambiguous. To drop below an expanded folder, aim just above the next row.
        </p>
        <div class="mt-3">
          <Tree.tree
            id={"#{@id}-dnd"}
            nodes={@dnd}
            expanded={:all}
            draggable
            aria_label="Reorderable tree"
            on_drag_drop="dropped"
            on_target={"##{@id}"}
            class={tree_class()}
          >
            <:expand_icon>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M6 12V4l4.5 4z" />
              </svg>
            </:expand_icon>
          </Tree.tree>
        </div>
      </details>

      <details
        open={MapSet.member?(@open, "search")}
        class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-100)] p-4"
      >
        <summary
          phx-click="toggle_section"
          phx-value-key="search"
          phx-target={@myself}
          class="cursor-pointer select-none font-medium"
        >
          Search — filter server-side, keep the path
        </summary>
        <p class="mt-1 text-sm text-[var(--c-base-content)]/60">
          No client filtering: a match keeps its ancestors so the path stays visible.
        </p>
        <form id={"#{@id}-search-form"} phx-change="search" phx-target={@myself} class="mt-3 max-w-xs">
          <input
            type="text"
            name="query"
            value={@query}
            placeholder="Try “package” or “tsx”…"
            autocomplete="off"
            class="w-full rounded border border-[var(--c-base-300)] bg-[var(--c-base-100)] px-2 py-1 text-sm"
          />
        </form>
        <div class="mt-3">
          <p :if={@filtered == []} class="text-sm text-[var(--c-base-content)]/40">Nothing found</p>
          <Tree.tree
            :if={@filtered != []}
            id={"#{@id}-search"}
            nodes={@filtered}
            expanded={:all}
            aria_label="Search results"
            class={tree_class()}
          >
            <:expand_icon>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M6 12V4l4.5 4z" />
              </svg>
            </:expand_icon>
          </Tree.tree>
        </div>
      </details>

      <div class="rounded-lg border border-[var(--c-base-300)] bg-[var(--c-base-200)]/50 p-3">
        <div class="mb-1 text-xs font-semibold uppercase tracking-wide text-[var(--c-base-content)]/40">
          Event log
        </div>
        <ul class="max-h-32 space-y-0.5 overflow-auto font-mono text-[11px]">
          <li :if={@log == []} class="text-[var(--c-base-content)]/40">
            Interact with a tree above…
          </li>
          <li :for={entry <- @log}>{entry}</li>
        </ul>
      </div>
    </div>
    """
  end

  defp log(socket, message),
    do: assign(socket, log: Enum.take([message | socket.assigns.log], 8))

  defp put_children(nodes, value, children) do
    Enum.map(nodes, fn node ->
      cond do
        node.value == value ->
          Map.put(node, :children, children)

        is_list(node[:children]) ->
          Map.put(node, :children, put_children(node.children, value, children))

        true ->
          node
      end
    end)
  end

  defp leaf_values(nodes) do
    Enum.flat_map(nodes, fn node ->
      case node[:children] || [] do
        [] -> [node.value]
        children -> leaf_values(children)
      end
    end)
  end

  defp filter_tree(nodes, ""), do: nodes

  defp filter_tree(nodes, query) do
    needle = String.downcase(query)

    Enum.flat_map(nodes, fn node ->
      kids = filter_tree(node[:children] || [], query)
      hit? = String.contains?(String.downcase(to_string(node.label)), needle)

      cond do
        kids != [] -> [Map.put(node, :children, kids)]
        hit? -> [Map.delete(node, :children)]
        true -> []
      end
    end)
  end

  defp move_node(nodes, dragged, target, position) do
    if descendant?(nodes, dragged, target) do
      nodes
    else
      {without, node} = pop_node(nodes, dragged)
      (node && insert_node(without, node, target, position)) || nodes
    end
  end

  defp descendant?(nodes, ancestor, value) do
    case find_node(nodes, ancestor) do
      nil -> false
      node -> value in flat_values(node[:children] || [])
    end
  end

  defp find_node(nodes, value) do
    Enum.find_value(nodes, fn node ->
      cond do
        node.value == value -> node
        is_list(node[:children]) -> find_node(node.children, value)
        true -> nil
      end
    end)
  end

  defp flat_values(nodes),
    do: Enum.flat_map(nodes, fn node -> [node.value | flat_values(node[:children] || [])] end)

  defp pop_node(nodes, value) do
    Enum.reduce(nodes, {[], nil}, fn node, {acc, found} ->
      cond do
        node.value == value ->
          {acc, node}

        is_list(node[:children]) ->
          {kids, inner} = pop_node(node.children, value)
          {acc ++ [Map.put(node, :children, kids)], found || inner}

        true ->
          {acc ++ [node], found}
      end
    end)
  end

  defp insert_node(nodes, node, target, "inside") do
    Enum.map(nodes, fn item ->
      cond do
        item.value == target ->
          Map.put(item, :children, (item[:children] || []) ++ [node])

        is_list(item[:children]) ->
          Map.put(item, :children, insert_node(item.children, node, target, "inside"))

        true ->
          item
      end
    end)
  end

  defp insert_node(nodes, node, target, position) do
    if Enum.any?(nodes, &(&1.value == target)) do
      Enum.flat_map(nodes, fn item ->
        cond do
          item.value != target -> [item]
          position == "before" -> [node, item]
          true -> [item, node]
        end
      end)
    else
      Enum.map(nodes, fn item ->
        if is_list(item[:children]),
          do: Map.put(item, :children, insert_node(item.children, node, target, position)),
          else: item
      end)
    end
  end
end
