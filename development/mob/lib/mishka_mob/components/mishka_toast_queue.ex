defmodule MishkaMob.Components.MishkaToast.Queue do
  @moduledoc """
  The queue behaviour behind `MishkaMob.Components.MishkaToast`, as pure
  functions over a list of toasts.

  The web component's JS engine owns this: it caps the visible count, drops
  repeats and auto-dismisses on a timer. None of that is rendering, and a
  component that started its own timers would fire one per render — so the
  operations live here and the screen drives them, keeping the toast list in its
  own assigns where it already belongs.

  A toast is a plain map: `%{id:, title:, description:, variant:, at:,
  duration:}`. `at` is a monotonic millisecond stamp used only by `expire/3`,
  and `duration` overrides that call's default for this one toast — matching the
  per-toast `duration` attr the web component's `<:toast>` slot declares.
  """

  @doc """
  Add a toast, newest last.

  Options: `:limit` (keep at most N, dropping the oldest) and `:dedup_key`
  (a function or atom key; a new toast replaces an existing one with the same
  key instead of stacking a duplicate).

      iex> alias MishkaMob.Components.MishkaToast.Queue
      ...> Queue.push([], %{id: 1, title: "Saved"}) |> length()
      1

      iex> alias MishkaMob.Components.MishkaToast.Queue
      ...> [%{id: 2}, %{id: 3}] = Queue.push([%{id: 1}, %{id: 2}], %{id: 3}, limit: 2)
      ...> :ok
      :ok
  """
  @spec push([map()], map(), keyword()) :: [map()]
  def push(toasts, toast, opts \\ []) do
    toasts
    |> dedup(toast, Keyword.get(opts, :dedup_key))
    |> Kernel.++([toast])
    |> cap(Keyword.get(opts, :limit))
  end

  @doc """
  Remove a toast by id.

      iex> MishkaMob.Components.MishkaToast.Queue.dismiss([%{id: 1}, %{id: 2}], 1)
      [%{id: 2}]
  """
  @spec dismiss([map()], term()) :: [map()]
  def dismiss(toasts, id), do: Enum.reject(toasts, &(Map.get(&1, :id) == id))

  @doc """
  Drop every toast that has outlived its duration as of `now`.

  `duration` is the default; a toast carrying its own `:duration` uses that
  instead, which is how the web component's per-toast `duration` attr ports. Two
  ways to make a message sticky, both matching the web behaviour: omit `:at`, or
  give it `duration: 0` — the web engine reads `0` as "disables auto-dismiss".

      iex> alias MishkaMob.Components.MishkaToast.Queue
      ...> Queue.expire([%{id: 1, at: 0}, %{id: 2, at: 5_000}], 4_000, now: 5_000)
      [%{id: 2, at: 5000}]

      iex> alias MishkaMob.Components.MishkaToast.Queue
      ...> queue = [%{id: 1, at: 0, duration: 500}, %{id: 2, at: 0, duration: 0}]
      ...> Queue.expire(queue, 10_000, now: 1_000)
      [%{id: 2, at: 0, duration: 0}]
  """
  @spec expire([map()], non_neg_integer(), keyword()) :: [map()]
  def expire(toasts, duration, opts \\ []) do
    now = Keyword.get_lazy(opts, :now, fn -> System.monotonic_time(:millisecond) end)

    Enum.reject(toasts, fn toast ->
      case {Map.get(toast, :at), Map.get(toast, :duration, duration)} do
        {nil, _} -> false
        {_at, sticky} when not is_integer(sticky) or sticky <= 0 -> false
        {at, dur} -> now - at >= dur
      end
    end)
  end

  defp dedup(toasts, _toast, nil), do: toasts

  defp dedup(toasts, toast, key) when is_atom(key) do
    Enum.reject(toasts, &(Map.get(&1, key) != nil and Map.get(&1, key) == Map.get(toast, key)))
  end

  # Same nil guard as the atom clause. Without it a key function that returns nil
  # for both toasts — `& &1[:group]` over two toasts with no `:group` — reads
  # `nil == nil` as a match and silently drops an unrelated message.
  defp dedup(toasts, toast, fun) when is_function(fun, 1) do
    key = fun.(toast)

    Enum.reject(toasts, fn existing ->
      existing_key = fun.(existing)
      existing_key != nil and existing_key == key
    end)
  end

  defp cap(toasts, nil), do: toasts
  defp cap(toasts, limit) when length(toasts) <= limit, do: toasts
  defp cap(toasts, limit), do: Enum.take(toasts, -limit)
end
