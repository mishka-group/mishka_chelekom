# Renders every component's showcase preview to iodata and reports failures.
# A fast regression check that the generated previews actually render (not just compile).
#
#   Run:  mix run smoke.exs

alias DevelopmentWeb.Showcase.{Catalog, Preview}

form = Phoenix.Component.to_form(%{}, as: :demo)

results =
  for c <- Catalog.all() do
    props =
      for %{key: k, values: [v | _]} <- c.dims, into: %{} do
        {String.to_existing_atom(k), v}
      end

    assigns = %{
      component: c.name,
      id: "smoke-#{c.name}",
      props: props,
      form: form,
      sample: "Sample",
      __changed__: nil
    }

    try do
      assigns |> Preview.show() |> Phoenix.HTML.Safe.to_iodata()
      {:ok, c.name}
    rescue
      e -> {:error, c.name, Exception.message(e)}
    catch
      kind, e -> {:error, c.name, "#{kind}: #{inspect(e)}"}
    end
  end

oks = Enum.count(results, &match?({:ok, _}, &1))
fails = for {:error, n, m} <- results, do: {n, m}

IO.puts("\n=== Showcase preview smoke: #{oks}/#{length(results)} rendered OK ===")

for {n, m} <- fails do
  IO.puts("FAIL #{n}: #{m |> String.replace("\n", " ") |> String.slice(0, 200)}")
end

if fails == [], do: IO.puts("All previews render. 🎉")
