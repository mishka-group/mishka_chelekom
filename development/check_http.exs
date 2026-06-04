# GETs a sample of showcase pages from the already-running dev server and reports
# status + whether a LiveView actually mounted. Run against `mix phx.server`:
#
#   mix run --no-start check_http.exs
#
# `--no-start` avoids booting a second endpoint (which would clash on port 4000).

{:ok, _} = Application.ensure_all_started(:inets)
{:ok, _} = Application.ensure_all_started(:ssl)

paths = [
  "/",
  "/showcase",
  "/showcase/button",
  "/showcase/accordion",
  "/showcase/input_field",
  "/showcase/tabs",
  "/showcase/modal",
  "/showcase/carousel",
  "/showcase/dock",
  "/showcase/video",
  "/showcase/clipboard",
  "/showcase/checkbox_card"
]

IO.puts("")

Enum.each(paths, fn p ->
  url = ~c"http://localhost:4002#{p}"

  case :httpc.request(:get, {url, []}, [{:autoredirect, false}], []) do
    {:ok, {{_v, code, _r}, _h, body}} ->
      body = to_string(body)
      mounted = String.contains?(body, "data-phx-main") or String.contains?(body, "data-phx-session")
      note = if code in [200] and mounted, do: "LiveView mounted ✓", else: ""
      note = if code in [301, 302], do: "redirect", else: note
      IO.puts(String.pad_trailing(p, 28) <> "#{code}  #{byte_size(body)}b  #{note}")

    {:error, reason} ->
      IO.puts(String.pad_trailing(p, 28) <> "ERROR #{inspect(reason)}")
  end
end)
