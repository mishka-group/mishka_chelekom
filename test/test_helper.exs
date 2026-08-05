# Exclude slow integration tests by default
# Run them with: mix test --include sync_integration
ExUnit.start(exclude: [:sync_integration])

# The 21 `:igniter` modules each build a throwaway Mix project and compile it,
# so their wall time is dominated by compilation rather than by anything they
# assert. Every one finishes in about a second in isolation, but that figure
# scales with how busy the machine is, and ExUnit's 60s default is a wall the
# slowest of them can hit on a loaded laptop while still being perfectly
# correct.
#
# Doubling it is headroom for that, not cover for a hang: a genuinely stuck test
# still fails, just a minute later. The timeout is per test, so a passing run is
# not lengthened at all — this suite is 720 tests in about 270s.
#
# Global rather than a moduletag on each igniter module: the same pressure
# applies to anything that shells out or compiles, and one line beats the same
# line repeated 21 times.
ExUnit.configure(timeout: 120_000)
