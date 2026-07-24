# .credo.exs — Credo config for mishka_mob.
#
# Run `mix credo --strict`. ExSlop is registered as a *plugin* (per its
# README) — registering it under checks.enabled makes Credo ignore it as an
# "undefined check", so it must live in `plugins:`. It contributes ~31 checks
# that flag AI-generated Elixir slop (blanket rescue, narrator docs, obvious
# comments, anti-idiomatic Enum usage, try/rescue around non-raising calls,
# N+1 queries, …) on top of Credo's strict defaults.

%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      strict: true,
      plugins: [{ExSlop, []}],
      checks: %{
        disabled: [
          # Pipes with a single function call are fine in this codebase.
          {Credo.Check.Readability.SinglePipe, []}
        ]
      }
    }
  ]
}
