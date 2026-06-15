defmodule MishkaChelekom.Kit.Entities.Rule do
  @moduledoc """
  Entity struct for a **styled dimension rule** inside a `customize`:
  `color :brand, "…"` → `%Rule{attr: :color, value: :brand, classes: "…"}`.

  A rule may also be **paired** on the variant×color axis — mirroring how the components
  themselves key styling (`color_variant(@variant, @color)`). The optional `color`/`variant`
  fields hold the partner value, so the rule matches only that specific combination:

      variant :bordered, "…", color: :danger
      #   → %Rule{attr: :variant, value: :bordered, classes: "…", color: :danger}

  Built by the dimension entities (`color`/`variant`/`size`/…) in `MishkaChelekom.Kit.Dsl`.
  """
  defstruct [:attr, :value, :classes, :color, :variant, __spark_metadata__: nil]
end
