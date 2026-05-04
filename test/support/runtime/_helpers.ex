defmodule MishkaChelekom.Test.Runtime.Compilers.Helpers do
  @doc """
  Generates a unique module name for runtime-compiled resources.

  This function creates a deterministic module name by combining the resource ID,
  site identifier, and resource type. It uses MD5 hashing to ensure the generated
  module name is always valid and avoids Elixir module naming restrictions.

  ## Parameters

   * `id` - A string identifier for the resource (typically a UUID)
   * `site` - A string identifier for the site/tenant
   * `resource` - A string representing the resource type (e.g., "page", "component", "layout")

  ## Examples

     iex> module_name("550e8400-e29b-41d4-a716-446655440000", "blog", "page")
     MishkaChelekom.Test.Runtime.A1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6.Page

     iex> module_name("123-456-789", "my_site", "component")
     MishkaChelekom.Test.Runtime.B2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7.Component

  ## Implementation Details

  The function uses MD5 hashing to:
  - Handle any special characters in `id` or `site` that would be invalid in module names
  - Ensure consistent module naming regardless of input format
  - Avoid Elixir's module name length limitations
  - Provide collision resistance for different ID/site combinations
  - If we expect < 50,000 unique pages, phash2 was fine. Beyond that, we considered MD5 for safety.

  The generated module follows the pattern: `MishkaChelekom.Test.Runtime.<md5_hash>.<Resource>`

  ## Notes

  - The same `id`, `site`, and `resource` combination will always generate the same module name
  - MD5 is used for speed and deterministic output, not cryptographic security
  - The function assumes `resource` contains only valid module name characters
  """
  @spec module_name(String.t(), String.t() | nil, String.t()) :: module()
  def module_name(id, site, resource) do
    # Coerce a missing/nil site to "Global" so callers can pass raw
    # `assigns[:site]` (which is `nil` outside the parent's declared
    # `:site` attr scope, e.g. inside slot inner_blocks) without
    # producing a different hash than the boot-time compile path.
    # Boot/worker code already routes `nil` through this same rule —
    # centralizing it here keeps the hash key authoritative.
    resolved_site = site || "Global"
    site_hash = :md5 |> :crypto.hash("#{id}" <> resolved_site) |> Base.encode16(case: :lower)

    Module.concat([MishkaChelekom.Test.Runtime, "#{site_hash}", resource])
  end

  # `compress_asset/1` is dropped from this vendored test variant —
  # chelekom doesn't ship `ExBrotli` and the test harness never
  # compresses anything. The real CMS still has the full version.

  @doc """
  Recursively convert string keys in a map to atoms (mirrors
  `MishkaCmsCore.Runtime.Helpers.atomize_keys/1` from the CMS).
  """
  def atomize_keys(map) when is_map(map) and not is_struct(map) do
    for {k, v} <- map, into: %{} do
      {if(is_binary(k), do: String.to_atom(k), else: k), atomize_keys(v)}
    end
  end

  def atomize_keys(list) when is_list(list) do
    for item <- list, do: atomize_keys(item)
  end

  def atomize_keys(value), do: value
end
