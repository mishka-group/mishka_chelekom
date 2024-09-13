defmodule MishkaChelekom.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :fullname, :string
    field :adress, :string
    field :phone, :string
    field :zipcode, :string
    field :email, :string
    field :password, :string
    field :job, Ecto.Enum, values: [frontend: 1, backend: 2, designer: 3]
    field :accepted_terms, :boolean, virtual: true
    field :experience, {:array, :string}
    field :start_office_hour, :time
    field :start_office_day, :date
    field :image, :string
    field :salary, :integer

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(
    fullname adress phone zipcode email password job experience start_office_hour
    start_office_day image salary
  )a

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ [:accepted_terms])
    |> validate_required(@required_fields)
    |> validate_confirmation(:password)
    |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:salary, 1..100)
    |> validate_length(:fullname, min: 3, max: 70)
    |> validate_length(:adress, min: 3, max: 250)
    |> validate_length(:password, min: 8, max: 150)
    |> validate_length(:email, max: 250)
    |> validate_length(:phone, is: 11)
    |> validate_length(:zipcode, is: 6)
    |> validate_acceptance(:accepted_terms)
    |> validate_subset(:experience, ["nextjs", "react", "liveview"])
  end
end
