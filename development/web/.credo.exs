# Credo merges every `.credo.exs` from this directory up to the filesystem root, and the one at the
# repository root is the library's: it calls ExSlop and names Jump.CredoChecks, dev dependencies
# this app does not have, so reading it crashes Credo. The `credo` alias in mix.exs gives Credo
# this file alone, which keeps Credo's defaults.
%{configs: [%{name: "default"}]}
