# Warnings `mix dialyzer` reports that are not defects. Each one is named by file, kind and line,
# so a new warning of the same kind in the same file is still reported.
[
  # MapSet and :sets are opaque types: dialyzer reports a `MapSet` carried through a recursion or a
  # reduce as a call that reads one through its struct, though the code only calls `MapSet`.
  {"lib/mishka_chelekom/cms_bundle/attr_values.ex", :call_with_opaque, 244},
  {"lib/mishka_chelekom/cms_bundle/attr_values.ex", :call_with_opaque, 408},
  {"lib/mishka_chelekom/cms_bundle/attr_values.ex", :call_without_opaque, 162},
  {"lib/mishka_chelekom/cms_bundle/attr_values.ex", :call_without_opaque, 406},
  {"test/support/runtime/demo_harness.ex", :call_without_opaque, 196},

  # Logger documents `:none` for `Logger.configure(level: ...)`, but its `configure_opts` type lists
  # only the severities. The stdio MCP server silences Logger with it, so dialyzer calls the call
  # one that cannot succeed and `run_stdio/0` "without a local return".
  {"lib/mix/tasks/mishka.mcp.server.ex", :call, 215},
  {"lib/mix/tasks/mishka.mcp.server.ex", :no_return, 209},

  # A last clause that matches anything, after clauses the current callers already cover. Kept on
  # purpose, as in the MishkaCmsCore compiler this test copy mirrors.
  {"test/support/runtime/component_compiler.ex", :pattern_match_cov, 1125}
]
