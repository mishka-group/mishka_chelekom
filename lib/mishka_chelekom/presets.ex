defmodule MishkaChelekom.Presets.Default do
  @moduledoc """
  The default theme preset — no overrides. Components render with their own generated classes.
  Conventionally appended last in `config :mishka_chelekom, :overrides`.
  """
  use MishkaChelekom.Overrides
end

defmodule MishkaChelekom.Presets.Flat do
  @moduledoc "A flat preset — drops shadows and heavy borders. Example/starting point."
  use MishkaChelekom.Overrides

  override :button, :root, "shadow-none"
  override :card, :root, "shadow-none border border-base-300"
  override :dialog, :popup, "shadow-none border border-base-300"
end

defmodule MishkaChelekom.Presets.Bordered do
  @moduledoc "A bordered preset — emphasizes borders over shadows. Example/starting point."
  use MishkaChelekom.Overrides

  override :button, :root, "border-2 shadow-none"
  override :card, :root, "border-2 shadow-none"
  override :dialog, :popup, "border-2 shadow-none"
end
