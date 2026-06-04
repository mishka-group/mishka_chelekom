defmodule MishkaChelekom.Overrides do
  @moduledoc """
  Centralized, Pyro-style **overrides** for component part classes (Layer 3, opt-in).

  A project declares overrides in one place without editing generated component files:

      defmodule MyAppWeb.Overrides do
        use MishkaChelekom.Overrides

        override :button, :root, "rounded-full"
        override :dialog, :popup, "shadow-2xl ring-1 ring-black/5"
      end

  Register override modules (first match wins — exactly Pyro's resolution order); the default
  preset is conventionally appended last:

      config :mishka_chelekom, :overrides, [MyAppWeb.Overrides, MishkaChelekom.Presets.Default]

  At render time, components compose `base ++ override ++ user_class` via `merge/4` so the
  caller's class still wins (through `MishkaChelekom.CSS`). Generated components remain
  zero-dependency; this engine is only used when a project opts into it.
  """

  defmacro __using__(_opts) do
    quote do
      import MishkaChelekom.Overrides, only: [override: 3]
      Module.register_attribute(__MODULE__, :chelekom_overrides, accumulate: true)
      @before_compile MishkaChelekom.Overrides
    end
  end

  @doc "Declare an override for `{component, part}`."
  defmacro override(component, part, classes) do
    quote bind_quoted: [component: component, part: part, classes: classes] do
      @chelekom_overrides {{component, part}, classes}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc false
      def __overrides__, do: Map.new(@chelekom_overrides)
    end
  end

  @doc "The configured override modules, in resolution order."
  def configured do
    Application.get_env(:mishka_chelekom, :overrides, [MishkaChelekom.Presets.Default])
  end

  @doc """
  Resolve the override classes for `{component, part}` across the configured modules
  (first non-nil wins), or `nil` if none.
  """
  @spec class_for(atom(), atom()) :: String.t() | nil
  def class_for(component, part) do
    Enum.find_value(configured(), fn mod ->
      if function_exported?(mod, :__overrides__, 0) do
        Map.get(mod.__overrides__(), {component, part})
      end
    end)
  end

  @doc """
  Compose a part's final class string: component `base`, then the resolved override, then the
  caller's `user` class — later wins via `MishkaChelekom.CSS.classes/1`.
  """
  @spec merge(atom(), atom(), MishkaChelekom.CSS.input(), MishkaChelekom.CSS.input()) ::
          String.t()
  def merge(component, part, base, user \\ nil) do
    MishkaChelekom.CSS.classes([base, class_for(component, part), user])
  end
end
