# mishka_ui_dsl (skeleton)

The **separate package** that hosts the declarative-UI bridge for Layer 3, keeping the core
`mishka_chelekom` kit generic and Ash-free.

This mirrors the Pyro split:

| Pyro | Mishka |
|---|---|
| pyro-core (overrides, CSS) | `mishka_chelekom` (`MishkaChelekom.Overrides`/`CSS`/`Dsl`) |
| ash_pyro / PyroManiac | **`mishka_ui_dsl`** (this package) |
| pyro_maniac_live_view (renderer) | the renderer inside `mishka_ui_dsl` |

## Status

- ✅ Spark DSL surface compiles with just `spark`: sections `form` (entities `field`) and
  `table` (entities `column`), plus `MishkaUiDsl.Info` introspection.
- ⏳ Next: the Ash data-layer integration (derive fields/columns from an Ash resource) and the
  renderer that emits Mishka Chelekom styled/headless components.

```elixir
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
```

It depends on `mishka_chelekom` only as an optional, dev-time path dep (for generating the
target components); `ash` is optional so the DSL compiles without it.
