defmodule MishkaChelekom.Avatar do
  use Phoenix.Component

  # TODO: We need Avatar tooltip
  # TODO: We need Dot indicator
  # TODO: We need dropdown
  @sizes ["extra_small", "small", "medium", "large", "extra_large"]

  @doc type: :component
  attr :id, :string, default: nil, doc: ""

  attr :type, :string,
    values: ["default", "placeholder", "placeholder_icon", nil],
    default: "default",
    doc: ""

  attr :size, :string, default: "large", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :border, :string, doc: ""
  attr :rest, :global

  def avatar(assigns) do
    ~H"""
    """
  end

  @doc type: :component
  attr :id, :string, default: nil, doc: ""

  attr :type, :string,
    values: ["default", "placeholder", "placeholder_icon", nil],
    default: "default",
    doc: ""

  attr :size, :string, default: "large", doc: ""
  attr :rounded, :string, values: @sizes ++ ["full", "none"], default: "large", doc: ""
  attr :border, :string, doc: ""
  attr :rest, :global

  def avatar_group(assigns) do
    ~H"""
    """
  end
end
