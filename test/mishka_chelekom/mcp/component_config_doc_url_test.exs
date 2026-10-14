defmodule MishkaChelekom.MCP.ComponentConfigDocUrlTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.MCP.ComponentConfig

  test "an unknown component gets a dashed docs slug" do
    assert ComponentConfig.get_doc_url("no_such_component") ==
             "https://mishka.tools/chelekom/docs/no-such-component"
  end

  test "every shipped doc_url path uses dashes, never underscores" do
    offenders =
      for {name, url} <- ComponentConfig.list_doc_urls(),
          url != "internal",
          URI.parse(url).path =~ "_",
          do: {name, url}

    assert offenders == []
  end

  test "the headless catalog files and their .eex docs agree on dashed slugs" do
    for file <- Path.wildcard("priv/headless/*.{exs,eex}"),
        line <- file |> File.read!() |> String.split("\n"),
        [_, slug] <- [Regex.run(~r{chelekom/docs/headless/([\w-]+)}, line)] do
      refute slug =~ "_", "#{file} links to #{slug}"
    end
  end
end
