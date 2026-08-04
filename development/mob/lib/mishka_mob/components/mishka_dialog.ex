defmodule MishkaMob.Components.MishkaDialog do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Dialog** — a centred modal
  over a dimmed backdrop.

  Shares the Drawer's overlay mechanics (Mob has no z-index or modal layer, so
  an overlay is a `:box` stacking `[scrim, panel]` that is itself stacked over
  the screen), but centres its panel instead of anchoring it to an edge.

  ## Sizing and corners

  The panel is a **width-locked Box**, not a fill-width Column. That is a
  deliberate repeat of a lesson from the Drawer: `corner_radius` clips on a Box
  on both platforms, while a Compose Column rounds and a SwiftUI VStack does
  not. A dialog with square corners on iOS would be an obvious defect, so the
  panel takes an explicit `width` (default `320`) — which is also how dialogs
  behave on the web, where they are max-width constrained rather than
  edge-to-edge.

  ## `modal` survives; the focus trap does not

  The web's `modal` bundles three things: a focus trap, a scroll lock, and a
  backdrop. Two of them are DOM concepts — there is no tab ring to trap and no
  document to lock — but the third is real and visible, so it is what `modal`
  controls here:

    * `true` (default) — the backdrop dims.
    * `false` / `"trap-focus"` — the backdrop is transparent.

  `false` and `"trap-focus"` therefore render identically, because the only
  thing that separated them on the web was the focus trap. Both still catch an
  outside tap when `dismissible`, which is where this diverges from the web
  honestly rather than quietly: the web lets a non-modal outside click both
  dismiss the dialog *and* reach the content beneath it, and a single native
  hit-test cannot do both. Dismissal wins, because that is the behaviour a user
  is relying on. Set `dismissible: false` and the transparent backdrop stops
  taking taps at all — a Box with no fill and no handler has no hit shape —
  which is the closest thing to the web's pass-through.

  ## Anatomy, and the tags that name it

  Every part of the web anatomy is here: backdrop, viewport, popup, title,
  description, content, footer. What the web writes as `data-part` this writes
  as a testTag derived from `id`, because a device test can read a tag and
  cannot read a colour:

  | Tag | The part it names |
  |------|------|
  | `<id>-open` | The overlay root. It exists **only while open**, so its presence is the open state. |
  | `<id>-backdrop-modal` / `<id>-backdrop-plain` | The backdrop, naming whether it dims. `modal` is otherwise pure colour. |
  | `<id>-panel` | The popup. |
  | `<id>-title` · `<id>-description` · `<id>-content` · `<id>-footer` | The four inner parts. |
  | `<id>-trigger` / `<id>-trigger-disabled` | What `trigger/3` and `<MishkaDialogTrigger>` build. Disabled is otherwise pure colour. |

  Without `id` no part is tagged, which is what every caller written before this
  existed gets.

  ## Slots

  All four of the web component's slots are ported as tags, so markup reads the
  way the Phoenix component does instead of being assembled in an expression
  child:

      <MishkaDialog id="confirm" open={@open?} on_close={:close_confirm}>
        <MishkaDialogTitle text="Delete file?" />
        <MishkaDialogDescription text="This cannot be undone." />
        <Text text="report.pdf will be removed from every device." />
        <MishkaDialogFooter>
          <Button text="Cancel" on_tap={{self(), :close_confirm}} />
        </MishkaDialogFooter>
      </MishkaDialog>

  | Slot | Phoenix | Takes | The function that builds the same node |
  |------|---------|-------|----------------------------------------|
  | `<MishkaDialogTitle>` | `<:title>` | `text`, or children | `title/1` |
  | `<MishkaDialogDescription>` | `<:description>` | `text`, or children | `description/1` |
  | `<MishkaDialogFooter>` | `<:close>` | children — the footer buttons | `footer/1` |
  | `<MishkaDialogTrigger>` | `<:trigger>` | `label` (or `text`), `on_tap`, `on_open_change`, `disabled`, `id`, and the chrome props | `trigger/3` |
  | bare children | `<:inner_block>` | — | — the dialog body, as before |

  A slot tag has no module and no expander, so it arrives with its subtree
  intact and `dialog/4` consumes it. Anything it did not claim would reach the
  renderer as an unknown node and draw nothing at all — silently, because the
  tag name is whitelisted.

  A tag and its builder produce the IDENTICAL node — `<MishkaDialogTitle
  text="Delete file?" />` *is* `title("Delete file?")` — so the two forms are
  interchangeable. Write the tags out when you are writing a dialog out, and
  reach for the functions when the children come from DATA, where a
  comprehension reads better than generated markup:

      MishkaDialog.footer(Enum.map(@choices, &action_button/1))

  ### The string shorthands

  `title:`, `description:` and `actions:` stay as shorthands for the same three
  slots, for the common case of a line of text or a row of buttons. **A slot
  wins over its shorthand**, so passing both is not an error, merely redundant.

  ### The trigger slot is what a CLOSED dialog draws

  A closed dialog renders nothing, which is precisely the room the trigger slot
  needs: it takes the dialog's own place in the layout, and when the dialog
  opens the overlay takes that place instead. That makes `<MishkaDialog>` a
  self-contained control you drop in flow — but the node then has to sit
  somewhere that can hand the overlay the whole screen (the screen's root `Box`,
  or a root `Column` that is not scrolling), because the overlay is a fill node
  and a fill node inside a scroll has no bounded height to fill.

  When the button belongs in a scrolling page and the panel still has to cover
  it — the usual case, and what this library's own gallery does — keep the two
  apart: `trigger/3` builds **exactly** the node the tag builds, you place it
  where it belongs, and `id` ties the two together. That is also what lets one
  dialog be opened from two places, which no slot can express.

  ## Usage

      <MishkaDialog
        id="confirm"
        open={@open?}
        title="Delete file?"
        description="This cannot be undone."
        on_close={:close_dialog}
        actions={actions}
      >{body}</MishkaDialog>

      {MishkaDialog.trigger("confirm", "Delete", on_tap: :open_dialog)}

      def handle_info({:tap, :open_dialog}, socket) do
        {:noreply, Mob.Socket.assign(socket, :open?, true)}
      end

      def handle_info({:tap, :close_dialog}, socket) do
        {:noreply, Mob.Socket.assign(socket, :open?, false)}
      end
      # REQUIRED catch-all: the panel routes stray taps to an ignored tag.
      def handle_info(_msg, socket), do: {:noreply, socket}

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `id` | string | `nil` | Tag stem for every part. Give it one if a device test must find the dialog. |
  | `open` | boolean | `false` | Whether the dialog is shown. Lives in the screen. |
  | `modal` | `true` `false` `"trap-focus"` | `true` | Whether the backdrop dims. |
  | `title` | string | `nil` | Heading. Shorthand for `<MishkaDialogTitle>` / `title/1`. |
  | `description` | string | `nil` | Supporting line under the heading. Shorthand for `<MishkaDialogDescription>` / `description/1`. |
  | `actions` | list of nodes | `[]` | Footer buttons. Shorthand for `<MishkaDialogFooter>` / `footer/1`. |
  | `dismissible` | boolean | `true` | Whether a backdrop tap closes it. `false` forces an explicit choice (what Alert Dialog does). |
  | `on_close` | event tag (atom) | — | Sent as `{:tap, tag}` on backdrop tap. |
  | `on_open_change` | event tag (atom) | — | Sent as `{:tap, {tag, false}}` on backdrop tap, mirroring the web's `{open}` payload. `on_close` wins when both are given. |
  | `width` | number | `320` | Panel width. |
  | `background` | color token / ARGB int | `:surface` | Panel background. |
  | `corner_radius` | radius token / number | `:radius_lg` | Panel corners. |
  | `padding` | spacing token / number | `:space_lg` | Padding inside the panel. |
  | `inset` | spacing token / number | `:space_lg` | The viewport gap between the panel and the screen edges. |
  | `scrim_color` | ARGB int / token | `0x99000000` when modal, `0x00000000` otherwise | Backdrop fill. |

  Not ported: `close_on_escape` (Mob registers no key or back-press event, so
  there is nothing to listen to), `initial_focus`, `final_focus`, `labelledby`,
  `describedby` and the nine `*_class` attrs. Focus restoration and ARIA
  anchoring are DOM concerns; the classes are replaced by the chrome props
  above. `on_open_change_target` has no analogue either — a Mob event goes to
  the screen process, and there is no second LiveView to target.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  # The slot tags. They have no expander of their own — a slot tag is a marker
  # that arrives with its subtree intact and is consumed by the parent, exactly
  # as MishkaMenu consumes its six row kinds.
  @title :mishka_dialog_title
  @description :mishka_dialog_description
  @footer :mishka_dialog_footer
  @trigger :mishka_dialog_trigger

  @slot_types [@title, @description, @footer, @trigger]

  # Everything `trigger/3` takes as an option, read off the tag verbatim. The
  # button is built THROUGH trigger/3, so the tag and the builder cannot drift.
  @trigger_opts [
    :on_tap,
    :on_open_change,
    :disabled,
    :background,
    :text_color,
    :padding,
    :fill_width
  ]

  # Taps on the panel's empty areas must not reach the scrim, or the dialog
  # would dismiss itself. Routing them to a tag the screen ignores absorbs them
  # (the host screen's catch-all handle_info/2 swallows it).
  @absorb :__mishka_dialog_ignore
  @scrim 0x99_00_00_00
  # A non-modal backdrop is still a backdrop — it simply does not dim. Fully
  # transparent, so with no handler it also has no hit shape and taps fall
  # through, which is as close as native gets to the web's pass-through.
  @clear 0x00_00_00_00

  @doc """
  The accessible title — the web's `<:title>`, and the node
  `<MishkaDialogTitle>` builds. Takes a string, one node, or a list of nodes;
  the string form is styled like the `title:` prop.
  """
  @spec title(String.t() | map() | [map()]) :: map()
  def title(content), do: slot(@title, content)

  @doc """
  The supporting line under the title — the web's `<:description>`, and the node
  `<MishkaDialogDescription>` builds. Takes a string, one node, or a list of
  nodes.
  """
  @spec description(String.t() | map() | [map()]) :: map()
  def description(content), do: slot(@description, content)

  @doc """
  The footer actions — the web's `<:close>`, and the node `<MishkaDialogFooter>`
  builds. Takes one node or a list of them, laid out in a trailing-aligned row
  exactly like the `actions:` prop.
  """
  @spec footer(String.t() | map() | [map()]) :: map()
  def footer(content), do: slot(@footer, content)

  @doc """
  Every node type the dialog consumes as a slot. Exported so a test can prove
  none of them leaked past `dialog/4` to the renderer — a leak is silent, since
  the tag names are whitelisted and an unknown node simply draws nothing.
  """
  @spec slot_types() :: [atom()]
  def slot_types, do: @slot_types

  @doc """
  The button that opens the dialog — the web's `<:trigger>`, as a builder as well
  as a tag.

  Options: `:on_tap` (a bare event tag), `:on_open_change` (the same handler the
  dialog takes, widened to `{tag, true}` so one clause can serve both edges),
  `:disabled`, and the chrome props `:background`, `:text_color`, `:padding`,
  `:fill_width`.

      trigger("confirm", "Delete", on_tap: :open_confirm)

  `<MishkaDialogTrigger>` is built **through this function**, so the two forms
  cannot drift: the tag's `id` (defaulting to the dialog's own) is this first
  argument, its `label` the second, and every other prop one of these options.
  Reach for the builder when the trigger cannot live inside the dialog tag —
  because it belongs in a scrolling page while the panel has to cover one, or
  because the same dialog is opened from more than one place, which no slot can
  express.

  A disabled trigger wires no handler at all and tags itself
  `<id>-trigger-disabled`, because the muted colour that says so is invisible to
  a device test.
  """
  @spec trigger(String.t() | nil, String.t(), keyword()) :: map()
  def trigger(id, label, opts \\ []) do
    disabled? = truthy?(Keyword.get(opts, :disabled, false))

    node = ~MOB"""
    <Button
      text={label}
      background={trigger_background(opts, disabled?)}
      text_color={trigger_text_color(opts, disabled?)}
      padding={Keyword.get(opts, :padding, :space_sm)}
      fill_width={Keyword.get(opts, :fill_width, true)}
    />
    """

    node
    |> put_prop(:id, trigger_tag(id, disabled?))
    |> put_prop(:on_tap, trigger_handler(opts, disabled?))
  end

  @doc """
  Composite expander (`<MishkaDialog>`). The tag's children are the dialog body
  plus its slot tags.
  """
  @spec expand(map(), [map()], %{screen: pid()}) :: map()
  # `actions` arrives as a prop as well as a slot: a composite's expand/3 is
  # handed ONE children list, and before `<MishkaDialogFooter>` existed a footer
  # was otherwise unreachable from markup. Popped before the props reach the
  # widget.
  def expand(props, children, ctx) do
    {actions, props} = Map.pop(Map.new(props), :actions, [])
    dialog(props, children, List.wrap(actions), ctx)
  end

  @doc """
  The dialog node. `body` is the content — slot tags among it are consumed
  rather than drawn — and `actions` are footer nodes laid out in a
  trailing-aligned row.

  Renders the trigger slot when closed, and an empty column when there is not
  one.
  """
  @spec dialog(map() | keyword(), [map()], [map()], map()) :: map()
  def dialog(props \\ %{}, body \\ [], actions \\ [], ctx \\ %{}) do
    props = Map.new(props)
    {slots, content} = partition(body)
    triggers = Map.get(slots, @trigger, [])

    cond do
      truthy?(Map.get(props, :open, false)) ->
        overlay(props, slots, content, actions, ctx)

      # A closed dialog draws nothing, which is precisely the room the trigger
      # slot needs: it takes the dialog's own place until the overlay wants it.
      triggers != [] ->
        opener(triggers, props)

      true ->
        ~MOB(<Column />)
    end
  end

  # ── The trigger slot ──
  #
  # Built THROUGH trigger/3, so the tag and the builder cannot drift: whatever
  # the markup renders is the node the function returns, and a test can assert
  # that with `==`.
  #
  # Two triggers share a Column rather than the first one winning — dropping a
  # node the caller wrote is the silent failure this whole slot exists to avoid.
  defp opener(triggers, props) do
    case Enum.map(triggers, &built_trigger(&1, props)) do
      [one] -> one
      many -> %{type: :column, props: %{fill_width: true}, children: many}
    end
  end

  defp built_trigger(node, props) do
    tag_props = Map.get(node, :props, %{})

    # A slot tag's `on_*` props are NOT auto-wired the way the composite's own
    # are — Mob.Composite widens the tag it dispatches on, and a marker has no
    # expander to dispatch to. They are handed to trigger/3 raw and widened
    # there, through the same Event.handler call the function form makes.
    opts =
      Enum.reduce(@trigger_opts, [], fn key, acc ->
        case Map.fetch(tag_props, key) do
          {:ok, value} -> Keyword.put(acc, key, value)
          :error -> acc
        end
      end)

    # `text` as well as `label`, because `<Button text={…} />` is the muscle
    # memory and a trigger that silently renders blank is worse than an alias.
    label = Map.get(tag_props, :label) || Map.get(tag_props, :text) || ""

    trigger(Map.get(tag_props, :id) || Map.get(props, :id), label, opts)
  end

  defp overlay(props, slots, content, actions, ctx) do
    id = tag_stem(props)

    # An alert dialog keeps its backdrop inert so the user must choose. Note the
    # `if` rather than `dismissible? && close`: the latter yields `false`, which
    # would be attached as an on_tap prop instead of omitting the handler.
    close =
      if truthy?(Map.get(props, :dismissible, true)) do
        dismiss_handler(props)
      end

    node = ~MOB"""
    <Box fill_width={true} fill_height={true}>
      {scrim(props, id, close)}
      <Box
        fill_width={true}
        fill_height={true}
        align={:center}
        padding={Map.get(props, :inset, :space_lg)}
      >
        {panel(props, id, slots, content, actions, ctx)}
      </Box>
    </Box>
    """

    put_prop(node, :id, part_tag(id, "open"))
  end

  # The backdrop names whether it dims in its own tag: `modal` is otherwise a
  # difference of colour alone, and a device test cannot read a colour.
  defp scrim(props, id, close) do
    dim? = dim?(props)
    fill = Map.get(props, :scrim_color, if(dim?, do: @scrim, else: @clear))
    tag = part_tag(id, if(dim?, do: "backdrop-modal", else: "backdrop-plain"))
    node = ~MOB(<Box fill_width={true} fill_height={true} background={fill} />)

    node
    |> put_prop(:id, tag)
    |> put_prop(:on_tap, close)
  end

  # Width-locked Box so corner_radius clips on BOTH platforms (a Compose Column
  # rounds, a SwiftUI VStack does not).
  defp panel(props, id, slots, content, actions, ctx) do
    title = part_nodes(slots, @title, Map.get(props, :title))
    description = part_nodes(slots, @description, Map.get(props, :description))
    footer = footer_nodes(slots, actions)

    node = ~MOB"""
    <Box
      width={Map.get(props, :width, 320)}
      background={Map.get(props, :background, :surface)}
      corner_radius={Map.get(props, :corner_radius, :radius_lg)}
    >
      <Column fill_width={true} padding={Map.get(props, :padding, :space_lg)}>
        {heading(title, description, id)}
        {block(content, part_tag(id, "content"))}
        {footer_row(footer, id)}
      </Column>
    </Box>
    """

    node
    |> put_prop(:id, part_tag(id, "panel"))
    |> put_prop(:on_tap, absorb_tap(ctx))
  end

  defp heading([], [], _id), do: []

  defp heading(title, description, id) do
    [
      ~MOB"""
      <Column fill_width={true}>
        {block(title, part_tag(id, "title"))}
        <Spacer size={6} :if={title != [] and description != []} />
        {block(description, part_tag(id, "description"))}
        <Spacer size={16} />
      </Column>
      """
    ]
  end

  defp footer_row([], _id), do: []

  # Two or more actions SHARE the row; a lone one is trailing-aligned.
  #
  # They used to be unweighted after a weighted Spacer, which trailing-aligns
  # correctly right up until the labels are wider than the panel — and then the
  # LAST button overflows the panel's clip. It was still in the tree, still
  # carried its handler, and a test could still find it and "click" it, but the
  # tap landed outside the clip and nothing fired. Only a finger, or a device
  # test that measures, can tell. Weighting them means they cannot overflow.
  defp footer_row(actions, id) do
    node =
      case actions do
        [_one] ->
          ~MOB"""
          <Column fill_width={true}>
            <Spacer size={18} />
            <Row fill_width={true}>
              <Spacer weight={1} />
              {actions}
            </Row>
          </Column>
          """

        many ->
          shared =
            many
            |> Enum.map(&%{type: :box, props: %{weight: 1}, children: [&1]})
            |> Enum.intersperse(~MOB(<Spacer size={10} />))

          ~MOB"""
          <Column fill_width={true}>
            <Spacer size={18} />
            <Row fill_width={true}>
              {shared}
            </Row>
          </Column>
          """
      end

    [put_prop(node, :id, part_tag(id, "footer"))]
  end

  # Each anatomical part is its own tagged Column, so a device test can address
  # the title without knowing what the caller put inside it.
  defp block([], _tag), do: []

  defp block(nodes, tag) do
    node = ~MOB"""
    <Column fill_width={true}>
      {nodes}
    </Column>
    """

    [put_prop(node, :id, tag)]
  end

  # A slot builder produces the same marker node the matching tag does: a string
  # keeps its text in props, so the styling stays this module's decision rather
  # than the caller's, and anything else travels as children.
  defp slot(type, content) when is_binary(content),
    do: %{type: type, props: %{text: content}, children: []}

  defp slot(type, content) when is_list(content),
    do: %{type: type, props: %{}, children: content}

  defp slot(type, content) when is_map(content),
    do: %{type: type, props: %{}, children: [content]}

  # One pass over the children, the way MishkaMenu reads its rows: split the
  # markers out, group them by kind, and hand the rest on as the body. A marker
  # left in the body would travel all the way to the renderer, which has no
  # widget for it and draws nothing — and says nothing either, because the tag
  # name is whitelisted.
  defp partition(children) do
    {slots, body} = Enum.split_with(List.wrap(children), &slot?/1)
    {Enum.group_by(slots, & &1.type), body}
  end

  defp slot?(node), do: is_map(node) and Map.get(node, :type) in @slot_types

  defp part_nodes(slots, type, shorthand) do
    case Map.get(slots, type, []) do
      [] -> if is_binary(shorthand), do: styled(type, shorthand), else: []
      nodes -> Enum.flat_map(nodes, &slot_content(&1, type))
    end
  end

  defp footer_nodes(slots, actions) do
    case Map.get(slots, @footer, []) do
      [] -> List.wrap(actions)
      nodes -> Enum.flat_map(nodes, &slot_content(&1, @footer))
    end
  end

  defp slot_content(%{props: props, children: children}, type) do
    case Map.get(props, :text) do
      text when is_binary(text) -> styled(type, text)
      _ -> children
    end
  end

  defp styled(@title, text),
    do: [~MOB(<Text text={text} text_size={:xl} text_color={:on_surface} />)]

  defp styled(@description, text),
    do: [~MOB(<Text text={text} text_size={:base} text_color={:muted} />)]

  defp styled(@footer, text),
    do: [~MOB(<Text text={text} text_size={:base} text_color={:on_surface} />)]

  # `on_close` wins over `on_open_change` when both are set: it is the narrower
  # statement of intent, and it is what every caller written before the web's
  # {open} payload was ported already passes.
  defp dismiss_handler(props) do
    case {Map.get(props, :on_close), Map.get(props, :on_open_change)} do
      {nil, nil} -> nil
      {nil, change} -> Event.handler(change, false)
      {close, _} -> Event.handler(close)
    end
  end

  defp trigger_handler(_opts, true), do: nil

  defp trigger_handler(opts, _disabled) do
    case {Keyword.get(opts, :on_tap), Keyword.get(opts, :on_open_change)} do
      {nil, nil} -> nil
      {nil, change} -> Event.handler(change, true)
      {tap, _} -> Event.handler(tap)
    end
  end

  defp trigger_background(_opts, true), do: :surface_raised
  defp trigger_background(opts, _disabled), do: Keyword.get(opts, :background, :primary)

  defp trigger_text_color(_opts, true), do: :muted
  defp trigger_text_color(opts, _disabled), do: Keyword.get(opts, :text_color, :on_primary)

  # Only `true` dims. The web serialises `modal` with to_string/1, so a string
  # arrives just as legitimately as a boolean — and "trap-focus", whose whole
  # meaning was the focus trap, is left rendering as the plain backdrop.
  defp dim?(props) do
    case Map.get(props, :modal, true) do
      true -> true
      "true" -> true
      _ -> false
    end
  end

  defp tag_stem(props) do
    case Map.get(props, :id) do
      nil -> nil
      id -> to_string(id)
    end
  end

  defp part_tag(nil, _suffix), do: nil
  defp part_tag(id, suffix), do: id <> "-" <> suffix

  defp trigger_tag(nil, _disabled?), do: nil
  defp trigger_tag(id, true), do: to_string(id) <> "-trigger-disabled"
  defp trigger_tag(id, false), do: to_string(id) <> "-trigger"

  defp put_prop(node, _key, nil), do: node
  defp put_prop(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  # ctx carries the screen pid for composite expansion; when called as a plain
  # function the caller's process (the screen) is already correct.
  defp absorb_tap(%{screen: pid}) when is_pid(pid), do: {pid, @absorb}
  defp absorb_tap(_ctx), do: {self(), @absorb}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
