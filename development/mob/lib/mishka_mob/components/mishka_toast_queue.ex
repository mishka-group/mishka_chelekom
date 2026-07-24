defmodule MishkaMob.Components.MishkaToast.Queue do
  @moduledoc """
  The queue behaviour behind `MishkaMob.Components.MishkaToast`, as pure
  functions over a list of toasts.

  The web component's JS engine owns this: it caps the visible count, drops
  repeats and auto-dismisses on a timer. None of that is rendering, and a
  component that started its own timers would fire one per render — so the
  operations live here and the screen drives them, keeping the toast list in its
  own assigns where it already belongs.

  A toast is a plain map: `%{id:, title:, description:, variant:, at:}`. `at` is
  a monotonic millisecond stamp used only by `expire/2`.
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
  Drop every toast stamped more than `duration` ms before `now`.

  Toasts with no `:at` never expire, so a message can be made sticky by simply
  omitting the stamp.

      iex> alias MishkaMob.Components.MishkaToast.Queue
      ...> Queue.expire([%{id: 1, at: 0}, %{id: 2, at: 5_000}], 4_000, now: 5_000)
      [%{id: 2, at: 5000}]
  """
  @spec expire([map()], non_neg_integer(), keyword()) :: [map()]
  def expire(toasts, duration, opts \\ []) do
    now = Keyword.get_lazy(opts, :now, fn -> System.monotonic_time(:millisecond) end)

    Enum.reject(toasts, fn toast ->
      case Map.get(toast, :at) do
        nil -> false
        at -> now - at >= duration
      end
    end)
  end

  defp dedup(toasts, _toast, nil), do: toasts

  defp dedup(toasts, toast, key) when is_atom(key) do
    Enum.reject(toasts, &(Map.get(&1, key) != nil and Map.get(&1, key) == Map.get(toast, key)))
  end

  defp dedup(toasts, toast, fun) when is_function(fun, 1) do
    Enum.reject(toasts, &(fun.(&1) == fun.(toast)))
  end

  defp cap(toasts, nil), do: toasts
  defp cap(toasts, limit) when length(toasts) <= limit, do: toasts
  defp cap(toasts, limit), do: Enum.take(toasts, -limit)
end
