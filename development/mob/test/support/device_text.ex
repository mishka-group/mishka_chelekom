defmodule MishkaMob.DeviceText do
  @moduledoc """
  What the screen asked a tagged node to say, for device tests whose assertion is
  a caption rather than a position ("Picked bold", "Value: nil").

  This reads the render tree (`MishkaMob.Device.render_tree/0`), like
  `MishkaMob.Device.assert_text/1`, so it answers "what did the screen render
  here" and not "what is drawn". It is addressed by tag, because the page is one
  eagerly rendered tree and every code sample on it is a text node too: asking for
  the text under a tag asks one component rather than the page.

  Import it next to the device case:

      use MishkaMob.DeviceCase, page: :toggle
      import MishkaMob.DeviceText
  """

  import MishkaMob.Device, only: [render_tree: 0]

  @doc """
  The `text` of the node tagged `tag`, or `nil` when no such node is rendered or
  it carries no text.
  """
  @spec text_of(tag :: String.t() | atom()) :: String.t() | nil
  def text_of(tag) do
    case node_tagged(render_tree(), to_string(tag)) do
      %{props: %{text: text}} when is_binary(text) -> text
      _no_text -> nil
    end
  end

  @doc """
  Every `text` rendered inside the node tagged `tag`, the node included, in tree
  order. Empty when there is no such node.
  """
  @spec texts_under(tag :: String.t() | atom()) :: [String.t()]
  def texts_under(tag) do
    case node_tagged(render_tree(), to_string(tag)) do
      nil -> []
      node -> collect_texts(node)
    end
  end

  @doc """
  Does the node tagged `tag` carry `label` as the text of one of its own nodes?

  A page-wide text query cannot say that: an example's source is rendered as a text
  node too, so a label quoted in a code sample is "on the page" whether or not the
  live component drew it.
  """
  @spec labelled?(tag :: String.t() | atom(), label :: String.t()) :: boolean()
  def labelled?(tag, label), do: label in texts_under(tag)

  defp node_tagged(%{props: props, children: children} = node, tag) do
    if to_string(Map.get(props, :id, "")) == tag,
      do: node,
      else: Enum.find_value(children || [], &node_tagged(&1, tag))
  end

  defp node_tagged(_leaf, _tag), do: nil

  defp collect_texts(%{props: props, children: children}) do
    own =
      case props do
        %{text: text} when is_binary(text) -> [text]
        _no_text -> []
      end

    own ++ Enum.flat_map(children || [], &collect_texts/1)
  end

  defp collect_texts(_leaf), do: []
end
