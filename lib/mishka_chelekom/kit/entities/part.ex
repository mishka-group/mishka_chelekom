defmodule MishkaChelekom.Kit.Entities.Part do
  @moduledoc """
  Entity struct for a **headless part rule** inside a `customize`:
  `part :trigger, "…"` → `%Part{name: :trigger, classes: "…"}`.

  Built by the `part` entity in `MishkaChelekom.Kit.Dsl`.
  """
  defstruct [:name, :classes, __spark_metadata__: nil]
end
