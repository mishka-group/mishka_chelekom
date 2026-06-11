defmodule MishkaChelekom.Kit.Entities.Rule do
  @moduledoc """
  Entity struct for a **styled dimension rule** inside a `customize`:
  `color :brand, "…"` → `%Rule{attr: :color, value: :brand, classes: "…"}`.

  Built by the dimension entities (`color`/`variant`/`size`/…) in `MishkaChelekom.Kit.Dsl`.
  """
  defstruct [:attr, :value, :classes, __spark_metadata__: nil]
end
