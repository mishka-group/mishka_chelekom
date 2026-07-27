defmodule MishkaMob.Components.MishkaAnchor do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Anchor** — a link.

  ## A link is a tap plus a destination

  There is no `<a>` on a device, but there is navigation, so this is a real port
  rather than a stub. An anchor is a tappable `Text`, and where the tap goes is
  the screen's business:

    * an external URL → `MishkaMob.Components.MishkaAnchor.open/1`, which wraps
      `Mob.Device.open_url/1`
    * another screen → `Mob.Socket.push_screen/3`

  The component does not perform either. A node tree is a description, so
  side effects belong to the screen that receives the event — the same rule
  `MishkaMob.Components.MishkaScroller` follows. `on_tap` therefore carries the
  destination with it as `{tag, href}`, so one handler can serve every link on
  a page.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `label` | string | `nil` | The link text. Children override it. |
  | `href` | string | `nil` | Sent back with the tap. |
  | `on_tap` | event tag (atom) | — | `{:tap, {tag, href}}`, or `{:tap, tag}` with no href. |
  | `color` | color token / ARGB | `:primary` | Link colour. |
  | `underline` | boolean | `true` | Draw a rule under the text. |
  | `text_size` | size token | `:base` | Text size. |
  | `disabled` | boolean | `false` | Mutes and unwires. |

  Not ported: `target` / `rel` / `download` and `navigate` vs `patch` — the
  distinction is a LiveView routing concept, and on a device the screen decides
  how to navigate.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaAnchor>`). Children override `label`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: anchor(props, children)

  @doc """
  The anchor.

      <MishkaAnchor label="mishka.tools" href="https://mishka.tools" on_tap={:open} />
  """
  @spec anchor(map() | keyword(), [map()]) :: map()
  def anchor(props \\ %{}, children \\ []) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))
    ink = if disabled?, do: :muted, else: Map.get(props, :color, :primary)
    size = Map.get(props, :text_size, :base)

    # Bound first: ~MOB(...) ends at the first ")", so an interpolated call with
    # arguments breaks the parse. The heredoc form has no such limit.
    label = Map.get(props, :label, "")

    content =
      case List.wrap(children) do
        [] -> [~MOB(<Text text={label} text_size={size} text_color={ink} />)]
        given -> given
      end

    ~MOB"""
    <Column>
      {content}
      {rule(props, ink)}
    </Column>
    """
    |> put(:on_tap, handler(props, disabled?))
  end

  defp rule(props, ink) do
    if truthy?(Map.get(props, :underline, true)) do
      ~MOB(<Box fill_width={true} height={1} background={ink} />)
    end
  end

  # The href rides along with the tag, so one handler can serve a page of links.
  defp handler(_props, true), do: nil

  defp handler(props, _disabled?) do
    case {Map.get(props, :on_tap), Map.get(props, :href)} do
      {nil, _} -> nil
      {tag, nil} -> Event.handler(tag)
      {tag, href} -> Event.handler({tag, href})
    end
  end

  @doc """
  Open an external URL, which is what an `href` means on a device.

  Returns `:ok`, or `:error` for anything that is not an http(s) URL — a
  component should never hand an arbitrary string to the platform's URL opener.

      iex> MishkaMob.Components.MishkaAnchor.open("ftp://example.com")
      :error

      iex> MishkaMob.Components.MishkaAnchor.open(nil)
      :error
  """
  @spec open(String.t() | nil) :: :ok | :error
  def open(url) when is_binary(url) do
    if String.starts_with?(url, ["http://", "https://"]) do
      Mob.Device.open_url(url)
      :ok
    else
      :error
    end
  end

  def open(_), do: :error

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
