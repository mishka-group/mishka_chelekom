defmodule MishkaChelekom.Kit.Rule do
  @moduledoc "A styled dimension rule: `color :brand, \"…\"` → `%Rule{attr: :color, value: :brand, classes: \"…\"}`."
  defstruct [:attr, :value, :classes, __spark_metadata__: nil]
end

defmodule MishkaChelekom.Kit.Part do
  @moduledoc "A headless part rule: `part :trigger, \"…\"` → `%Part{name: :trigger, classes: \"…\"}`."
  defstruct [:name, :classes, __spark_metadata__: nil]
end

defmodule MishkaChelekom.Kit.Customize do
  @moduledoc """
  A customization of one EXISTING component. The rules inside decide which world it targets:
  `color`/`variant`/`size`/… ⇒ a styled component, `part` ⇒ a headless one. Never both.
  """
  defstruct [
    :name,
    :from,
    base: "base",
    rules: [],
    default: [],
    __identifier__: nil,
    __spark_metadata__: nil
  ]
end

defmodule MishkaChelekom.Kit.Dsl do
  @moduledoc """
  The `MishkaChelekom.Kit` Spark DSL — **one** verb, `customize`, to reuse and restyle any existing
  Mishka Chelekom component (styled or headless). It never builds HTML from scratch.

      customize :my_button do
        from :button                 # styled — you'll use color/variant/size
        color :brand, "…"            #   add a new color
        variant :glow, "…"           #   add a new variant
        default color: :brand
      end

      customize :confirm_dialog do
        from :dialog                 # headless — you'll use `part`
        part :popup, "…"
        part :title, "…"
      end

  The macro decides styled vs headless from the **rules you write** (`color`/`variant`/… vs `part`),
  so a name that exists in both worlds is never ambiguous. Each `customize` generates a thin wrapper
  that delegates to the real component — its file is never touched.
  """
  alias MishkaChelekom.Kit.{Rule, Part, Customize}

  @dimensions [:color, :variant, :size, :padding, :rounded, :kind, :space, :border, :width]

  @dim_entities (for attr <- @dimensions do
                   %Spark.Dsl.Entity{
                     name: attr,
                     target: Rule,
                     args: [:value, :classes],
                     auto_set_fields: [attr: attr],
                     schema: [
                       value: [type: {:or, [:atom, :string]}, required: true],
                       classes: [type: :string, required: true]
                     ]
                   }
                 end)

  @part %Spark.Dsl.Entity{
    name: :part,
    target: Part,
    args: [:name, :classes],
    schema: [name: [type: :atom, required: true], classes: [type: :string, required: true]]
  }

  @customize %Spark.Dsl.Entity{
    name: :customize,
    target: Customize,
    args: [:name],
    identifier: :name,
    entities: [rules: @dim_entities ++ [@part]],
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "the generated component name (may differ from `from`)"
      ],
      from: [type: :atom, doc: "the component to reuse (defaults to `name`)"],
      base: [
        type: :string,
        default: "base",
        doc: "the neutral value a new color/variant falls back to"
      ],
      default: [
        type: :keyword_list,
        default: [],
        doc: "default props for the generated component"
      ]
    ]
  }

  @ui %Spark.Dsl.Section{
    name: :ui,
    describe: "Customize existing styled or headless components.",
    top_level?: true,
    entities: [@customize]
  }

  use Spark.Dsl.Extension,
    sections: [@ui],
    transformers: [MishkaChelekom.Kit.Transformers.Generate],
    verifiers: [MishkaChelekom.Kit.Verifiers.Rules]
end

defmodule MishkaChelekom.Kit.Verifiers.Rules do
  @moduledoc """
  Compile-time guards for each `customize`:
    * it must declare at least one `color`/`variant`/…/`part` rule (else it's a no-op);
    * it may not mix styled rules (`color`/`variant`/…) with a `part` rule — that would mean
      customizing a styled and a headless component at once.
  """
  use Spark.Dsl.Verifier
  alias MishkaChelekom.Kit.{Rule, Customize}

  @impl true
  def verify(dsl_state) do
    dsl_state
    |> Spark.Dsl.Verifier.get_entities([:ui])
    |> Enum.reduce_while(:ok, fn %Customize{name: name, rules: rules}, :ok ->
      {dims, parts} = Enum.split_with(rules, &match?(%Rule{}, &1))

      cond do
        dims != [] and parts != [] ->
          {:halt,
           err(
             dsl_state,
             name,
             "mixes styled rules (color/variant/…) with `part` — a customize targets one component, styled OR headless"
           )}

        dims == [] and parts == [] ->
          {:halt,
           err(dsl_state, name, "declares no rules — add at least one color/variant/size/part")}

        true ->
          {:cont, :ok}
      end
    end)
  end

  defp err(dsl_state, name, message) do
    {:error,
     Spark.Error.DslError.exception(
       module: Spark.Dsl.Verifier.get_persisted(dsl_state, :module),
       message: "customize #{inspect(name)} #{message}",
       path: [:ui, :customize, name]
     )}
  end
end
