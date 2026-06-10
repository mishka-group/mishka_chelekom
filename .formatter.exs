# Used by "mix format"

# Keeps MishkaChelekom.Kit DSL calls (e.g. `customize :button do`, `color :brand, "..."`, `part :trigger, "..."`)
# parenless. Populated by `mix spark.formatter --extensions MishkaChelekom.Kit.Dsl` — do not edit by hand.
spark_locals_without_parens = [
  base: 1,
  border: 2,
  border: 3,
  color: 2,
  color: 3,
  customize: 1,
  customize: 2,
  default: 1,
  from: 1,
  kind: 2,
  kind: 3,
  padding: 2,
  padding: 3,
  part: 2,
  part: 3,
  rounded: 2,
  rounded: 3,
  size: 2,
  size: 3,
  space: 2,
  space: 3,
  variant: 2,
  variant: 3,
  width: 2,
  width: 3
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
