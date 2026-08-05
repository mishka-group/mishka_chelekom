defmodule MishkaMob.Round do
  use Ecto.Schema

  schema "rounds" do
    # "rock" | "paper" | "scissors"
    field(:user_choice, :string)
    field(:computer_choice, :string)
    # "win" | "loss" | "draw"
    field(:result, :string)
    timestamps()
  end
end
