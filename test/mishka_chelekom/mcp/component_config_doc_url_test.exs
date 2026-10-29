defmodule MishkaChelekom.MCP.ComponentConfigDocUrlTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.Generators.Core
  alias MishkaChelekom.MCP.ComponentConfig
  alias MishkaChelekom.MCP.Resources.ListHeadlessComponents

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
    catalog =
      ~r{## (\w+)\n.*?Docs: \S+/headless/([\w-]+)}s
      |> Regex.scan(ListHeadlessComponents.summary(), capture: :all_but_first)
      |> Map.new(fn [name, slug] -> {name, slug} end)

    assert catalog != %{}

    for {name, slug} <- catalog do
      refute slug =~ "_", "the catalog links #{name} to #{slug}"

      template = :headless |> Core.template_dir() |> Path.join("#{name}.eex") |> File.read!()

      assert [_, ^slug] = Regex.run(~r{chelekom/docs/headless/([\w-]+)}, template),
             "#{name}.eex links to a different slug than its catalog entry (#{slug})"
    end
  end
end
