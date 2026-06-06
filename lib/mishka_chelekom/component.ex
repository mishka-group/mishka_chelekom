defmodule MishkaChelekom.Component do
  @moduledoc """
  The Mishka Chelekom component macro — one declarative `component/2` for **both** styled and
  headless components, with Pyro-style overrides and class-merging built in.

  This is an original Mishka design (not a port of any other library). It unifies the ideas we
  liked from the ecosystem, in our own shape:

    * **styled** — declare `variants`/`defaults` (Doggo-style modifiers), compile-time validated;
    * **overrides** — every component composes its classes through `MishkaChelekom.Overrides`
      (Pyro-style, central, first-wins) so a project can restyle without editing the component;
    * **merge** — composition runs through `MishkaChelekom.CSS` (swappable Tailwind-merge seam);
    * **headless** — declare `parts:` (a Base-UI-style anatomy) and the macro emits the full
      unstyled markup: `chelekom-<comp>__<part>` classes, `data-part`, ARIA, paired-presence
      `data-open`/`data-closed`, and the JS `hook`.

  ## Styled

      defmodule MyAppWeb.Components.Button do
        use MishkaChelekom.Component

        component :button,
          tag: :button,
          base: "inline-flex items-center font-medium rounded",
          variants: [
            color: [primary: "bg-primary text-primary-content", ghost: "bg-transparent hover:bg-base-200"],
            size:  [sm: "h-8 px-3 text-xs", md: "h-9 px-4 text-sm", lg: "h-10 px-6"]
          ],
          defaults: [color: :primary, size: :md]
      end

      <.button color={:ghost} size={:lg} class="px-6">Save</.button>

  A `default` that names an undeclared value fails at **compile time**.

  ## Headless

      component :dialog,
        headless: true,
        hook: "FocusTrap",
        parts: [
          trigger:  [tag: :button, slot: true, aria: [haspopup: "dialog"]],
          backdrop: [tag: :div, aria: [hidden: "true"]],
          popup:    [tag: :div, role: "dialog", state: true,
                     aria: [modal: "true", labelledby: {:ref, :title}],
                     children: [
                       title:   [tag: :h2, id: true, slot: true],
                       content: [tag: :div, slot: :inner_block]
                     ]]
        ]

      <.dialog id="confirm" open={@open}>
        <:trigger>Open</:trigger>
        <:title>Confirm</:title>
        Body
      </.dialog>

  ### Part options
    * `tag:` — HTML tag (default `:div`)
    * `role:` — ARIA role
    * `aria:` — keyword of `aria-*`; a value of `{:ref, :other_part}` resolves to
      `"\#{@id}-other_part"` (id wiring)
    * `state: true` — emit paired-presence `data-open`/`data-closed` (from the `open` assign)
    * `id: true` — give the part `id="\#{@id}-<part>"`
    * `slot: true` — render a named `<:part>` slot here; `slot: :inner_block` for the default slot
    * `children:` — nested parts

  Generated components remain plain Phoenix components; rendering is delegated to the small
  `render_tag/1` and recursive `render_node/1` helpers below.

  > Note: components authored with this macro use `mishka_chelekom` at runtime (like Doggo/Pyro).
  > That is the opt-in alternative to the zero-runtime-dependency `mix mishka.ui.gen.*` generators
  > — which is why `phoenix_live_view` is declared as an optional dependency.
  """
  use Phoenix.Component

  # ---- runtime renderers (normal components; no macro-hygiene constraints) ----

  @doc false
  attr(:__tag__, :string)
  attr(:__cls__, :any)
  attr(:rest, :global)
  slot(:inner_block)

  def render_tag(assigns) do
    ~H"<.dynamic_tag tag_name={@__tag__} class={@__cls__} {@rest}>{render_slot(@inner_block)}</.dynamic_tag>"
  end

  @doc false
  attr(:spec, :map, required: true)
  attr(:ctx, :map, required: true)

  def render_node(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@spec.tag} {@spec.attrs}>{@spec[:text]}<%= if s = @spec[:slot] do %>{render_slot(@ctx[s])}<% end %><.render_node :for={c <- @spec[:children] || []} spec={c} ctx={@ctx} /></.dynamic_tag>
    """
  end

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import MishkaChelekom.Component, only: [component: 2]
    end
  end

  @doc "Declare a styled or headless component. See the module docs."
  defmacro component(name, opts) do
    if Keyword.get(opts, :headless, false) || Keyword.has_key?(opts, :parts),
      do: headless(name, opts),
      else: styled(name, opts)
  end

  # ===== styled =====

  defp styled(name, opts) do
    tag = Keyword.get(opts, :tag, :div)
    base = Keyword.get(opts, :base, "")
    variants = Keyword.get(opts, :variants, [])
    defaults = Keyword.get(opts, :defaults, [])

    Enum.each(defaults, fn {v, d} ->
      values = variants |> Keyword.get(v, []) |> Keyword.keys()

      d in values ||
        raise(CompileError,
          description:
            "component #{inspect(name)}: default #{v}=#{inspect(d)} not in #{inspect(values)}"
        )
    end)

    variant_attrs =
      Enum.map(variants, fn {v, vals} ->
        quote do:
                attr(unquote(v), :atom,
                  default: unquote(Keyword.get(defaults, v)),
                  values: unquote(Keyword.keys(vals))
                )
      end)

    vmap = variants |> Map.new(fn {k, v} -> {k, Map.new(v)} end) |> Macro.escape()
    vkeys = Keyword.keys(variants)

    quote do
      unquote_splicing(variant_attrs)
      attr(:class, :any, default: nil)
      attr(:rest, :global)
      slot(:inner_block, required: true)

      def unquote(name)(assigns) do
        vmap = unquote(vmap)
        vclasses = Enum.map(unquote(vkeys), &vmap[&1][Map.get(assigns, &1)])

        cls =
          MishkaChelekom.Overrides.merge(
            unquote(name),
            :root,
            [unquote(base) | vclasses],
            assigns.class
          )

        MishkaChelekom.Component.render_tag(%{
          __tag__: unquote(to_string(tag)),
          __cls__: cls,
          rest: assigns.rest,
          inner_block: assigns.inner_block,
          __changed__: assigns[:__changed__]
        })
      end
    end
  end

  # ===== headless =====

  defp headless(name, opts) do
    hook = Keyword.get(opts, :hook)
    parts = Keyword.get(opts, :parts, [])
    {slot_decls, has_state} = collect(parts, {[], false})
    state_attr = if has_state, do: [quote(do: attr(:open, :boolean, default: false))], else: []

    root =
      node_ast(
        name,
        :root,
        [tag: opts[:tag] || :div, hook: hook, children: parts, state: has_state],
        true
      )

    quote do
      attr(:id, :string, required: true)
      attr(:class, :any, default: nil)
      attr(:rest, :global)
      unquote_splicing(state_attr)
      unquote_splicing(slot_decls)

      def unquote(name)(assigns) do
        MishkaChelekom.Component.render_node(%{
          spec: unquote(root),
          ctx: assigns,
          __changed__: assigns[:__changed__]
        })
      end
    end
  end

  defp collect(parts, acc) do
    Enum.reduce(parts, acc, fn {pname, popts}, {slots, state?} ->
      slots =
        case popts[:slot] do
          true -> [quote(do: slot(unquote(pname))) | slots]
          :inner_block -> [quote(do: slot(:inner_block, required: true)) | slots]
          _ -> slots
        end

      collect(popts[:children] || [], {slots, state? || popts[:state] == true})
    end)
  end

  defp node_ast(comp, pname, popts, root?) do
    tag = to_string(popts[:tag] || :div)
    attrs = attrs_ast(comp, pname, popts, root?)

    cond do
      popts[:slot] in [true, :inner_block] ->
        key = if popts[:slot] == :inner_block, do: :inner_block, else: pname
        quote do: %{tag: unquote(tag), attrs: unquote(attrs), slot: unquote(key)}

      popts[:children] not in [nil, []] ->
        kids = Enum.map(popts[:children], fn {cn, co} -> node_ast(comp, cn, co, false) end)
        quote do: %{tag: unquote(tag), attrs: unquote(attrs), children: unquote(kids)}

      true ->
        quote do: %{tag: unquote(tag), attrs: unquote(attrs)}
    end
  end

  defp attrs_ast(comp, pname, popts, root?) do
    klass = if root?, do: "chelekom-#{comp}", else: "chelekom-#{comp}__#{pname}"

    [
      if root? do
        quote do: [
                class: MishkaChelekom.CSS.classes([unquote(klass), assigns.class]),
                id: assigns.id
              ]
      else
        quote do: [class: unquote(klass)]
      end
    ]
    |> add(if(root?, do: nil, else: quote(do: ["data-part": unquote(to_string(pname))])))
    |> add(if(popts[:role], do: quote(do: [role: unquote(popts[:role])])))
    |> add(aria_ast(popts[:aria] || []))
    |> add(
      if(popts[:state] == true,
        do: quote(do: ["data-open": assigns.open, "data-closed": !assigns.open])
      )
    )
    |> add(
      if(!root? && popts[:id],
        do: quote(do: [id: assigns.id <> unquote("-" <> to_string(pname))])
      )
    )
    |> add(if(popts[:hook], do: quote(do: ["phx-hook": unquote(popts[:hook])])))
    |> add(if(root?, do: quote(do: Map.to_list(assigns.rest))))
    |> combine()
  end

  defp add(list, nil), do: list
  defp add(list, piece), do: list ++ [piece]

  defp combine([h | t]),
    do: Enum.reduce(t, h, fn p, acc -> quote do: unquote(acc) ++ unquote(p) end)

  defp aria_ast([]), do: quote(do: [])

  defp aria_ast(aria) do
    pairs =
      Enum.map(aria, fn
        {k, {:ref, part}} ->
          quote do: {unquote(:"aria-#{k}"), assigns.id <> unquote("-" <> to_string(part))}

        {k, v} ->
          quote do: {unquote(:"aria-#{k}"), unquote(v)}
      end)

    quote do: unquote(pairs)
  end
end
