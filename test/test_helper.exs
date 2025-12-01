# Exclude slow integration tests by default
# Run them with: mix test --include sync_integration
ExUnit.start(exclude: [:sync_integration])
