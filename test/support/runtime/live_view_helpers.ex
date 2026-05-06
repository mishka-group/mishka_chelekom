defmodule MishkaChelekom.Test.Runtime.LiveViewHelpers do
  import Phoenix.Component
  alias MishkaChelekom.Test.Runtime.Compilers.Helpers

  def component(assigns) when is_map(assigns) do
    name = assigns[:component_name] || raise "component name is required"
    module_name = Helpers.module_name(name, assigns[:site], "Component")

    assigns =
      if assigns[:runtime_slot] do
        case process_runtime_slots(assigns[:runtime_slot]) do
          {:ok, runtime_slots} ->
            assigns |> Map.drop([:runtime_slot]) |> Map.merge(runtime_slots)

          {:error, message} ->
            Map.put(assigns, :slot_error, message)
        end
      else
        assigns
      end

    if assigns[:slot_error] do
      ~H"""
      <div class="text-red-600 border border-red-300 p-2 rounded">
        <strong>Slot Error in {@component_name}:</strong> {@slot_error}
      </div>
      """
    else
      if :erlang.module_loaded(module_name) do
        apply(module_name, String.to_atom(name), [assigns])
      else
        ~H"""
        <div class="text-red-600">
          {@component_name} Component failed to render!
        </div>
        """
      end
    end
  end

  def component(assigns) when is_map(assigns) do
    name = assigns[:component_name] || raise "component name is required"
    module_name = Helpers.module_name(name, assigns[:site], "Component")

    assigns =
      if assigns[:runtime_slot] do
        case process_runtime_slots(assigns[:runtime_slot]) do
          {:ok, runtime_slots} ->
            assigns |> Map.drop([:runtime_slot]) |> Map.merge(runtime_slots)

          {:error, message} ->
            Map.put(assigns, :slot_error, message)
        end
      else
        assigns
      end

    if assigns[:slot_error] do
      ~H"""
      <div class="text-red-600 border border-red-300 p-2 rounded">
        <strong>Slot Error in {@component_name}:</strong> {@slot_error}
      </div>
      """
    else
      if :erlang.module_loaded(module_name) do
        apply(module_name, String.to_atom(name), [assigns])
      else
        ~H"""
        <div class="text-red-600">
          {@component_name} Component failed to render!
        </div>
        """
      end
    end
  end

  def component(name, site, assigns \\ %{}) do
    component(Map.merge(assigns, %{name: name, site: site}))
  end

  defp process_runtime_slots(slots) when is_list(slots) do
    invalid_slots =
      Enum.filter(slots, fn slot ->
        is_nil(slot[:for_slot]) || slot[:for_slot] == ""
      end)

    if length(invalid_slots) > 0 do
      {:error, "Missing for_slot attribute in #{length(invalid_slots)} slot(s)"}
    else
      processed_slots =
        slots
        |> Enum.group_by(& &1[:for_slot])
        |> Map.new(fn {name, grouped_slots} ->
          {String.to_atom(name), grouped_slots}
        end)

      {:ok, processed_slots}
    end
  end
end
