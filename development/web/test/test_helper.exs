# Several of these tests mount every page in the catalog — 92 components, three galleries — in a
# single test body, so their wall time is dominated by LiveView mounts rather than by anything
# they assert. `headless_showcase_smoke_test.exs` alone is about 108s for six tests, and the one
# that walks every preview page sits right against ExUnit's 60s default: correct, and occasionally
# a second the wrong side of the wall.
#
# Doubling it is headroom for that, not cover for a hang: a genuinely stuck test still fails, just
# a minute later. The timeout is per test, so a passing run is not lengthened at all.
#
# Same figure and same reasoning as the library suite's `test/test_helper.exs`, which raised it for
# the same reason a while ago; this one had simply never been given the same treatment.
ExUnit.start()
ExUnit.configure(timeout: 120_000)
