# Renders every headless component example to iodata and reports failures.
#   Run:  mix run headless_smoke.exs

alias DevelopmentWeb.Showcase.{HeadlessPreview, HeadlessCatalog}

names = HeadlessCatalog.all() |> Enum.map(& &1.name)

results =
  for name <- names do
    assigns = %{component: name, id: "smoke-#{name}", __changed__: nil}

    try do
      assigns |> HeadlessPreview.show() |> Phoenix.HTML.Safe.to_iodata()
      {:ok, name}
    rescue
      e -> {:error, name, Exception.message(e)}
    catch
      kind, e -> {:error, name, "#{kind}: #{inspect(e)}"}
    end
  end

oks = Enum.count(results, &match?({:ok, _}, &1))
IO.puts("\n=== Headless preview smoke: #{oks}/#{length(results)} rendered OK ===")
for {:error, n, m} <- results, do: IO.puts("FAIL #{n}: #{m |> String.replace("\n", " ") |> String.slice(0, 200)}")
if oks == length(results), do: IO.puts("All headless previews render. 🎉")
