defmodule MishkaChelekom.Kit.Entities.Customize do
  @moduledoc """
  Entity struct for one `customize` — a customization of an EXISTING component. The rules inside
  decide which world it targets: `color`/`variant`/`size`/… ⇒ a styled component, `part` ⇒ a
  headless one. Never both.

  Built by the `customize` entity in `MishkaChelekom.Kit.Dsl`; consumed by
  `MishkaChelekom.Kit.Transformers.Generate` and the `MishkaChelekom.Kit.Verifiers.*`.
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
