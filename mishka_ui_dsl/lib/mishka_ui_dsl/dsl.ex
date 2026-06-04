defmodule MishkaUiDsl.Field do
  @moduledoc "A declared form field."
  defstruct [:name, :type, :label, __spark_metadata__: nil]
end

defmodule MishkaUiDsl.Column do
  @moduledoc "A declared table column."
  defstruct [:name, :label, __spark_metadata__: nil]
end

defmodule MishkaUiDsl.Dsl do
  @moduledoc "Spark extension defining the `form`/`table` declarative UI DSL."

  @field %Spark.Dsl.Entity{
    name: :field,
    target: MishkaUiDsl.Field,
    args: [:name],
    schema: [
      name: [type: :atom, required: true],
      type: [type: :atom, default: :input_field, doc: "Chelekom field component to render"],
      label: [type: :string]
    ]
  }

  @column %Spark.Dsl.Entity{
    name: :column,
    target: MishkaUiDsl.Column,
    args: [:name],
    schema: [
      name: [type: :atom, required: true],
      label: [type: :string]
    ]
  }

  @form %Spark.Dsl.Section{
    name: :form,
    describe: "Declarative form: fields rendered via Chelekom field components.",
    entities: [@field]
  }

  @table %Spark.Dsl.Section{
    name: :table,
    describe: "Declarative table: columns rendered via the Chelekom table component.",
    entities: [@column]
  }

  use Spark.Dsl.Extension, sections: [@form, @table]
end

defmodule MishkaUiDsl.Info do
  @moduledoc "Introspection for `MishkaUiDsl` modules."
  use Spark.InfoGenerator, extension: MishkaUiDsl.Dsl, sections: [:form, :table]
end
