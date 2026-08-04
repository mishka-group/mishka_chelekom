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
  | `<id>-trigger` / `<id>-trigger-disabled` | What `trigger/3` builds. Disabled is otherwise pure colour. |

  Without `id` no part is tagged, which is what every caller written before this
  existed gets.

  ## Slots, and their string shorthands

  `title/1`, `description/1` and `footer/1` build slot children — the native
  analogue of the web's `<:title>`, `<:description>` and `<:close>`. Each also
  has a shorthand prop (`title:`, `description:`, `actions:`) for the common
  case of a line of text or a row of buttons. **A slot child wins over its
  shorthand**, so passing both is not an error, merely redundant.

      dialog(
        %{id: "confirm", open: @open?, on_close: :close},
        [
          MishkaDialog.title("Delete file?"),
          MishkaDialog.description("This cannot be undone."),
          body_nodes(),
          MishkaDialog.footer([cancel_button(), confirm_button()])
        ]
      )

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
  | `title` | string | `nil` | Heading. Shorthand for `title/1`. |
  | `description` | string | `nil` | Supporting line under the heading. Shorthand for `description/1`. |
  | `actions` | list of nodes | `[]` | Footer buttons. Shorthand for `footer/1`. |
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

  @title :mishka_dialog_title
  @description :mishka_dialog_description
  @footer :mishka_dialog_footer

  @slot_types [@title, @description, @footer]

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
  The accessible title — the web's `<:title>`. Takes a string, one node, or a
  list of nodes; the string form is styled like the `title:` prop.
  """
  @spec title(String.t() | map() | [map()]) :: map()
  def title(content), do: slot(@title, content)

  @doc """
  The supporting line under the title — the web's `<:description>`. Takes a
  string, one node, or a list of nodes.
  """
  @spec description(String.t() | map() | [map()]) :: map()
  def description(content), do: slot(@description, content)

  @doc """
  The footer actions — the web's `<:close>`. Takes one node or a list of them,
  laid out in a trailing-aligned row exactly like the `actions:` prop.
  """
  @spec footer(String.t() | map() | [map()]) :: map()
  def footer(content), do: slot(@footer, content)

  @doc """
  Every node type the dialog consumes as a slot. Exported so a test can prove
  none of them leaked past `dialog/4` to the renderer.
  """
  @spec slot_types() :: [atom()]
  def slot_types, do: @slot_types

  @doc """
  The button that opens the dialog — the web's `<:trigger>`, as a builder rather
  than a slot child.

  It is a builder because the two cannot be the same node here. The web trigger
  lives inside the dialog's own markup; natively the panel has to be stacked at
  the **screen root** to cover the page, while the trigger belongs in flow where
  the user is reading. One node cannot be in both places, so the caller places
  the trigger and the dialog separately, and `id` is what ties them together.

  Options: `:on_tap` (a bare event tag), `:on_open_change` (the same handler the
  dialog takes, widened to `{tag, true}` so one clause can serve both edges),
  `:disabled`, and the chrome props `:background`, `:text_color`, `:padding`,
  `:fill_width`.

      trigger("confirm", "Delete", on_tap: :open_confirm)

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
  plus any slot children.
  """
  @spec expand(map(), [map()], %{screen: pid()}) :: map()
  # `actions` arrives as a prop rather than a second slot: a composite's
  # expand/3 is handed ONE children list, so a footer would otherwise be
  # unreachable from markup and `<MishkaDialog>` could never replace a
  # dialog/4 call. Popped before the props reach the widget.
  def expand(props, children, ctx) do
    {actions, props} = Map.pop(Map.new(props), :actions, [])
    dialog(props, children, List.wrap(actions), ctx)
  end

  @doc """
  The dialog node. `body` is the content — slot children among it are consumed
  rather than drawn — and `actions` are footer nodes laid out in a
  trailing-aligned row. Renders an empty column when closed.
  """
  @spec dialog(map() | keyword(), [map()], [map()], map()) :: map()
  def dialog(props \\ %{}, body \\ [], actions \\ [], ctx \\ %{}) do
    props = Map.new(props)

    if truthy?(Map.get(props, :open, false)) do
      overlay(props, body, actions, ctx)
    else
      ~MOB(<Column />)
    end
  end

  defp overlay(props, body, actions, ctx) do
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
        {panel(props, id, body, actions, ctx)}
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
  defp panel(props, id, body, actions, ctx) do
    {slots, content} = partition(body)

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

  # Slot children travel as ordinary nodes and are pulled back out here, the way
  # MishkaMenu consumes its row tags. A string slot keeps its text in props so
  # the styling stays this module's decision rather than the caller's.
  defp slot(type, content) when is_binary(content),
    do: %{type: type, props: %{text: content}, children: []}

  defp slot(type, content) when is_list(content),
    do: %{type: type, props: %{}, children: content}

  defp slot(type, content) when is_map(content),
    do: %{type: type, props: %{}, children: [content]}

  defp partition(children) do
    {slots, body} = Enum.split_with(children, &slot?/1)
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
