defmodule MishkaMob.Showcase.Components.Accordion do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaAccordion`.

  Each example owns a separate open set in the screen's assigns and a separate
  `on_toggle` tag, so opening a panel in one example never disturbs another —
  and each demonstrates a different mode of the headless component
  (`multiple`, `collapsible`, per-item `disabled`).
  """
  use MishkaMob.Showcase

  import Mob.Sigil

  alias MishkaMob.Components.MishkaAccordion
  alias MishkaMob.Showcase.Example

  @impl true
  def entry do
    %{
      slug: :accordion,
      name: "Accordion",
      category: "Disclosure",
      order: 0,
      description: "Stacked disclosure items where each header toggles its panel."
    }
  end

  @impl true
  def mount(socket) do
    socket
    |> Mob.Socket.assign(:acc_faq, [:what])
    |> Mob.Socket.assign(:acc_multi, [:beam, :native])
    |> Mob.Socket.assign(:acc_locked, [:always])
    |> Mob.Socket.assign(:acc_disabled, [])
    |> Mob.Socket.assign(:acc_watched, [])
    |> Mob.Socket.assign(:acc_log, [])
  end

  @impl true
  def examples do
    [
      %Example{
        title: "One at a time",
        description: "The default: opening a panel closes the others.",
        code: ~S"""
        <MishkaAccordion open={@faq} on_toggle={:toggle_faq}>
          <MishkaAccordionItem id={:what} title="What is Mishka Chelekom?">
            {text("A component library for Phoenix — and now for Mob.")}
          </MishkaAccordionItem>
          <MishkaAccordionItem id={:styled} title="Is it styled?">
            ...
          </MishkaAccordionItem>
        </MishkaAccordion>

        # the screen owns the open set; toggle/3 applies the semantics
        def handle_info({:tap, {:toggle_faq, id}}, socket) do
          {:noreply, assign(socket, :faq, MishkaAccordion.toggle(socket.assigns.faq, id))}
        end
        """,
        render: fn assigns ->
          ~MOB"""
          <MishkaAccordion open={@acc_faq} on_toggle={:toggle_faq}>
            <MishkaAccordionItem id={:what} title="What is Mishka Chelekom?">
              {body("A component library for Phoenix — and now a native port for Mob.")}
            </MishkaAccordionItem>
            <MishkaAccordionItem id={:styled} title="Is it styled?">
              {body("The headless version ships behaviour only. This native port maps that behaviour onto theme tokens.")}
            </MishkaAccordionItem>
            <MishkaAccordionItem id={:native} title="Is this real native UI?">
              {body("Yes — it expands to SwiftUI / Jetpack Compose widgets. No WebView.")}
            </MishkaAccordionItem>
          </MishkaAccordion>
          """
        end
      },
      %Example{
        title: "Multiple open",
        description: "Set multiple to let panels open independently.",
        code: ~S"""
        <MishkaAccordion open={@open} multiple={true} on_toggle={:toggle_multi}>
          ...
        </MishkaAccordion>

        MishkaAccordion.toggle(open, id, multiple: true)
        """,
        render: fn assigns ->
          ~MOB"""
          <MishkaAccordion open={@acc_multi} multiple={true} on_toggle={:toggle_multi}>
            <MishkaAccordionItem id={:beam} title="The BEAM runs on the device">
              {body("Your Elixir runs on the phone itself — screens are GenServers.")}
            </MishkaAccordionItem>
            <MishkaAccordionItem id={:native} title="Widgets are native">
              {body("Node maps become real platform widgets, so scrolling and text feel native.")}
            </MishkaAccordionItem>
            <MishkaAccordionItem id={:hot} title="Code can be hot-pushed">
              {body("mix mob.deploy pushes new BEAMs to the running app.")}
            </MishkaAccordionItem>
          </MishkaAccordion>
          """
        end
      },
      %Example{
        title: "Always one open (collapsible: false)",
        description: "The open panel cannot be closed by its own trigger.",
        code: ~S"""
        <MishkaAccordion open={@open} collapsible={false} on_toggle={:toggle_locked}>
          ...
        </MishkaAccordion>

        MishkaAccordion.toggle(open, id, collapsible: false)
        """,
        render: fn assigns ->
          ~MOB"""
          <MishkaAccordion open={@acc_locked} collapsible={false} on_toggle={:toggle_locked}>
            <MishkaAccordionItem id={:always} title="This one starts open">
              {body("Tapping this header again will not close it — something must stay open.")}
            </MishkaAccordionItem>
            <MishkaAccordionItem id={:other} title="Tap me instead">
              {body("Opening another item moves the selection, because multiple is still false.")}
            </MishkaAccordionItem>
          </MishkaAccordion>
          """
        end
      },
      %Example{
        title: "Disabled item",
        description: "A disabled item is inert — it renders muted and wires no tap.",
        code: ~S"""
        <MishkaAccordion open={@open} on_toggle={:toggle_disabled}>
          <MishkaAccordionItem id={:ok} title="I work" >...</MishkaAccordionItem>
          <MishkaAccordionItem id={:nope} title="I am disabled" disabled={true}>
            ...
          </MishkaAccordionItem>
        </MishkaAccordion>
        """,
        render: fn assigns ->
          ~MOB"""
          <MishkaAccordion open={@acc_disabled} on_toggle={:toggle_disabled}>
            <MishkaAccordionItem id={:ok} title="I open normally">
              {body("Nothing special about this one.")}
            </MishkaAccordionItem>
            <MishkaAccordionItem id={:nope} title="I am disabled" disabled={true}>
              {body("You should not be able to reach this text.")}
            </MishkaAccordionItem>
          </MishkaAccordion>
          """
        end
      },
      %Example{
        title: "Knowing which way it went",
        description:
          "on_toggle says WHICH trigger, not which way. on_open_change adds the " <>
            "state after the tap, and on_value_change hands you the whole open set " <>
            "already resolved. All three are optional — pick one.",
        code: ~S"""
        # on_toggle — which trigger. The screen works the rest out itself.
        <MishkaAccordion open={@open} on_toggle={:toggled} />
        def handle_info({:tap, {:toggled, id}}, socket) do
          {:noreply, assign(socket, :open, MishkaAccordion.toggle(socket.assigns.open, id))}
        end

        # on_open_change — …and which WAY. Use it to load a panel body lazily,
        # or to fire analytics only on close.
        <MishkaAccordion open={@open} on_open_change={:changed} />
        def handle_info({:tap, {:changed, id, true}}, socket), do: {:noreply, load(socket, id)}
        def handle_info({:tap, {:changed, _id, false}}, socket), do: {:noreply, socket}

        # on_value_change — the least work. The payload IS the next open set,
        # computed with the same toggle/3, so the handler is a bare assign and
        # cannot drift from the component's multiple / collapsible semantics.
        <MishkaAccordion open={@open} multiple={true} on_value_change={:opened} />
        def handle_info({:tap, {:opened, next}}, socket) do
          {:noreply, assign(socket, :open, next)}
        end
        """,
        render: fn assigns ->
          # No on_toggle here: on_open_change is an alternative to it, not an
          # addition — a tap can only send one message.
          ~MOB"""
          <Column fill_width={true}>
            <MishkaAccordion open={@acc_watched} multiple={true} on_open_change={:acc_watch}>
              <MishkaAccordionItem id={:shipping} title="Shipping">
                {body("Open and close these — the log below records both.")}
              </MishkaAccordionItem>
              <MishkaAccordionItem id={:returns} title="Returns">
                {body("on_open_change carries the state AFTER the tap.")}
              </MishkaAccordionItem>
            </MishkaAccordion>
            <Spacer size={12} />
            <Text text={log_label(@acc_log)} text_size={:sm} text_color={:muted} />
          </Column>
          """
        end
      }
    ]
  end

  @impl true
  def props do
    [
      %{
        name: "open",
        type: "list of item ids",
        default: "[]",
        description: "The open set. Lives in the screen — composites are stateless."
      },
      %{
        name: "multiple",
        type: "boolean",
        default: "false",
        description: "Allow several panels open at once; when false, opening one closes the rest."
      },
      %{
        name: "collapsible",
        type: "boolean",
        default: "true",
        description: "Allow the open item to be closed by its own trigger."
      },
      %{
        name: "disabled",
        type: "boolean",
        default: "false",
        description: "Disable every trigger. Cascades to all items."
      },
      %{
        name: "on_toggle",
        type: "event tag",
        default: "—",
        description: "Sent as {:tap, {tag, item_id}}, so one handler serves every item."
      },
      %{
        name: "chevron",
        type: "boolean",
        default: "true",
        description: "Show the ▸/▾ state indicator on each header."
      },
      %{
        name: "background",
        type: "color / ARGB",
        default: ":surface_raised",
        description: "Item background."
      },
      %{
        name: "corner_radius",
        type: "radius / number",
        default: ":radius_md",
        description: "Rounds each item."
      },
      %{
        name: "padding",
        type: "spacing / number",
        default: ":space_md",
        description: "Padding inside the trigger and the panel."
      },
      %{
        name: "space",
        type: "number",
        default: "8",
        description: "Gap between items. Use 0 to join them into one block."
      },
      %{
        name: "color",
        type: "color / ARGB",
        default: ":on_surface",
        description: "Item title and chevron. Set it whenever you set background."
      },
      %{
        name: "on_open_change",
        type: "event tag",
        default: "—",
        description: "{:tap, {tag, id, open?}} — open? is the state AFTER the tap."
      },
      %{
        name: "on_value_change",
        type: "event tag",
        default: "—",
        description: "{:tap, {tag, next_open_set}} — already resolved. One of the three wins."
      },
      %{
        name: "item.id / .title / .disabled",
        type: "term / string / boolean",
        default: "index / — / false",
        description: "Per item. id falls back to its 0-based position."
      }
    ]
  end

  @impl true
  def handle({:toggle_faq, id}, socket), do: put(socket, :acc_faq, id, [])
  def handle({:toggle_multi, id}, socket), do: put(socket, :acc_multi, id, multiple: true)
  def handle({:toggle_locked, id}, socket), do: put(socket, :acc_locked, id, collapsible: false)
  def handle({:toggle_disabled, id}, socket), do: put(socket, :acc_disabled, id, [])

  # Three-element tag: the item AND the state after the tap. That direction is
  # the whole point — on_toggle cannot tell an open from a close.
  def handle({:acc_watch, id, open?}, socket) do
    next = MishkaAccordion.toggle(socket.assigns.acc_watched, id, multiple: true)

    socket
    |> Mob.Socket.assign(:acc_watched, next)
    |> Mob.Socket.assign(:acc_log, Enum.take([{id, open?} | socket.assigns.acc_log], 3))
  end

  def handle(_tag, socket), do: socket

  defp log_label([]), do: "Nothing yet — open or close a panel above."

  defp log_label(entries) do
    "Last: " <>
      Enum.map_join(entries, ", ", fn {id, open?} ->
        "#{id} #{if open?, do: "opened", else: "closed"}"
      end)
  end

  defp put(socket, key, id, opts) do
    next = MishkaAccordion.toggle(Map.fetch!(socket.assigns, key), id, opts)
    Mob.Socket.assign(socket, key, next)
  end

  @impl true
  def card_preview do
    %{
      type: :column,
      props: %{fill_width: true},
      children: [
        bar(:muted),
        gap(6),
        # the "expanded" item: header + a taller panel block
        bar(:muted),
        gap(3),
        %{
          type: :box,
          props: %{
            fill_width: true,
            height: 22,
            background: :surface_raised,
            corner_radius: :radius_sm
          },
          children: []
        },
        gap(6),
        bar(:muted)
      ]
    }
  end

  # The panel body — the one thing every item has in common, and the only part
  # worth a helper. Everything else is written as markup at the call site,
  # because the props that vary between the examples ARE what each example is
  # demonstrating, and a builder that takes them as a map hides exactly that.
  defp body(text), do: ~MOB(<Text text={text} text_size={:base} text_color={:muted} />)

  defp bar(color) do
    %{
      type: :box,
      props: %{fill_width: true, height: 10, background: color, corner_radius: :radius_sm},
      children: []
    }
  end

  defp gap(n), do: %{type: :spacer, props: %{size: n}, children: []}
end
