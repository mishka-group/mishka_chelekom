defmodule MishkaMob.Showcase.Components.Accordion do
  @moduledoc """
  Gallery entry for `MishkaMob.Components.MishkaAccordion`.

  Each example owns a separate open set in the screen's assigns and a separate
  `on_toggle` tag, so opening a panel in one example never disturbs another —
  and each demonstrates a different mode of the headless component
  (`multiple`, `collapsible`, per-item `disabled`).
  """
  use MishkaMob.Showcase

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
          accordion(assigns.acc_faq, :toggle_faq, [
            {:what, "What is Mishka Chelekom?",
             "A component library for Phoenix — and now a native port for Mob."},
            {:styled, "Is it styled?",
             "The headless version ships behaviour only. This native port maps that behaviour onto theme tokens."},
            {:native, "Is this real native UI?",
             "Yes — it expands to SwiftUI / Jetpack Compose widgets. No WebView."}
          ])
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
          accordion(
            assigns.acc_multi,
            :toggle_multi,
            [
              {:beam, "The BEAM runs on the device",
               "Your Elixir runs on the phone itself — screens are GenServers."},
              {:native, "Widgets are native",
               "Node maps become real platform widgets, so scrolling and text feel native."},
              {:hot, "Code can be hot-pushed",
               "mix mob.deploy pushes new BEAMs to the running app."}
            ],
            %{multiple: true}
          )
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
          accordion(
            assigns.acc_locked,
            :toggle_locked,
            [
              {:always, "This one starts open",
               "Tapping this header again will not close it — something must stay open."},
              {:other, "Tap me instead",
               "Opening another item moves the selection, because multiple is still false."}
            ],
            %{collapsible: false}
          )
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
          accordion(assigns.acc_disabled, :toggle_disabled, [
            {:ok, "I open normally", "Nothing special about this one."},
            {:nope, "I am disabled", "You should not be able to reach this text.", true}
          ])
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
          %{
            type: :column,
            props: %{fill_width: true},
            children: [
              accordion_with(
                assigns.acc_watched,
                %{multiple: true, on_open_change: :acc_watch},
                [
                  {:shipping, "Shipping", "Open and close these — the log below records both."},
                  {:returns, "Returns", "on_open_change carries the state AFTER the tap."}
                ]
              ),
              %{type: :spacer, props: %{size: 12}, children: []},
              %{
                type: :text,
                props: %{text: log_label(assigns.acc_log), text_size: :sm, text_color: :muted},
                children: []
              }
            ]
          }
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

  # ── Example builder ────────────────────────────────────────────────────────
  # items are {id, title, body} or {id, title, body, disabled}
  defp accordion(open, on_toggle, items, extra \\ %{}) do
    props = Map.merge(%{open: open, on_toggle: on_toggle}, extra)
    %{type: :mishka_accordion, props: props, children: Enum.map(items, &item/1)}
  end

  # No on_toggle: the caller wires on_open_change or on_value_change instead,
  # which are alternatives to it rather than additions.
  defp accordion_with(open, extra, items) do
    props = Map.merge(%{open: open}, extra)
    %{type: :mishka_accordion, props: props, children: Enum.map(items, &item/1)}
  end

  defp item({id, title, body}), do: item({id, title, body, false})

  defp item({id, title, body, disabled}) do
    %{
      type: :mishka_accordion_item,
      props: %{id: id, title: title, disabled: disabled},
      children: [
        %{
          type: :text,
          props: %{text: body, text_size: :base, text_color: :muted},
          children: []
        }
      ]
    }
  end

  defp bar(color) do
    %{
      type: :box,
      props: %{fill_width: true, height: 10, background: color, corner_radius: :radius_sm},
      children: []
    }
  end

  defp gap(n), do: %{type: :spacer, props: %{size: n}, children: []}
end
