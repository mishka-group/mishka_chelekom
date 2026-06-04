defmodule MishkaChelekom.Dsl.Variant do
  @moduledoc "A declared component variant: a name and its Tailwind classes."
  defstruct [:name, :classes, __spark_metadata__: nil]
  @type t :: %__MODULE__{name: atom(), classes: String.t()}
end

defmodule MishkaChelekom.Dsl.Token do
  @moduledoc "A declared theme token: a CSS-variable name and its value."
  defstruct [:name, :value, __spark_metadata__: nil]
  @type t :: %__MODULE__{name: atom(), value: String.t()}
end

defmodule MishkaChelekom.Dsl.Verifiers.DefaultVariantExists do
  @moduledoc "Compile-time check: a `variants` section's `default` must name a declared variant."
  use Spark.Dsl.Verifier

  @impl true
  def verify(dsl_state) do
    default = Spark.Dsl.Verifier.get_option(dsl_state, [:variants], :default)
    names = dsl_state |> Spark.Dsl.Verifier.get_entities([:variants]) |> Enum.map(& &1.name)

    if is_nil(default) or default in names do
      :ok
    else
      {:error,
       Spark.Error.DslError.exception(
         module: Spark.Dsl.Verifier.get_persisted(dsl_state, :module),
         message:
           "default variant #{inspect(default)} is not declared (have: #{inspect(names)})",
         path: [:variants, :default]
       )}
    end
  end
end

defmodule MishkaChelekom.Dsl do
  @moduledoc """
  A Spark DSL extension for declaring component **variants** and **theme tokens** in one
  compile-time-validated place (Layer 3). Use it via `MishkaChelekom.Theme`.

      defmodule MyAppWeb.Buttons do
        use MishkaChelekom.Theme

        variants do
          default :primary
          variant :primary, classes: "bg-primary text-primary-content"
          variant :ghost, classes: "bg-transparent hover:bg-base-200"
        end

        theme do
          token :radius, value: "0.5rem"
        end
      end

  A `default` that names an undeclared variant fails compilation with a clear `Spark.Error`.
  Introspect with `MishkaChelekom.Theme.Info`.
  """

  @variant %Spark.Dsl.Entity{
    name: :variant,
    target: MishkaChelekom.Dsl.Variant,
    args: [:name],
    schema: [
      name: [type: :atom, required: true, doc: "Variant name"],
      classes: [type: :string, required: true, doc: "Tailwind classes for the variant"]
    ]
  }

  @token %Spark.Dsl.Entity{
    name: :token,
    target: MishkaChelekom.Dsl.Token,
    args: [:name],
    schema: [
      name: [type: :atom, required: true, doc: "Token (CSS variable) name"],
      value: [type: :string, required: true, doc: "Token value"]
    ]
  }

  @variants %Spark.Dsl.Section{
    name: :variants,
    describe: "Declared component variants and the default.",
    entities: [@variant],
    schema: [
      default: [type: :atom, doc: "The default variant name (must be declared)"]
    ]
  }

  @theme %Spark.Dsl.Section{
    name: :theme,
    describe: "Theme tokens (CSS variables).",
    entities: [@token]
  }

  use Spark.Dsl.Extension,
    sections: [@variants, @theme],
    verifiers: [MishkaChelekom.Dsl.Verifiers.DefaultVariantExists]
end

defmodule MishkaChelekom.Theme do
  @moduledoc """
  Base module for declarative Chelekom theming. `use MishkaChelekom.Theme` to get the
  `variants`/`theme` DSL (see `MishkaChelekom.Dsl`).
  """
  use Spark.Dsl, default_extensions: [extensions: [MishkaChelekom.Dsl]]
end

defmodule MishkaChelekom.Theme.Info do
  @moduledoc "Introspection for `MishkaChelekom.Theme` modules."
  use Spark.InfoGenerator, extension: MishkaChelekom.Dsl, sections: [:variants, :theme]
end
