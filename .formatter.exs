# Used by "mix format"

# Keeps MishkaChelekom DSL calls (e.g. `default :primary`, `variant :primary, classes: "..."`)
# parenless. Populated by `mix spark.formatter --extensions MishkaChelekom.Dsl` — do not edit by hand.
spark_locals_without_parens = [
  classes: 1,
  default: 1,
  token: 1,
  token: 2,
  value: 1,
  variant: 1,
  variant: 2
]

[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "priv/components/**/*.{exs}"
  ],
  locals_without_parens: spark_locals_without_parens,
  export: [locals_without_parens: spark_locals_without_parens]
]
