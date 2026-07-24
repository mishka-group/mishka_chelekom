defmodule MishkaMob.Components.MishkaVisuallyHidden do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless Visually Hidden** — and the
  one component in this port that cannot do its job.

  ## Why it renders nothing

  The web component hides content visually while leaving it in the accessibility
  tree, which is what makes it useful: extra labels, live-region text, skip-link
  content. That trick needs two things — a way to render a node without showing
  it, and a way for the platform's screen reader to read it anyway.

  Mob has neither. There is no semantics or accessibility-label prop on any node
  type in the bridge; the single exception is `Image`, whose `description` prop
  becomes a `contentDescription` on Android. So there is no node this component
  could return that TalkBack or VoiceOver would announce.

  Given that, the only honest implementations are to render the content
  **visibly** — which is not what the caller asked for and would corrupt the
  layout — or to render **nothing**. It renders nothing, and `announce?/0`
  returns `false` so a caller can branch on it rather than discovering the
  emptiness at runtime.

  ## What to do instead, today

    * put the text in the visible label — on a phone there is usually room, and
      it helps everyone
    * for an icon-only control, use an `Image` with a `description`
    * `Mob.Speech` can speak a string outright, which covers the live-region case

  ## If the bridge grows semantics

  The moment nodes gain an accessibility-label prop, this component becomes a
  one-liner over it and the API here does not have to change: it already takes
  the content and already reports whether it can be announced.
  """

  import Mob.Sigil

  @doc "Composite expander (`<MishkaVisuallyHidden>`). Delegates to `visually_hidden/2`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, children, _ctx), do: visually_hidden(props, children)

  @doc """
  An empty node.

  The children are accepted and dropped deliberately: the call site stays
  truthful about intent, and becomes correct for free if Mob ever grows an
  accessibility-label prop.
  """
  @spec visually_hidden(map() | keyword(), [map()]) :: map()
  def visually_hidden(_props \\ %{}, _children \\ []) do
    ~MOB(<Spacer size={0} />)
  end

  @doc """
  Whether hidden content can actually reach a screen reader on this platform.

  Always `false` today. Branch on it instead of assuming.

      iex> MishkaMob.Components.MishkaVisuallyHidden.announce?()
      false
  """
  @spec announce?() :: boolean()
  def announce?, do: false
end
