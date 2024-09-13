defmodule MishkaChelekom.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :unit_price, :float
    field :sku, :integer
    field :gku, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku, :gku])
    |> validate_required([:name, :description, :unit_price, :sku, :gku])
    |> unique_constraint(:sku)
  end
end
