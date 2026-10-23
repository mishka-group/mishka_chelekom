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
    :scroll_to
  ]

  @node_key {__MODULE__, :node}
  @scale_key {__MODULE__, :scale}
  @stats_key {__MODULE__, :stats}

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
  when it already is, and when there is no scroll to move. Pass `in: "<scroll id>"`
  for a scroll other than the page's. Returns the frame afterwards.
  """
  @spec scroll_into_view(tag :: tag(), opts :: keyword()) :: frame()
  def scroll_into_view(tag, opts \\ []) do
    scroller = Keyword.get(opts, :in, @page)
    frames = frames()
    target = lookup(frames, tag) || flunk(not_shown_message(tag))

    case lookup(frames, scroller) do
      nil ->
        target

      viewport ->
        if visible?(target, viewport), do: target, else: scroll_to_centre(tag, scroller, viewport)
    end
  end

  defp scroll_to_centre(tag, scroller, viewport) do
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

  defp scale, do: :persistent_term.get(@scale_key)

  # ── Touch ───────────────────────────────────────────────────────────────────

  @doc """
  A real touch at the centre of `tag`: DOWN and UP delivered in-process to the
  window a finger would reach there (a popup's own window included), after
  scrolling the page to it if it is off screen.

  Returns the receipts the tap produced. Options:

    * `:expect` - `:event` (default): the tap must reach a handler, retried once
      if it does not and failed if it still does not. `:none`: it must reach
      nothing (a disabled control), and the test fails if it does.
    * `:retry` - how many times a dropped tap is repeated. Default 1; 0 to see raw drops.
  """
  @spec tap(tag :: tag(), opts :: keyword()) :: [Receipt.t()]
  def tap(tag, opts \\ []) do
    deliver("tap #{tag}", opts, fn ->
      {x, y} = tag |> scroll_into_view() |> center()
      Mob.Test.tap_xy(device!(), x, y)
    end)
  end

  @doc "A real touch at `(x, y)` dp of the activity window. Options as in `tap/2`."
  @spec tap_xy(x :: number(), y :: number(), opts :: keyword()) :: [Receipt.t()]
  def tap_xy(x, y, opts \\ []) do
    deliver("tap at (#{x}, #{y})", opts, fn -> Mob.Test.tap_xy(device!(), x, y) end)
  end

  @doc """
  A real long press on `tag`: the finger stays down for `ms` (default #{@hold_ms},
  past Android's 500ms long-press timeout), so this blocks that long. Options as
  in `tap/2`.
  """
  @spec hold(tag :: tag(), ms :: pos_integer(), opts :: keyword()) :: [Receipt.t()]
  def hold(tag, ms \\ @hold_ms, opts \\ []) do
    deliver("hold #{tag}", opts, fn ->
      {x, y} = tag |> scroll_into_view() |> center()
      Mob.Test.long_press_xy(device!(), x, y, ms)
    end)
  end

  @doc """
  A real drag from the centre of `tag` by `{dx, dy}` dp, over real frames so touch
  slop is crossed. Scrolls a scroll view, moves a slider.
  """
  @spec drag(tag :: tag(), by :: {number(), number()}) :: :ok
  def drag(tag, {dx, dy}) do
    {x, y} = tag |> scroll_into_view() |> center()
    swipe({x, y}, {x + dx, y + dy})
  end

  @doc "A real swipe between two points, in dp of the activity window."
  @spec swipe(from :: {number(), number()}, to :: {number(), number()}) :: :ok
  def swipe({x1, y1}, {x2, y2}) do
    expect_ok!("swipe", Mob.Test.swipe(device!(), x1, y1, x2, y2))
    sync()
  end

  @doc "Types `text` (ASCII only) into the focused field. Tap the field first."
  @spec type(text :: String.t()) :: :ok
  def type(text) do
    expect_ok!("type #{inspect(text)}", Mob.Test.type_text(device!(), text))
    sync()
  end

  @doc "Presses backspace `count` times in the focused field."
  @spec delete_backward(count :: pos_integer()) :: :ok
  def delete_backward(count \\ 1) do
    for _press <- 1..count//1 do
      expect_ok!("backspace", Mob.Test.delete_backward(device!()))
      sync()
    end

    :ok
  end

  @doc """
  Delivers the handler message `tag`'s node carries in `prop` (`:on_tap`,
  `:on_long_press`, `:on_tap` of an `anchored` node is its dismiss) without a
  touch. For what a touch cannot reach: a control a modal popup covers, or a
  handler whose payload is the thing under test.
  """
  @spec event(tag :: tag(), prop :: atom()) :: [Receipt.t()]
  def event(tag, prop \\ :on_tap) do
    deliver("#{prop} of #{tag}", [], fn ->
      case find_node(render_tree(), to_string(tag)) do
        %{props: %{^prop => {_pid, handler}}} -> Mob.Test.tap(device!(), handler)
        other -> flunk("#{tag} has no #{prop}: #{inspect(other && other.props)}")
      end
    end)
  end

  defp find_node(%{props: props, children: children} = node, id) do
    if to_string(Map.get(props, :id, "")) == id,
      do: node,
      else: Enum.find_value(children || [], &find_node(&1, id))
  end

  defp find_node(_leaf, _id), do: nil

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

    case {expect, fresh, result} do
      {_expect, _fresh, {:error, reason}} when reason not in [:dispatch_failed, :no_effect] ->
        flunk("#{label} failed: #{inspect(reason)}")

      {_expect, _fresh, {:badrpc, reason}} ->
        flunk("#{label} could not reach the app: #{inspect(reason)}")

      {:event, [_ | _], _result} ->
        reject_unhandled!(label, fresh)
        fresh

      {:event, [], _result} when retries > 0 ->
        bump(:retried)
        attempt(label, expect, retries - 1, action)

      {:event, [], result} ->
        flunk(
          "#{label} reached no handler (touch result #{inspect(result)}). " <>
            "No receipt followed it, so the event never arrived: a stale handle, " <>
            "or a touch that landed on nothing clickable. Last receipts: " <>
            describe(recent_receipts(node))
        )

      {:none, [], _result} ->
        []

      {:none, fresh, _result} ->
        flunk("#{label} should have done nothing but delivered #{describe(fresh)}")
    end
  end

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
  `hold/3` and `event/2`, and `:retried`, how many of those were dropped and had to
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
