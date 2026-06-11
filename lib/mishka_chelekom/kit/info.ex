defmodule MishkaChelekom.Kit.Info do
  @moduledoc "Introspection for `MishkaChelekom.Kit` modules."
  use Spark.InfoGenerator, extension: MishkaChelekom.Kit.Dsl, sections: [:ui]

  @doc "All `customize :x` entries."
  def customizes(module), do: ui(module)
end
