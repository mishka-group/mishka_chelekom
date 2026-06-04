defmodule MishkaUiDsl do
  @moduledoc """
  Declarative UI bridge (Layer 3, Ash side) — **skeleton**.

  This is the separate package that hosts the Spark-DSL → declarative-UI bridge, keeping the
  core `mishka_chelekom` kit generic and Ash-free (per the architecture decision). It mirrors
  the Pyro/AshPyro split: pyro-core ↔ chelekom, ash_pyro ↔ this package.

  A project describes forms/tables for an Ash resource declaratively; a renderer emits the
  matching Mishka Chelekom (styled or headless) components in the host app.

      defmodule MyApp.Accounts.User.Ui do
        use MishkaUiDsl

        form do
          field :email, type: :email_field
          field :role, type: :select
        end

        table do
          column :email
          column :inserted_at, label: "Joined"
        end
      end

  Status: the DSL surface (sections `form`/`table`, entities `field`/`column`) is defined and
  compiles with just `spark`. The Ash data-layer integration and the Chelekom renderer are the
  next steps and intentionally live here, not in `mishka_chelekom`.
  """
  use Spark.Dsl, default_extensions: [extensions: [MishkaUiDsl.Dsl]]
end
