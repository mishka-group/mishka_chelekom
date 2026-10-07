defmodule MishkaMob.Showcase.Page do
  @moduledoc """
  Contract for one page of the component gallery.

  A page is a module that `use MishkaMob.Showcase.Page` and implements `entry/0`
  (metadata) and `examples/0` (a list of `MishkaMob.Showcase.Example`).
  `MishkaMob.Showcase` registers it, and the generic `GalleryScreen` and
  `ComponentScreen` render it.

  This module references no other module of the app, and has to stay that way:
  every page compiles against it, so anything it reached would recompile all of
  them whenever it changed.

  ## Author a component showcase

      defmodule MyApp.Showcase.Components.Badge do
        use MishkaMob.Showcase.Page
        alias MishkaMob.Showcase.Example

        @impl true
        def entry do
          %{slug: :badge, name: "Badge", category: "Data display", order: 0,
            description: "A small status/count label."}
        end

        @impl true
        def examples do
          [%Example{title: "Colors", description: "One per semantic token.",
                    code: "<Badge color={:primary} text=\\"New\\" />",
                    render: fn _assigns -> badge_row() end}]
        end
      end

  Then `MishkaMob.Showcase.register(MyApp.Showcase.Components.Badge)`.

  ## Interactive / overlay components

  Static components only need `entry/0` + `examples/0` (each example's `render`
  returns an inline preview node). Components that need state or an overlay
  (Drawer, Modal, …) also override:

    * `mount/1`  — seed the screen's assigns (`socket -> socket`)
    * `handle/2` — react to a tapped tag (`(tag, socket) -> socket`)
    * `overlay/1` — a node rendered at the **screen root** (`assigns -> node | nil`),
      so a drawer's panel stacks over the whole page while the example card
      shows only the inline "Open" buttons.

  `ComponentScreen` delegates its `mount`, tap events, and root overlay to
  these, so every component drives itself through one generic screen.
  """

  alias MishkaMob.Showcase.Kit

  @typedoc "Component metadata returned by `entry/0` (the registry adds `:module`)."
  @type entry :: %{
          required(:slug) => atom(),
          required(:name) => String.t(),
          required(:category) => String.t(),
          optional(:description) => String.t(),
          optional(:order) => integer()
        }

  @callback entry() :: entry()
  @callback examples() :: [MishkaMob.Showcase.Example.t()]
  @callback mount(socket :: term()) :: term()
  @callback handle(tag :: term(), socket :: term()) :: term()
  @callback overlay(assigns :: map()) :: map() | nil
  @callback card_preview() :: map()
  @callback props() :: [%{required(:name) => String.t(), optional(atom()) => String.t()}]
  @doc """
  Handle a value-carrying event — `{:change, tag, value}` from a Toggle, Slider,
  TextField, … — as opposed to `handle/2`'s bare taps.
  """
  @callback handle_change(tag :: term(), value :: term(), socket :: term()) :: term()
  @optional_callbacks mount: 1,
                      handle: 2,
                      handle_change: 3,
                      overlay: 1,
                      card_preview: 0,
                      props: 0

  # `Kit` stays inside the quote, never unquoted: expanded here it would make this
  # file depend on Kit, and every page compile-connected through it.
  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour MishkaMob.Showcase.Page

      @impl true
      def mount(socket), do: socket
      @impl true
      def handle(_tag, socket), do: socket
      @impl true
      def overlay(_assigns), do: nil
      @impl true
      def card_preview, do: Kit.skeleton_preview()
      @impl true
      def props, do: []
      @impl true
      def handle_change(_tag, _value, socket), do: socket

      defoverridable mount: 1,
                     handle: 2,
                     handle_change: 3,
                     overlay: 1,
                     card_preview: 0,
                     props: 0
    end
  end
end
