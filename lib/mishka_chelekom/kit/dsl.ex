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

  This module only assembles the DSL; supporting modules live alongside it:
  structs in `MishkaChelekom.Kit.Entities.*`, code-gen in `MishkaChelekom.Kit.Transformers.Generate`,
  compile-time checks in `MishkaChelekom.Kit.Verifiers.*`.
  """
  alias MishkaChelekom.Kit.Entities.{Rule, Part, Customize}

  @dimensions [:color, :variant, :size, :padding, :rounded, :kind, :space, :border, :width]

  @dim_entities (for attr <- @dimensions do
                   %Spark.Dsl.Entity{
                     name: attr,
                     target: Rule,
                     args: [:value, :classes],
                     auto_set_fields: [attr: attr],
                     schema: [
                       value: [type: {:or, [:atom, :string]}, required: true],
                       classes: [type: :string, required: true],
                       color: [
                         type: {:or, [:atom, :string]},
                         required: false,
                         doc:
                           "pair this rule with a specific color — matches only that variant×color combo"
                       ],
                       variant: [
                         type: {:or, [:atom, :string]},
                         required: false,
                         doc:
                           "pair this rule with a specific variant — matches only that variant×color combo"
                       ]
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
      from: [
        type: {:or, [:atom, {:tuple, [:atom, :atom]}]},
        doc:
          "the component to reuse: an atom resolves by convention (`<Web>.Components.<Name>.<name>`), " <>
            "or a `{Module, :function}` tuple points at an exact module/function (no convention)"
      ],
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
    schema: [
      components: [
        type: :atom,
        doc: "module namespace for styled components (default: <Web>.Components)"
      ],
      headless: [
        type: :atom,
        doc: "module namespace for headless components (default: <Web>.Components.Headless)"
      ]
    ],
    entities: [@customize]
  }

  use Spark.Dsl.Extension,
    sections: [@ui],
    transformers: [MishkaChelekom.Kit.Transformers.Generate],
    verifiers: [MishkaChelekom.Kit.Verifiers.Rules, MishkaChelekom.Kit.Verifiers.Catalog]
end
