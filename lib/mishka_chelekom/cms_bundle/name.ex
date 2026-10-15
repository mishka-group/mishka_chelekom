defmodule MishkaChelekom.CmsBundle.Name do
  @moduledoc """
  The name a CMS stores a bundle row under, for every row the bundle writes and every place one row
  names another.

  A CMS slugifies the name of each component, JS hook and stylesheet as it saves the row —
  lowercase, every run of anything but a letter or a digit one hyphen — and rewrites nothing that
  refers to it. A bundle that ships `chelekom_headless-button-content` and calls it by that name
  installs `chelekom-headless-button-content` and calls a component that does not exist, so the
  name written on a row, in a `component_name="…"`, in `dependencies` and in a hook key all come
  from here.

      iex> MishkaChelekom.CmsBundle.Name.component("chelekom_headless", "button_content")
      "chelekom-headless-button-content"

      iex> MishkaChelekom.CmsBundle.Name.stored("chelekom-scroll_area")
      "chelekom-scroll-area"
  """

  @doc "The form a CMS stores `name` in."
  @spec stored(String.t() | atom()) :: String.t()
  def stored(name) do
    name
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  @doc "The stored name of the kit's row for `name`: the kit's name in front, then the whole slugified."
  @spec component(String.t() | nil, String.t() | atom()) :: String.t()
  def component(kit_name, name), do: stored("#{kit_name}-#{name}")
end
