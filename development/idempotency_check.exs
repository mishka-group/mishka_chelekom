defmodule IdempotencyCheck do
  @checks [
    {"styled   (mishka.ui.gen.components)", "mishka.ui.gen.components",
     ["--import", "--helpers", "--global", "--yes"]},
    {"headless (mishka.ui.gen.headless.components)", "mishka.ui.gen.headless.components",
     ["--yes"]}
  ]

  def run do
    results =
      Enum.map(@checks, fn {label, task, argv} ->
        igniter = Igniter.new() |> Igniter.compose_task(task, argv)
        {label, changed_paths(igniter)}
      end)

    Enum.each(results, fn
      {label, []} ->
        IO.puts("✅ #{label}: idempotent (no changes)")

      {label, changed} ->
        IO.puts("❌ #{label}: #{length(changed)} file(s) would change:")
        Enum.each(changed, &IO.puts("     - #{&1}"))
    end)

    drifted = results |> Enum.flat_map(fn {_, c} -> c end) |> Enum.uniq()

    if drifted == [] do
      IO.puts("\n🎉 Generators are idempotent — re-running the CLI changes nothing.")
    else
      IO.puts("""

      💥 Not idempotent: #{length(drifted)} file(s) would change. Regenerate and commit:
        mix mishka.ui.gen.components --import --helpers --global --yes
        mix mishka.ui.gen.headless.components --yes
      """)

      System.halt(1)
    end
  end

  defp changed_paths(igniter) do
    igniter.rewrite
    |> Rewrite.sources()
    |> Enum.filter(fn source ->
      Rewrite.Source.get(source, :content) != Rewrite.Source.get(source, :content, 1)
    end)
    |> Enum.map(&Rewrite.Source.get(&1, :path))
    |> Enum.sort()
  end
end

IdempotencyCheck.run()
