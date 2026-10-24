defmodule MishkaMob.Device do
  @moduledoc """
  The host-side driver of the device suite: one running MishkaMob app on a phone,
  driven over Erlang distribution through `Mob.Test`.

  Tests do not call this directly. `use MishkaMob.DeviceCase` imports it, connects
  once per module, and remounts the page under test before every test. The README
  next to the tests (`test/device/README.md`) shows how to write one.

  ## Why it paces every interaction the way it does

  The BEAM and the native side commit a render at different moments, and an event
  handle (the integer a tap sends back) carries the generation of the render that
  minted it. Native refuses a handle from a superseded generation. So a tap sent
  between "the BEAM committed render N+1" and "Compose drew render N+1" is silently
  dropped: it reaches no screen and leaves no trace.

  `Mob.Test.settle/2` proves the BEAM half. It is not enough: of 30 rapid taps, 12
  were dropped. `sync/0` adds the native half, `Mob.Test.screen_info/1`, which this
  app's bridge answers only after the main looper has run everything queued before
  it and drawn one more frame. With both, 180 of 180 toggles landed. Every
  interaction here ends in `sync/0`; none sleeps for a fixed time.

  ## Coordinates

  dp in the activity window, which is what `frame/1` reports and what `tap_xy/3`
  takes. A scroll offset is in pixels: `scroll_into_view/2` converts.

  ## Taps are verified

  A tap that reaches no handler would otherwise look like a tap that did nothing,
  and the test would fail somewhere downstream with a baffling message. Each tap
  compares `Mob.Agent.Receipts` before and after: a delivered event leaves a
  receipt, a dropped one does not. A drop is retried once (and counted, see
  `stats/0`), then fails loudly where it happened.

  What produces no receipt is the exception, and says so: `expect: :none` for a
  control that must do nothing, `expect: :any` (`touch/3`, `focus/1`) for a canvas or a
  text field with no `on_focus`.

  ## The keyboard and flings

  Focusing a text field raises the soft keyboard, which resizes the page over ~400ms;
  a frame read or a touch aimed inside that window lands on nothing. So a tap on a
  field, `focus/1`, and the first touch after typing wait for the page and the target
  to hold still. A drag ends in a fling, and a touch that lands on a fling stops it
  instead of reaching its target, so `drag/2` and `swipe/3` return only once the scroll
  has been still for a few drawn frames. Neither is a sleep: both poll the frame and
  scroll tables, one read per drawn frame.

  ## Reading the tree

  Native state (a field's own text, a switch's checked, enabled) is unreadable from the
  host. The helpers under "Reading the render tree" read what the screen asked for
  instead, addressed by tag: the page is one eagerly rendered tree and every code
  sample is a text node too, so a page-wide query can be satisfied by a sample.
  """

  import ExUnit.Assertions, only: [flunk: 1]

  alias MishkaMob.Showcase.ComponentScreen
  alias MishkaMob.ThemeBar
  alias Mob.Agent.{Receipt, Receipts}

  @typedoc "A laid-out element, in dp of the activity window."
  @type frame :: %{
          left: float(),
          top: float(),
          right: float(),
          bottom: float(),
          width: float(),
          height: float()
        }

  @typedoc "An element's id: the `:id` prop of its node."
  @type tag :: String.t() | atom()

  # The Android applicationId. mob_dev keys the app's private distribution cookie
  # on it (MobDev.DistCookie), and mob_dev is a :dev-only dependency, so the file
  # is read here rather than through it.
  @bundle_id "com.example.mishka_mob"
  @node_prefix "mishka_mob_android"
  @page "page"
  @theme :dark
  @hold_ms 650
  @poll_ms 10
  @eventually_ms 3_000
  # A drag ends in a fling, and a touch that lands on a fling stops it instead of
  # reaching what it was aimed at. Idle is this many reads in a row (one per drawn
  # frame) that agree, within a time bound for a page that never stops animating.
  @idle_reads 3
  @idle_ms 2_000
  # The distance in from a field's corner that a "caret at the end" touch lands.
  @corner_dp 4
  # The share of the screen a typical drawer drag travels.
  @step_share 0.15
  @reach_share 0.4

  # What the bridge in this branch must answer. An app installed from an older
  # build answers false to some of them, and every test would then fail on the
  # first interaction with a message about the symptom.
  @required [
    :screen_info,
    :tap_xy,
    :long_press_xy,
    :swipe_xy,
    :type_text,
    :delete_backward,
    :element_frames,
    :scroll_info,
    :scroll_to,
    :press_down_xy,
    :press_move_xy,
    :press_up_xy
  ]

  @node_key {__MODULE__, :node}
  @scale_key {__MODULE__, :scale}
  @stats_key {__MODULE__, :stats}
  # Per test process: layout that may still be moving because of the soft keyboard.
  @unsettled_key {__MODULE__, :unsettled}
  # Per test process: where the held finger is, so the lift lands where it went.
  @press_key {__MODULE__, :press}

  # ── Connecting ──────────────────────────────────────────────────────────────

  @doc """
  Connects to the running app and checks it can be driven. Returns its node.

  Distribution is started on this side if it is not already, the app's node is
  found in the Mac's EPMD (where the device registers through the `adb reverse`
  tunnel `mix mob.connect` sets up), and the app's private cookie is read from
  `~/.mob/dist_cookies`. It never restarts the app or touches adb.

  Override with `MOB_DEVICE_NODE` (a node name) and `MOB_DEVICE_COOKIE`.
  """
  @spec connect!() :: node()
  def connect! do
    cached = :persistent_term.get(@node_key, nil)

    if cached && Node.ping(cached) == :pong do
      cached
    else
      node = do_connect!()
      :persistent_term.put(@node_key, node)
      :persistent_term.put(@scale_key, Mob.Test.screen_info(node).scale)
      :persistent_term.put(@stats_key, :counters.new(2, []))
      node
    end
  end

  @doc "The connected app's node. Raises unless `connect!/0` has run."
  @spec device!() :: node()
  def device! do
    case :persistent_term.get(@node_key, nil) do
      nil -> raise "no device connected: `use MishkaMob.DeviceCase` connects before the tests run"
      node -> node
    end
  end

  defp do_connect! do
    ensure_distribution!()
    node = discover_node!()
    Node.set_cookie(node, cookie!())

    unless Node.connect(node) do
      raise """
      #{node} is in EPMD but did not accept the connection.

      The adb tunnels are probably gone (a replugged phone, a restarted adb), or the
      cookie is stale. Re-attach without restarting the app:

          mix mob.connect --no-iex --no-restart
      """
    end

    check_capabilities!(node)
    node
  end

  defp ensure_distribution! do
    unless Node.alive?() do
      if System.find_executable("epmd"), do: System.cmd("epmd", ["-daemon"])

      # The OS pid keeps two suites on one Mac (two worktrees, say) from fighting
      # over a name; the phone does not care what it is called.
      case Node.start(:"mishka_device_#{System.pid()}@127.0.0.1", :longnames) do
        {:ok, _pid} -> :ok
        {:error, reason} -> raise "could not start Erlang distribution: #{inspect(reason)}"
      end
    end
  end

  defp discover_node! do
    case System.get_env("MOB_DEVICE_NODE") do
      nil -> discover_in_epmd!()
      name -> String.to_atom(name)
    end
  end

  defp discover_in_epmd! do
    # The loopback address named outright: the no-argument form resolves this host's
    # name first, and on a Mac that alone takes five seconds.
    registered =
      case :net_adm.names(~c"127.0.0.1") do
        {:ok, names} -> for {name, _port} <- names, do: to_string(name)
        {:error, _reason} -> []
      end

    case Enum.filter(registered, &String.starts_with?(&1, @node_prefix)) do
      [name] ->
        :"#{name}@127.0.0.1"

      [] ->
        raise """
        No MishkaMob app is registered in EPMD (nodes there: #{inspect(registered)}).

        Start the app on the phone with the tunnels up:

            mix mob.connect --no-iex
        """

      many ->
        raise "several MishkaMob apps are registered (#{inspect(many)}); " <>
                "pick one with MOB_DEVICE_NODE=<name>@127.0.0.1"
    end
  end

  # Mirrors MobDev.DistCookie.default_path/1, which is unavailable here (see @bundle_id).
  defp cookie! do
    case System.get_env("MOB_DEVICE_COOKIE") do
      nil ->
        digest = Base.encode16(:crypto.hash(:sha256, @bundle_id), case: :lower)
        path = Path.join([System.user_home!(), ".mob", "dist_cookies", digest])

        case File.read(path) do
          {:ok, cookie} ->
            cookie |> String.trim() |> String.to_atom()

          {:error, reason} ->
            raise "no distribution cookie at #{path} (#{inspect(reason)}); " <>
                    "`mix mob.connect` creates it"
        end

      cookie ->
        String.to_atom(cookie)
    end
  end

  defp check_capabilities!(node) do
    caps = Mob.Test.capabilities(node)
    missing = Enum.reject(@required, &(Map.get(caps, &1) == true))

    if missing != [] do
      raise """
      The app on the phone cannot be driven for these: #{inspect(missing)}.

      It was built before the device harness. Install a build of this branch:

          mix android.native --device <serial>
      """
    end

    if :rpc.call(node, Code, :ensure_loaded?, [Receipts]) != true do
      raise "the app on the phone has no Mob.Agent.Receipts; update its mob to 0.9.25 or newer"
    end
  end

  # ── Pacing ──────────────────────────────────────────────────────────────────

  @doc """
  Returns once everything the app has been asked to do is on screen.

  `Mob.Test.settle/2` (the screen processed it and the sender committed the
  frame) followed by the native barrier (the main looper applied that frame and
  one more was drawn). See the moduledoc for why both.
  """
  @spec sync() :: :ok
  def sync do
    node = device!()

    # settle/2 is a chain of seven calls into the app. Run from here each is a round
    # trip over the USB tunnel (~20ms in all); run on the device they are local (~5ms),
    # and Mob.Test ships in the app. `node` is its own target.
    :ok = :rpc.call(node, Mob.Test, :settle, [node])
    native_barrier(node)
  end

  @doc "Only the native half of `sync/0`: wait for the next frame to be drawn."
  @spec barrier() :: :ok
  def barrier, do: native_barrier(device!())

  defp native_barrier(node) do
    case Mob.Test.screen_info(node) do
      %{width: width} when width > 0 -> :ok
      other -> raise "the native barrier did not answer: #{inspect(other)}"
    end
  end

  @doc """
  Polls `fun` until it returns a truthy value, and returns that value.

  A `fun` that raises `ExUnit.AssertionError` counts as "not yet" and is tried
  again, so the assertions of the condition can sit inside it. Any other
  exception propagates at once. Polls every #{@poll_ms}ms; there is no fixed wait.
  After `:timeout` (default #{@eventually_ms}ms) it fails with `:message` (a string
  or a function returning one) and what the last attempt said.
  """
  @spec assert_eventually(fun :: (-> term()), opts :: keyword()) :: term()
  def assert_eventually(fun, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @eventually_ms)
    deadline = System.monotonic_time(:millisecond) + timeout
    poll(fun, deadline, timeout, Keyword.get(opts, :message, "condition never held"))
  end

  defp poll(fun, deadline, timeout, message) do
    outcome = attempt_once(fun)

    case outcome do
      {:ok, value} when value not in [nil, false] ->
        value

      _not_yet ->
        if System.monotonic_time(:millisecond) >= deadline do
          flunk("#{resolve(message)} (waited #{timeout}ms)#{last_attempt(outcome)}")
        else
          Process.sleep(@poll_ms)
          poll(fun, deadline, timeout, message)
        end
    end
  end

  defp attempt_once(fun) do
    {:ok, fun.()}
  rescue
    error in ExUnit.AssertionError -> {:error, error}
  end

  defp resolve(message) when is_function(message, 0), do: message.()
  defp resolve(message), do: message

  defp last_attempt({:error, %ExUnit.AssertionError{message: message}}),
    do: "\nlast attempt failed with: " <> message

  defp last_attempt({:ok, value}), do: "\nlast attempt returned: " <> inspect(value)

  # ── Reading the screen ──────────────────────────────────────────────────────

  @doc """
  The frame of the node whose `:id` is `tag`, or `nil` when it is not laid out.

  A node that left the composition has no frame (the bridge drops it on disposal),
  so `nil` is also "not on the screen at all". A node laid out with no area counts
  as not laid out.
  """
  @spec frame(tag :: tag()) :: frame() | nil
  def frame(tag), do: lookup(frames(), tag)

  defp lookup(frames, tag) do
    case Map.get(frames, to_string(tag)) do
      {x, y, w, h} when w > 0 and h > 0 -> rect(x, y, w, h)
      _missing -> nil
    end
  end

  @doc "`frame/1`, failing with what is on screen instead of returning `nil`."
  @spec frame!(tag :: tag()) :: frame()
  def frame!(tag) do
    frame(tag) || flunk(not_shown_message(tag))
  end

  @doc "Every tracked frame, by id, as `{x, y, width, height}`."
  @spec frames() :: %{optional(String.t()) => {float(), float(), float(), float()}}
  def frames do
    case Mob.Test.element_frames(device!()) do
      %{} = frames -> frames
      error -> raise "could not read the frame table: #{inspect(error)}"
    end
  end

  @doc """
  The frame of `tag` once it stops moving.

  A popup window follows its anchor asynchronously, so a frame read the moment
  the panel appears can be a frame in flight. This reads once per drawn frame
  until two reads agree.
  """
  @spec settled_frame(tag :: tag()) :: frame()
  def settled_frame(tag) do
    assert_shown(tag)
    settle_frame(tag, frame!(tag), 40)
  end

  defp settle_frame(_tag, last, 0), do: last

  defp settle_frame(tag, previous, budget) do
    barrier()
    current = frame!(tag)

    if current == previous, do: current, else: settle_frame(tag, current, budget - 1)
  end

  @doc "The centre of a frame, as `{x, y}` dp."
  @spec center(frame :: frame()) :: {float(), float()}
  def center(%{left: left, top: top, width: width, height: height}),
    do: {left + width / 2, top + height / 2}

  @doc "Is `tag` laid out on screen?"
  @spec shown?(tag :: tag()) :: boolean()
  def shown?(tag), do: frame(tag) != nil

  @doc "Fails unless `tag` is laid out. Waits for it, since a render may still be landing."
  @spec assert_shown(tag :: tag(), opts :: keyword()) :: frame()
  def assert_shown(tag, opts \\ []) do
    assert_eventually(
      fn -> frame(tag) end,
      Keyword.put_new(opts, :message, fn -> not_shown_message(tag) end)
    )
  end

  @doc """
  Fails unless `tag` is gone. Waits for it, since a closing panel may still be leaving.

  A negative check passes at once when nothing was there, so it proves nothing
  unless an interaction that could have put it there happened first. Every
  interaction in this module ends in `sync/0`, which is what makes that so.
  """
  @spec refute_shown(tag :: tag(), opts :: keyword()) :: true
  def refute_shown(tag, opts \\ []) do
    assert_eventually(
      fn -> frame(tag) == nil end,
      opts |> Keyword.put_new(:timeout, 1_000) |> Keyword.put_new(:message, "#{tag} is on screen")
    )
  end

  defp not_shown_message(tag) do
    tag = to_string(tag)
    prefix = tag |> String.split("-", parts: 2) |> hd()

    near =
      frames()
      |> Map.keys()
      |> Enum.filter(&String.starts_with?(&1, prefix))
      |> Enum.sort()
      |> Enum.take(16)

    "no laid-out node tagged #{inspect(tag)}. Tags starting #{inspect(prefix)}: #{inspect(near)}"
  end

  @doc "The screen's assigns."
  @spec assigns() :: map() | nil
  def assigns, do: Mob.Test.assigns(device!())

  @doc """
  The tree the screen renders, composites expanded: what `render/1` produced,
  not what was drawn.
  """
  @spec render_tree() :: map()
  def render_tree do
    node = device!()
    pid = :rpc.call(node, Mob.Screen, :get_screen_pid, [:mob_screen])
    :rpc.call(node, Mob.Composite, :expand, [Mob.Test.tree(node), pid])
  end

  @doc """
  Fails unless some node of the rendered tree carries `text` in a string prop.

  This reads the render tree, so it answers "did the screen ask for this text",
  not "is it visible". Page text is ambiguous (a code sample is text too), so
  prefer a tag, and use this for headings and labels that have none.
  """
  @spec assert_text(text :: String.t()) :: :ok
  def assert_text(text) do
    if tree_has_text?(render_tree(), text),
      do: :ok,
      else: flunk("no node renders #{inspect(text)}")
  end

  @doc false
  @spec tree_has_text?(tree :: map(), text :: String.t()) :: boolean()
  def tree_has_text?(%{props: props, children: children}, text) do
    Enum.any?(props, fn {_key, value} -> is_binary(value) and String.contains?(value, text) end) or
      Enum.any?(children || [], &tree_has_text?(&1, text))
  end

  def tree_has_text?(_leaf, _text), do: false

  # ── Reading the render tree ─────────────────────────────────────────────────
  #
  # What the screen asked for, found by tag. The page is one eagerly rendered
  # tree and every code sample on it is a text node too, so ask a tag, not the
  # page. Native state (a field's own text, a switch's checked) is not readable
  # from the host; the tree stands in for it, and a test says so in a comment.

  @doc """
  The node of the rendered tree whose `:id` is `tag`, or `nil` when none is.
  """
  @spec find_node(tag :: tag()) :: map() | nil
  def find_node(tag), do: find_node(render_tree(), tag)

  @doc """
  `find_node/1` in a tree you already hold: `render_tree/0`, or a subtree of it.
  """
  @spec find_node(tree :: map() | nil, tag :: tag()) :: map() | nil
  def find_node(%{props: props, children: children} = node, tag) do
    if to_string(Map.get(props, :id, "")) == to_string(tag),
      do: node,
      else: Enum.find_value(children || [], &find_node(&1, tag))
  end

  def find_node(_leaf, _tag), do: nil

  @doc "`find_node/1`, failing instead of returning `nil`."
  @spec node!(tag :: tag()) :: map()
  def node!(tag), do: find_node(tag) || flunk("no node tagged #{tag}")

  @doc """
  The `text` of the node tagged `tag`, or `nil` when no such node is rendered or
  it carries none. For a caption that may not be there yet, inside
  `assert_eventually/2`. `text_of!/1` when it must be.
  """
  @spec text_of(tag :: tag()) :: String.t() | nil
  def text_of(tag) do
    case find_node(tag) do
      %{props: %{text: text}} when is_binary(text) -> text
      _no_text -> nil
    end
  end

  @doc "`text_of/1`, failing when there is no such node or it carries no text."
  @spec text_of!(tag :: tag()) :: String.t()
  def text_of!(tag) do
    case find_node(tag) do
      %{props: %{text: text}} -> text
      nil -> flunk("no node tagged #{tag}")
      other -> flunk("#{tag} carries no text: #{inspect(other.props)}")
    end
  end

  @doc """
  The `value` the screen gave the text field tagged `tag`. What the screen told
  the field to show: a field that kept its own text while the assign said
  otherwise would pass any check on the assign alone.
  """
  @spec value_of(tag :: tag()) :: String.t()
  def value_of(tag) do
    case find_node(tag) do
      %{props: %{value: value}} -> value
      nil -> flunk("no node tagged #{tag}")
      other -> flunk("#{tag} carries no value: #{inspect(other.props)}")
    end
  end

  @doc """
  Every `text` rendered in `tree` (default: the whole screen), in tree order.
  Compare whole (`"3 of 5 bars" in texts()`), never by substring: a code sample
  quotes the same words.
  """
  @spec texts(tree :: map() | nil) :: [String.t()]
  def texts(tree \\ render_tree())

  def texts(%{props: props, children: children}) do
    own = if is_binary(props[:text]), do: [props.text], else: []

    own ++ Enum.flat_map(children || [], &texts/1)
  end

  def texts(_leaf), do: []

  @doc """
  Every `text` rendered inside the node tagged `tag`, the node included. Empty
  when there is no such node.
  """
  @spec texts_under(tag :: tag()) :: [String.t()]
  def texts_under(tag) do
    case find_node(tag) do
      nil -> []
      node -> texts(node)
    end
  end

  @doc """
  Does the node tagged `tag` carry `label` as the text of one of its own nodes?

  A page-wide text query cannot say that: an example's source is rendered as a text
  node too, so a label quoted in a code sample is "on the page" whether or not the
  live component drew it.
  """
  @spec labelled?(tag :: tag(), label :: String.t()) :: boolean()
  def labelled?(tag, label), do: label in texts_under(tag)

  @doc "How many nodes of the screen read exactly `text`."
  @spec text_count(text :: String.t()) :: non_neg_integer()
  def text_count(text), do: Enum.count(texts(), &(&1 == text))

  @doc """
  Is `text` rendered anywhere in a string prop of the screen? Substring, any
  node: it answers "did the screen ask for this", so it needs a string no code
  sample quotes, or an interaction that makes the difference.
  """
  @spec showing?(text :: String.t()) :: boolean()
  def showing?(text), do: tree_has_text?(render_tree(), text)

  @doc """
  The first rendered text that is, whole, `pattern` (`~r/\\A\\d+°\\z/`), or `nil`.

  Whole, because a page's own description often contains the unit ("Pick a hue,
  0-360°") and a substring match returns the prose.
  """
  @spec readout(pattern :: Regex.t()) :: String.t() | nil
  def readout(pattern), do: Enum.find(texts(), &Regex.match?(pattern, &1))

  @doc "`readout/1` as the integer it starts with, failing when none is on screen."
  @spec readout_int(pattern :: Regex.t()) :: integer()
  def readout_int(pattern) do
    text = readout(pattern) || flunk("no #{inspect(pattern)} readout on screen")

    [digits] = Regex.run(~r/\d+/, text)
    String.to_integer(digits)
  end

  @doc """
  The percentage the topmost `NN%` readout reports. Topmost, because a page shows
  several and the first is the one wired to its buttons.
  """
  @spec percent() :: integer()
  def percent, do: readout_int(~r/\A\d+%\z/)

  @doc """
  Which of `states` the control `prefix` is in, read from the tag it carries now
  (`"<prefix>-<state>"`), or `nil` when it is in none. Controls that draw their
  state as a colour put it in the tag, since a colour is not readable.
  """
  @spec state_of(prefix :: String.t(), states :: [String.t()]) :: String.t() | nil
  def state_of(prefix, states), do: Enum.find(states, &shown?("#{prefix}-#{&1}"))

  @doc """
  `state_of/2` for a state that must exist. Insisting on one, rather than accepting
  `nil`, means a control that failed to render fails the test instead of quietly
  satisfying it.
  """
  @spec state_of!(prefix :: String.t(), states :: [String.t()]) :: String.t()
  def state_of!(prefix, states), do: state_of(prefix, states) || flunk("#{prefix} is untagged")

  @doc "The whole tag of `prefix`, state included: the state moves and the tag follows."
  @spec state_tag(prefix :: String.t(), states :: [String.t()]) :: String.t()
  def state_tag(prefix, states), do: "#{prefix}-#{state_of!(prefix, states)}"

  @doc """
  Fails unless every heading is rendered, and the page scrolls (so its props
  table, the last thing on it, is reachable). The closing test of a page.
  """
  @spec assert_headings(headings :: [String.t()]) :: :ok
  def assert_headings(headings) do
    for heading <- headings, do: assert_text(heading)

    %{max_offset: {_x, max_y}} = Mob.Test.scroll_info(device!(), @page)
    if max_y <= 0, do: flunk("the page does not scroll, so the props table is out of reach")

    :ok
  end

  # ── Pages ───────────────────────────────────────────────────────────────────

  @doc """
  Remounts a component's showcase page with fresh assigns and returns when it is
  on screen, scrolled to the top, in the default theme.

  This is the per-test reset. The app keeps running and nothing is relaunched, so
  it costs ~150ms where an Activity relaunch costs seconds. It clears the frame
  and scroll tables natively, and resets the one piece of global state the
  showcase has (the theme, kept in `Mob.State`).

  `slug` is the component's catalog slug (`:popover`, `:otp_field`).
  """
  @spec fresh_page(slug :: atom(), opts :: keyword()) :: :ok
  def fresh_page(slug, opts \\ []) do
    node = device!()
    Process.delete(@unsettled_key)
    reset_theme(node, Keyword.get(opts, :theme, @theme))

    :ok = Mob.Test.reset_to(node, ComponentScreen, %{slug: slug})
    sync()

    assert_eventually(
      fn -> match?(%{entry: %{slug: ^slug}}, assigns()) and shown?(@page) end,
      message: fn -> "the #{inspect(slug)} page did not come up: #{inspect(assigns())}" end
    )

    # A fresh composition starts at the top; this only matters if Compose reused
    # the old scroll state, and costs nothing when it did not.
    case Mob.Test.scroll_info(node, @page) do
      %{offset: {_x, +0.0}} -> :ok
      _scrolled -> scroll_page(:top)
    end
  end

  defp reset_theme(node, key) do
    if :rpc.call(node, Mob.State, :get, [:theme, @theme]) != key do
      :rpc.call(node, Mob.Theme, :set, [ThemeBar.module_for(key)])
      :rpc.call(node, Mob.State, :put, [:theme, key])
    end

    :ok
  end

  # ── Scrolling ───────────────────────────────────────────────────────────────

  @doc "Scrolls the page to `:top`, `:bottom` or `{:page, n}` and waits for it to land."
  @spec scroll_page(target :: :top | :bottom | {:page, number()}) :: :ok
  def scroll_page(target) do
    :ok = Mob.Test.scroll_to(device!(), @page, target)
    sync()
  end

  @doc """
  Scrolls the page so `tag` is on screen, centred when it had to move. A no-op
  when it already is, and when there is no scroll to move. Returns the frame afterwards.

  Options:

    * `:in` - the id of a scroll other than the page's.
    * `:center` - also bring a tag that is on screen, but more than a quarter of the
      viewport from its middle, to the middle, and return its settled frame. For a
      gesture that needs room to travel both ways: a tag whose centre is merely
      visible can sit hard against an edge, and a drag toward that edge leaves the
      window.
  """
  @spec scroll_into_view(tag :: tag(), opts :: keyword()) :: frame()
  def scroll_into_view(tag, opts \\ []) do
    scroller = Keyword.get(opts, :in, @page)
    center? = Keyword.get(opts, :center, false)
    frames = frames()
    target = lookup(frames, tag) || flunk(not_shown_message(tag))

    framed =
      case lookup(frames, scroller) do
        nil ->
          target

        viewport ->
          if visible?(target, viewport) and not (center? and off_middle?(target, viewport)),
            do: target,
            else: scroll_to_center(tag, scroller, viewport)
      end

    if center?, do: settled_frame(tag), else: framed
  end

  defp scroll_to_center(tag, scroller, viewport) do
    node = device!()
    %{offset: {_x, offset}} = Mob.Test.scroll_info(node, scroller)
    {_cx, wanted} = tag |> frame!() |> center()
    {_vx, middle} = center(viewport)

    # Frames are dp; a scroll offset is px.
    :ok = Mob.Test.scroll_to(node, scroller, {0.0, offset + (wanted - middle) * scale()})
    sync()

    assert_eventually(
      fn -> visible?(frame!(tag), frame!(scroller)) end,
      message: fn ->
        "#{tag} stayed outside #{scroller} after scrolling: " <>
          "#{inspect(frame(tag))} vs #{inspect(frame(scroller))}"
      end
    )

    frame!(tag)
  end

  # The centre is what a tap lands on; an element taller than the viewport is
  # never wholly inside it, and scrolling to fit it would never end.
  defp visible?(inner, outer) do
    {_x, y} = center(inner)
    y >= outer.top and y <= outer.bottom
  end

  defp off_middle?(inner, outer) do
    {_x, y} = center(inner)
    {_ox, middle} = center(outer)

    abs(y - middle) > outer.height / 4
  end

  defp scale, do: :persistent_term.get(@scale_key)

  # ── Geometry ────────────────────────────────────────────────────────────────

  @doc """
  The point a fraction `fx` across and `fy` down `tag` (default: its centre), after
  scrolling the page to it. Kept just inside the frame: its right and bottom edges
  belong to whatever is next to it.
  """
  @spec point(tag :: tag(), fx :: number(), fy :: number()) :: {float(), float()}
  def point(tag, fx \\ 0.5, fy \\ 0.5) do
    frame = scroll_into_view(tag)

    {min(frame.left + frame.width * fx, frame.right - 0.05),
     min(frame.top + frame.height * fy, frame.bottom - 0.05)}
  end

  @doc "Do two frames sit on one row? Their centres are less than a frame's height apart."
  @spec same_row?(a :: frame(), b :: frame()) :: boolean()
  def same_row?(a, b) do
    {_x, a_y} = center(a)
    {_x, b_y} = center(b)

    abs(a_y - b_y) < a.height
  end

  @doc """
  A point outside `frame` that a finger could land on: the left gutter, `gap` dp
  below it, or above it when there is no room below (a panel sits low on the page
  when its trigger does).
  """
  @spec outside(frame :: frame(), gap :: number()) :: {float(), float()}
  def outside(frame, gap \\ 80) do
    page = frame!(@page)
    below = frame.bottom + gap

    if below < page.bottom, do: {10.0, below}, else: {10.0, frame.top - gap}
  end

  @doc "The window the device reports: `width` and `height` in dp, `scale`, and the insets."
  @spec screen() :: map()
  def screen, do: Mob.Test.screen_info(device!())

  @doc """
  A vertical drag distance, roughly 15% of the screen's height (~125dp): past a
  sheet's 48dp threshold, inside one of its snap steps.
  """
  @spec step() :: float()
  def step, do: screen().height * @step_share

  @doc """
  A sideways drag distance, roughly 40% of the screen's width (~150dp): clears a
  64dp threshold on any density.
  """
  @spec reach() :: float()
  def reach, do: screen().width * @reach_share

  # ── Touch ───────────────────────────────────────────────────────────────────

  @doc """
  A real touch at the centre of `tag`: DOWN and UP delivered in-process to the
  window a finger would reach there (a popup's own window included), after
  scrolling the page to it if it is off screen.

  Returns the receipts the tap produced. Options:

    * `:expect` - `:event` (default): the tap must reach a handler, retried once
      if it does not and failed if it still does not. `:none`: it must reach
      nothing (a disabled control), and the test fails if it does. `:any`: it only
      has to be dispatched, and leaves a receipt or not. For what produces none: a
      canvas, whose drag is a stream and not a discrete event, and a field that
      already holds focus.
    * `:retry` - how many times a dropped tap is repeated. Default 1; 0 to see raw drops.

  A tap on a text field raises the soft keyboard, which resizes the page over the
  next ~400ms, so it returns once the page and the field have stopped moving. The
  first touch after typing waits the same way before it aims. A field with no
  `on_focus` delivers no event, so a tap on it fails with "reached no handler":
  use `focus/1`.
  """
  @spec tap(tag :: tag(), opts :: keyword()) :: [Receipt.t()]
  def tap(tag, opts \\ []) do
    receipts =
      deliver("tap #{tag}", opts, fn ->
        settle_if_unsettled(tag)
        {x, y} = point(tag)
        Mob.Test.tap_xy(device!(), x, y)
      end)

    # A text field reports the edge of gaining focus, and that is how a tap is
    # known to have landed on one without another round trip to ask.
    if Enum.any?(receipts, &match?({:focus, _address}, &1.event)), do: settle_layout([tag])

    receipts
  end

  @doc "A real touch at `(x, y)` dp of the activity window. Options as in `tap/2`."
  @spec tap_xy(x :: number(), y :: number(), opts :: keyword()) :: [Receipt.t()]
  def tap_xy(x, y, opts \\ []) do
    deliver("tap at (#{x}, #{y})", opts, fn ->
      settle_if_unsettled(nil)
      Mob.Test.tap_xy(device!(), x, y)
    end)
  end

  @doc """
  A real touch a fraction `fx` across and `fy` down `tag` (default: its centre),
  with no handler required (`tap/2` with `expect: :any`).

  For a canvas, where the position of the touch is the value: its drag reaches the
  screen as a stream, which leaves no receipt for `tap/2` to find. What proves the
  touch landed is the readout the page renders from its own assign.

  A plain touch, not a swipe: a canvas reports `phase: "began"` on touch-down, so a
  tap sets the value outright, which is what the colour sliders were rebuilt to do.
  """
  @spec touch(tag :: tag(), fx :: number(), fy :: number()) :: [Receipt.t()]
  def touch(tag, fx \\ 0.5, fy \\ 0.5) do
    deliver("touch #{tag} at #{fx}, #{fy}", [expect: :any], fn ->
      settle_if_unsettled(tag)
      {x, y} = point(tag, fx, fy)
      Mob.Test.tap_xy(device!(), x, y)
    end)
  end

  @doc """
  A real touch in the bottom-right corner of the text field `tag`: past the end of
  its last line, so the caret lands at the end of the text whatever its length. It
  returns once the keyboard's resize has settled.

  For a field with no `on_focus` handler, which delivers no event and so cannot be
  tapped, and for one that already has focus. A touch in the middle would leave the
  caret mid-text.
  """
  @spec focus(tag :: tag()) :: :ok
  def focus(tag) do
    deliver("focus #{tag}", [expect: :any], fn ->
      settle_if_unsettled(tag)
      scroll_into_view(tag)
      frame = settled_frame(tag)

      Mob.Test.tap_xy(device!(), frame.right - @corner_dp, frame.bottom - @corner_dp)
    end)

    settle_layout([tag])
  end

  @doc """
  A real long press on `tag`: the finger stays down for `ms` (default #{@hold_ms},
  past Android's 500ms long-press timeout), so this blocks that long. Options as
  in `tap/2`.
  """
  @spec hold(tag :: tag(), ms :: pos_integer(), opts :: keyword()) :: [Receipt.t()]
  def hold(tag, ms \\ @hold_ms, opts \\ []) do
    deliver("hold #{tag}", opts, fn ->
      settle_if_unsettled(tag)
      {x, y} = point(tag)
      Mob.Test.long_press_xy(device!(), x, y, ms)
    end)
  end

  @doc """
  A real drag from the centre of `tag` by `{dx, dy}` dp, over real frames so touch
  slop is crossed. Scrolls a scroll view, moves a slider.

  It returns once the drag's fling is over (see `swipe/3`), watching `tag` itself
  too: a scroll view's own offset, or the frame of what the drag moves.
  """
  @spec drag(tag :: tag(), by :: {number(), number()}) :: :ok
  def drag(tag, {dx, dy}) do
    settle_if_unsettled(tag)
    {x, y} = point(tag)
    swipe({x, y}, {x + dx, y + dy}, watch: tag)
  end

  @doc """
  A real swipe between two points, in dp of the activity window.

  A finger lifted at speed leaves a fling, and a touch that lands on a fling stops
  it instead of reaching its target: taps 90 to 350ms after a drag were lost, even
  retried. So this returns only once the page's scroll offset (and, with `:watch`, a
  tag's scroll offset and frame) has held still for #{@idle_reads} drawn frames. A
  drag on a canvas moves nothing and returns at once. A canvas drag leaves no
  receipt either (see the `:expect` option of `tap/2`), and none is required.
  """
  @spec swipe(from :: {number(), number()}, to :: {number(), number()}, opts :: keyword()) ::
          :ok
  def swipe({x1, y1}, {x2, y2}, opts \\ []) do
    settle_if_unsettled(nil)
    expect_ok!("swipe", Mob.Test.swipe(device!(), x1, y1, x2, y2))
    sync()
    await_scroll_idle(Keyword.get(opts, :watch))
  end

  defp await_scroll_idle(watch) do
    deadline = System.monotonic_time(:millisecond) + @idle_ms
    idle_after(watch, scroll_snapshot(watch), 0, deadline)
  end

  # One read per drawn frame, until `@idle_reads` of them in a row agree.
  defp idle_after(_watch, _last, @idle_reads, _deadline), do: :ok

  defp idle_after(watch, last, still, deadline) do
    if System.monotonic_time(:millisecond) >= deadline do
      :ok
    else
      barrier()
      now = scroll_snapshot(watch)

      if now == last,
        do: idle_after(watch, now, still + 1, deadline),
        else: idle_after(watch, now, 0, deadline)
    end
  end

  defp scroll_snapshot(watch) do
    {scroll_offset(@page), watch && scroll_offset(watch), watch && frame(watch)}
  end

  defp scroll_offset(id) do
    case Mob.Test.scroll_info(device!(), id) do
      %{offset: offset} -> offset
      _not_a_scroll -> nil
    end
  end

  # ── Held press ──────────────────────────────────────────────────────────────

  @doc """
  Puts a finger down at `{x, y}` dp, runs `fun`, and lifts it: the lift is in an
  `after`, so a failing assertion inside `fun` cannot leave the app believing a
  finger is on the glass for the rest of the suite. Use `press_move/1` inside to
  drag the held finger; it lifts where it last was. Returns what `fun` returns.

  The other gestures (`tap/2`, `swipe/3`, `hold/3`) refuse while a finger is down.
  """
  @spec while_pressed(at :: {number(), number()}, fun :: (-> result)) :: result
        when result: term()
  def while_pressed({x, y} = at, fun) do
    node = device!()
    expect_ok!("press down", Mob.Test.press_down_xy(node, x, y))
    Process.put(@press_key, at)
    sync()

    try do
      fun.()
    after
      {up_x, up_y} = Process.delete(@press_key)
      Mob.Test.press_up_xy(node, up_x, up_y)
      sync()
    end
  end

  @doc "Moves the finger `while_pressed/2` holds down to `{x, y}` dp, and waits for the app."
  @spec press_move(to :: {number(), number()}) :: :ok
  def press_move({x, y} = to) do
    expect_ok!("press move", Mob.Test.press_move_xy(device!(), x, y))
    Process.put(@press_key, to)
    sync()
  end

  @doc """
  Delivers the handler message `tag`'s node carries in `prop` (`:on_tap`,
  `:on_long_press`, `:on_tap` of an `anchored` node is its dismiss) without a
  touch. For what a touch cannot reach: a control a modal popup covers, or a
  handler whose payload is the thing under test. A test that uses it says why in
  a comment.
  """
  @spec event(tag :: tag(), prop :: atom()) :: [Receipt.t()]
  def event(tag, prop \\ :on_tap) do
    deliver("#{prop} of #{tag}", [], fn ->
      case find_node(tag) do
        %{props: %{^prop => {_pid, handler}}} -> Mob.Test.tap(device!(), handler)
        other -> flunk("#{tag} has no #{prop}: #{inspect(other && other.props)}")
      end
    end)
  end

  # ── The soft keyboard ───────────────────────────────────────────────────────

  @doc """
  Types `text` (ASCII only) into the focused field, as one key event. `focus/1` or
  `tap/2` the field first. For a value the screen sanitises key by key, `type_each/1`.
  """
  @spec type(text :: String.t()) :: :ok
  def type(text) do
    expect_ok!("type #{inspect(text)}", Mob.Test.type_text(device!(), text))
    Process.put(@unsettled_key, true)
    sync()
  end

  @doc """
  One key at a time, settling between them, as a person types: the screen answers
  each value before the next key arrives.
  """
  @spec type_each(text :: String.t()) :: :ok
  def type_each(text) do
    for char <- String.graphemes(text), do: type(char)

    :ok
  end

  @doc "Presses backspace `count` times in the focused field."
  @spec delete_backward(count :: pos_integer()) :: :ok
  def delete_backward(count \\ 1) do
    for _press <- 1..count//1 do
      expect_ok!("backspace", Mob.Test.delete_backward(device!()))
      Process.put(@unsettled_key, true)
      sync()
    end

    :ok
  end

  @doc """
  Replaces what is in the text field `tag` with `text`, the way a person would: a
  touch to put the caret at the end (`focus/1`), a backspace per character of the
  value the screen gave the field, then the keys.

  There is no select-all or clear-text in the harness, and a touch in the middle of
  the field would leave the caret mid-text.
  """
  @spec replace_text(tag :: tag(), text :: String.t()) :: :ok
  def replace_text(tag, text) do
    current = value_of(tag)

    focus(tag)
    delete_backward(String.length(current))
    type_each(text)
  end

  # The soft keyboard resizes the page over ~400ms after a field is focused, and what
  # typing adds re-flows it. A frame read inside that window is a frame in flight, and
  # a touch aimed at it lands on nothing: wait for the frames to hold still.
  defp settle_layout(tags) do
    Process.delete(@unsettled_key)
    for tag <- [@page | tags], do: settled_frame(tag)

    :ok
  end

  defp settle_if_unsettled(tag) do
    if Process.get(@unsettled_key), do: settle_layout(List.wrap(tag))
  end

  # ── Receipts ────────────────────────────────────────────────────────────────

  defp deliver(label, opts, action) do
    expect = Keyword.get(opts, :expect, :event)
    retries = Keyword.get(opts, :retry, 1)
    bump(:taps)
    attempt(label, expect, retries, action)
  end

  defp attempt(label, expect, retries, action) do
    node = device!()
    before = last_action_id(node)
    result = action.()
    sync()
    fresh = new_receipts(recent_receipts(node), before)

    case judge(label, expect, fresh, result) do
      {:done, receipts} ->
        receipts

      :dropped when retries > 0 ->
        bump(:retried)
        attempt(label, expect, retries - 1, action)

      :dropped ->
        flunk(dropped_message(label, expect, result, node))
    end
  end

  # What a touch and its receipts say about the expectation: done, or dropped (a
  # touch that may be repeated), or a failure outright.
  defp judge(label, _expect, _fresh, {:error, reason})
       when reason not in [:dispatch_failed, :no_effect],
       do: flunk("#{label} failed: #{inspect(reason)}")

  defp judge(label, _expect, _fresh, {:badrpc, reason}),
    do: flunk("#{label} could not reach the app: #{inspect(reason)}")

  defp judge(label, :event, [_ | _] = fresh, _result) do
    reject_unhandled!(label, fresh)
    {:done, fresh}
  end

  defp judge(_label, :event, [], _result), do: :dropped

  defp judge(label, :any, fresh, result) when result in [:ok, {:error, :no_effect}] do
    reject_unhandled!(label, fresh)
    {:done, fresh}
  end

  defp judge(_label, :any, _fresh, _result), do: :dropped
  defp judge(_label, :none, [], _result), do: {:done, []}

  defp judge(label, :none, fresh, _result),
    do: flunk("#{label} should have done nothing but delivered #{describe(fresh)}")

  defp dropped_message(label, :event, result, node) do
    "#{label} reached no handler (touch result #{inspect(result)}). " <>
      "No receipt followed it, so the event never arrived: a stale handle, " <>
      "a touch that landed on nothing clickable, or a text field with no " <>
      "on_focus (focus/1 touches those). Last receipts: " <>
      describe(recent_receipts(node))
  end

  defp dropped_message(label, :any, result, _node),
    do: "#{label} was not dispatched to any window (touch result #{inspect(result)})"

  defp reject_unhandled!(label, receipts) do
    if Enum.any?(receipts, &Receipt.reached?(&1, :unhandled)) do
      flunk("#{label} reached the screen but no clause handled it: #{describe(receipts)}")
    end
  end

  defp last_action_id(node) do
    case :rpc.call(node, Receipts, :recent, [1]) do
      [%Receipt{action_id: id}] -> id
      [] -> nil
      error -> raise "could not read receipts: #{inspect(error)}"
    end
  end

  defp recent_receipts(node) do
    case :rpc.call(node, Receipts, :recent, [16]) do
      receipts when is_list(receipts) -> receipts
      error -> raise "could not read receipts: #{inspect(error)}"
    end
  end

  @doc false
  # Receipts arrive newest first; the ones after `before_id` are the new ones.
  @spec new_receipts(receipts :: [Receipt.t()], before_id :: String.t() | nil) :: [Receipt.t()]
  def new_receipts(receipts, before_id),
    do: Enum.take_while(receipts, &(&1.action_id != before_id))

  defp describe([]), do: "none"
  defp describe(receipts), do: Enum.map_join(receipts, "; ", &inspect(&1.event))

  defp expect_ok!(label, :ok), do: label
  defp expect_ok!(label, other), do: flunk("#{label} failed: #{inspect(other)}")

  # ── Bookkeeping ─────────────────────────────────────────────────────────────

  @doc """
  Counts since the app was connected: `:taps` delivered through `tap/2`, `tap_xy/3`,
  `touch/3`, `focus/1`, `hold/3` and `event/2`, and `:retried`, how many of those were dropped and had to
  be repeated. `:retried` should stay 0; a non-zero count means the pacing has a hole.
  """
  @spec stats() :: %{taps: non_neg_integer(), retried: non_neg_integer()}
  def stats do
    case :persistent_term.get(@stats_key, nil) do
      nil -> %{taps: 0, retried: 0}
      counters -> %{taps: :counters.get(counters, 1), retried: :counters.get(counters, 2)}
    end
  end

  defp bump(:taps), do: :counters.add(:persistent_term.get(@stats_key), 1, 1)
  defp bump(:retried), do: :counters.add(:persistent_term.get(@stats_key), 2, 1)

  defp rect(x, y, w, h),
    do: %{left: x, top: y, right: x + w, bottom: y + h, width: w, height: h}
end
