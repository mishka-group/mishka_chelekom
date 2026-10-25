import Config

config :mob,
  extra_tags: [
    "MishkaAccordion",
    "MishkaActionIcon",
    "MishkaAlertDialog",
    "MishkaAlphaSlider",
    "MishkaAnchor",
    "MishkaAngleSlider",
    "MishkaAutocomplete",
    "MishkaAvatar",
    "MishkaBurger",
    "MishkaCheckbox",
    "MishkaCheckboxGroup",
    "MishkaChip",
    "MishkaCloseButton",
    "MishkaCode",
    "MishkaCollapsible",
    "MishkaColorInput",
    "MishkaColorPicker",
    "MishkaColorSwatch",
    "MishkaCombobox",
    "MishkaContextMenu",
    "MishkaDialog",
    "MishkaDrawer",
    "MishkaEmptyState",
    "MishkaField",
    "MishkaFieldset",
    "MishkaFloatingIndicator",
    "MishkaFloatingWindow",
    "MishkaHighlight",
    "MishkaHueSlider",
    "MishkaJsonInput",
    "MishkaLoadingOverlay",
    "MishkaMark",
    "MishkaMarquee",
    "MishkaMaskInput",
    "MishkaMenu",
    "MishkaMenubar",
    "MishkaMeter",
    "MishkaNavLink",
    "MishkaNavigationMenu",
    "MishkaNumberField",
    "MishkaNumberFormatter",
    "MishkaOtpField",
    "MishkaOverflowList",
    "MishkaPill",
    "MishkaPillsInput",
    "MishkaPopover",
    "MishkaPreviewCard",
    "MishkaProgress",
    "MishkaRadio",
    "MishkaRadioGroup",
    "MishkaRollingNumber",
    "MishkaScrollArea",
    "MishkaScroller",
    "MishkaSegmentedControl",
    "MishkaSelect",
    "MishkaSemiCircleProgress",
    "MishkaSeparator",
    "MishkaSkeleton",
    "MishkaSlider",
    "MishkaSplitter",
    "MishkaSpoiler",
    "MishkaSwitch",
    "MishkaTabs",
    "MishkaTagsInput",
    "MishkaThemeIcon",
    "MishkaToast",
    "MishkaToggle",
    "MishkaToggleGroup",
    "MishkaToolbar",
    "MishkaTooltip",
    "MishkaTree",
    "MishkaTreeSelect",
    "MishkaVisuallyHidden"
  ]

# Register the Repo so Mix tasks (mix ecto.create, mix ecto.migrate) can
# discover it. The actual database path is configured at runtime in
# MishkaMob.Repo.init/2 via the MOB_DATA_DIR environment variable.
config :mishka_mob, ecto_repos: [MishkaMob.Repo]

# Wire the Repo into Mob.ScreenState so screens using `vsn:` get automatic
# state persistence. Remove this line to disable screen state persistence.
config :mob, :repo, MishkaMob.Repo

# `mix e2e --report DIR` runs the device suite with a JUnit report in DIR, one file per
# partition. Only the test env has the formatter.
if config_env() == :test do
  config :junit_formatter,
    report_dir: System.get_env("E2E_REPORT_DIR", "_build/test/junit"),
    report_file: "junit-#{System.get_env("MIX_TEST_PARTITION", "1")}.xml",
    print_report_file: true,
    include_filename?: true
end
