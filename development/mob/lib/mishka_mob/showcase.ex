defmodule MishkaMob.Showcase do
  @moduledoc """
  Registry + contract for the component gallery.

  Each showcased component is a module that `use MishkaMob.Showcase` and
  implements `entry/0` (metadata) and `examples/0` (a list of
  `#{inspect(__MODULE__)}.Example`). Register them at boot (see
  `MishkaMob.App.on_start/0`). The generic `GalleryScreen` and
  `ComponentScreen` read this registry — so **adding a component to the gallery
  is one module + one register call, no new screen**.

  ## Author a component showcase

      defmodule MyApp.Showcase.Components.Badge do
        use MishkaMob.Showcase
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

  @pt_key {__MODULE__, :components}

  defmodule Example do
    @moduledoc """
    One showcased example: a `title`, a short `description`, the `code` to show
    (a plain string — device builds ship no source to read), and a `render`
    function returning the live preview node.
    """
    @enforce_keys [:title, :render]
    defstruct [:title, :description, :code, :render]

    @type t :: %__MODULE__{
            title: String.t(),
            description: String.t() | nil,
            code: String.t() | nil,
            render: (map() -> map())
          }
  end

  @typedoc "Component metadata returned by `entry/0` (the registry adds `:module`)."
  @type entry :: %{
          required(:slug) => atom(),
          required(:name) => String.t(),
          required(:category) => String.t(),
          optional(:description) => String.t(),
          optional(:order) => integer()
        }

  @callback entry() :: entry()
  @callback examples() :: [Example.t()]
  @callback mount(socket :: term()) :: term()
  @callback handle(tag :: term(), socket :: term()) :: term()
  @callback overlay(assigns :: map()) :: map() | nil
  @callback card_preview() :: map()
  @optional_callbacks mount: 1, handle: 2, overlay: 1, card_preview: 0

  @doc "Register a showcase component module. Overwrites any prior registration for its slug."
  @spec register(module()) :: :ok
  def register(module) when is_atom(module) do
    slug = module.entry().slug
    :persistent_term.put(@pt_key, Map.put(components(), slug, module))
    :ok
  end

  @doc "The raw `%{slug => module}` registry."
  @spec components() :: %{atom() => module()}
  def components, do: :persistent_term.get(@pt_key, %{})

  @doc false
  def reset, do: :persistent_term.put(@pt_key, %{})

  @doc "All entries (each augmented with `:module`), sorted by category then order then name."
  @spec all() :: [map()]
  def all do
    components()
    |> Map.values()
    |> Enum.map(&with_module/1)
    |> Enum.sort_by(&{&1.category, Map.get(&1, :order, 0), &1.name})
  end

  @doc "Entries grouped `[{category, [entry, ...]}, ...]`, categories alphabetical."
  @spec by_category() :: [{String.t(), [map()]}]
  def by_category do
    all()
    |> Enum.group_by(& &1.category)
    |> Enum.sort_by(fn {category, _} -> category end)
  end

  @doc "The entry (with `:module`) for a slug, or `nil`."
  @spec get(atom()) :: map() | nil
  def get(slug) do
    case Map.get(components(), slug) do
      nil -> nil
      module -> with_module(module)
    end
  end

  defp with_module(module), do: Map.put(module.entry(), :module, module)

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour MishkaMob.Showcase

      @impl true
      def mount(socket), do: socket
      @impl true
      def handle(_tag, socket), do: socket
      @impl true
      def overlay(_assigns), do: nil
      @impl true
      def card_preview, do: unquote(Kit).skeleton_preview()

      defoverridable mount: 1, handle: 2, overlay: 1, card_preview: 0
    end
  end
end
