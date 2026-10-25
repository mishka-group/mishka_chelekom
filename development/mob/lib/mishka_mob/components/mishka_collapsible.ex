defmodule MishkaMob.Components.MishkaCollapsible do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Collapsible** — a trigger that
  shows and hides one region (the WAI-ARIA disclosure pattern).

  ## Why this is not "an Accordion with one item"

  Structurally it is, and the rendered row is deliberately identical. What
  differs is the **event shape**, and that is the reason this is its own
  component rather than a thin call into
  `MishkaMob.Components.MishkaAccordion`: an accordion widens its tag to
  `{tag, item_id}` so one handler can serve many rows, which is noise when there
  is only ever one region. A collapsible fires a bare `{:tap, tag}`:

      <MishkaCollapsible
        title="Details"
        open={@open?}
        on_toggle={:toggle_details}
      >{body}</MishkaCollapsible>

      def handle_info({:tap, :toggle_details}, socket) do
        {:noreply, Mob.Socket.assign(socket, :open?, not socket.assigns.open?)}
      end

  Reusing the accordion would have leaked its multi-item event into a
  single-item API.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `title` | string | `nil` | The trigger label. |
  | `open` | boolean | `false` | Whether the region is shown. Lives in the screen. |
  | `disabled` | boolean | `false` | Wires no handler, so the trigger is inert. |
  | `on_toggle` | event tag (atom) | — | Sent as `{:tap, tag}`. |
  | `chevron` | boolean | `true` | Show the ▸/▾ indicator. |
  | `background` | color token / ARGB int | `:surface_raised` | Row background. |
  | `color` | color token / ARGB int | `:on_surface` | Title and chevron. Set it whenever you set `background`. |
  | `corner_radius` | radius token / number | `:radius_md` | Rounds the row. |
  | `padding` | spacing token / number | `:space_md` | Padding inside trigger and region. |
  | `id` | string | `nil` | Test tag on the root; the trigger is `<id>-trigger` and the region `<id>-panel`. |

  Not ported: the `*_class` attrs (styling), and `hidden_until_found`, which
  exists so a browser's find-in-page can reveal collapsed text — there is no
  find-in-page over native views. `id` is not the DOM anchor the web means by
  it; it is the test tag. The region is only in the tree while it is open, so
  `<id>-panel` existing is what says so.

  Like the Accordion, the trigger is a tappable Box rather than a Button,
  because a Material Button centres its label.

  **Documentation:** https://mishka.tools/chelekom/docs/mob/collapsible
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc """
  Composite expander (`<MishkaCollapsible>`). The tag's children are the
  collapsible region.
  """
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: collapsible(props, children)

  @doc """
  The collapsible node. `props` is a map or keyword list; `content` is the list
  of nodes revealed when open.
  """
  @spec collapsible(map() | keyword(), [map()]) :: map()
  def collapsible(props \\ %{}, content \\ []) do
    props = Map.new(props)
    open? = truthy?(Map.get(props, :open, false))
    disabled? = truthy?(Map.get(props, :disabled, false))
    padding = Map.get(props, :padding) || :space_md
    id = Map.get(props, :id)

    ~MOB"""
    <Box
      fill_width={true}
      background={Map.get(props, :background) || :surface_raised}
      corner_radius={Map.get(props, :corner_radius) || :radius_md}
    >
      <Column fill_width={true}>
        {trigger(props, open?, disabled?, padding)}
        {region(content, padding, id, open?)}
      </Column>
    </Box>
    """
    |> put(:id, id)
  end

  @doc """
  The test tag on the trigger, given the collapsible's `id`.

      iex> MishkaMob.Components.MishkaCollapsible.trigger_tag("shipping")
      "shipping-trigger"
      iex> MishkaMob.Components.MishkaCollapsible.trigger_tag(nil)
      nil
  """
  @spec trigger_tag(id :: String.t() | nil) :: String.t() | nil
  def trigger_tag(nil), do: nil
  def trigger_tag(id), do: "#{id}-trigger"

  @doc """
  The test tag on the region, given the collapsible's `id`. It exists only while
  the collapsible is open.

      iex> MishkaMob.Components.MishkaCollapsible.panel_tag("shipping")
      "shipping-panel"
      iex> MishkaMob.Components.MishkaCollapsible.panel_tag(nil)
      nil
  """
  @spec panel_tag(id :: String.t() | nil) :: String.t() | nil
  def panel_tag(nil), do: nil
  def panel_tag(id), do: "#{id}-panel"

  # The region is the trigger's sibling and is built only while open, so a closed
  # collapsible has no node here at all.
  defp region(content, padding, id, true) when content != [] do
    ~MOB"""
    <Column fill_width={true} padding={padding}>
      {content}
    </Column>
    """
    |> put(:id, panel_tag(id))
  end

  defp region(_content, _padding, _id, _open?), do: nil

  # Label leading, state chevron trailing. A disabled trigger gets no handler at
  # all, so it cannot fire.
  defp trigger(props, open?, disabled?, padding) do
    # :on_surface is the theme's ink for a THEME surface. The moment a caller
    # sets their own `background` it stops being one — a violet panel keeps
    # near-black text and the title becomes hard to read. So the ink is a prop
    # too; MishkaMark learned the same lesson, which is why its fill and ink are
    # a matched pair rather than one overridable half.
    color = if disabled?, do: :muted, else: Map.get(props, :color) || :on_surface

    # Widened to {pid, tag}; a bare atom would serialise as an ordinary prop and
    # the trigger would render fine but never fire.
    tap =
      if disabled?,
        do: nil,
        else: Event.handler(Map.get(props, :on_toggle))

    # `nil` means "not given", not `false`: `Map.get/3` hands back its default
    # only when the key is ABSENT, so a keyword-built props map carrying an
    # unset key as an explicit nil used to read as a deliberate `false`.
    # Only a real `false` turns this off.
    chevron? = Map.get(props, :chevron) != false

    node = ~MOB"""
    <Box fill_width={true} padding={padding}>
      <Row fill_width={true}>
        <Text text={Map.get(props, :title) || ""} text_size={:lg} text_color={color} />
        <Spacer weight={1} :if={chevron?} />
        <Text
          text={if(open?, do: "▾", else: "▸")}
          text_size={:lg}
          text_color={color}
          :if={chevron?}
        />
      </Row>
    </Box>
    """

    node
    |> put(:on_tap, tap)
    |> put(:id, trigger_tag(Map.get(props, :id)))
  end

  # A prop left out is a prop the node never carries: `nil` serialises as the
  # string "nil", and the bridge would tag the node with it.
  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
