defmodule MishkaChelekom.TemplatesPrefixConsistencyTest do
  @moduledoc """
  Guards the module/component-prefix feature against the class of bug reported around
  issue #491: a component template that opens a sub-component with the prefix
  (`<.<%= @component_prefix %>badge>`) but closes it literally (`</.badge>`) — or with a
  misplaced dot (`</<%= @component_prefix %>.th>`) — produces valid HEEx with an empty
  prefix but *unmatched closing tags* the moment any prefix is set, breaking generation.

  This scans the real `priv/components/*.eex` templates and, for every component that is
  referenced with a prefix, asserts that every open/close reference to that same component
  is also prefixed and well-formed. It derives everything from the templates themselves —
  no hardcoded component list or counts.
  """
  use ExUnit.Case, async: true

  @prefix_token "<%= @component_prefix %>"
  @templates Path.wildcard("priv/components/*.eex")

  test "there are component templates to check" do
    assert @templates != [], "expected priv/components/*.eex templates to exist"
  end

  test "every prefixed component is opened and closed with a well-formed prefix" do
    esc = Regex.escape(@prefix_token)
    open_re = Regex.compile!("<\\." <> esc <> "([a-zA-Z0-9_]+)")

    violations =
      Enum.flat_map(@templates, fn path ->
        content = File.read!(path)

        if String.contains?(content, @prefix_token) do
          names =
            open_re
            |> Regex.scan(content, capture: :all_but_first)
            |> List.flatten()
            |> Enum.uniq()

          for name <- names, issue <- name_issues(name, content, esc) do
            "#{Path.basename(path)}: <.#{name}> — #{issue}"
          end
        else
          []
        end
      end)

    assert violations == [],
           "Templates reference a prefixed component with an unprefixed/misplaced tag. " <>
             "These render fine with no prefix but break generation once a module/component " <>
             "prefix is set:\n  " <> Enum.join(violations, "\n  ")
  end

  defp name_issues(name, content, esc) do
    en = Regex.escape(name)

    [
      {"literal opening `<.#{name}` (missing prefix)", "<\\." <> en <> "(?=[\\s/>])"},
      {"literal closing `</.#{name}>` (missing prefix)", "</\\." <> en <> ">"},
      {"misplaced-dot closing `</#{@prefix_token}.#{name}>`", "</" <> esc <> "\\." <> en <> ">"}
    ]
    |> Enum.filter(fn {_label, pattern} -> Regex.match?(Regex.compile!(pattern), content) end)
    |> Enum.map(fn {label, _pattern} -> label end)
  end
end
