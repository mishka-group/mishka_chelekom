defmodule MishkaMob.Round do
  use Ecto.Schema

  schema "rounds" do
    field :user_choice,     :string   # "rock" | "paper" | "scissors"
    field :computer_choice, :string
    field :result,          :string   # "win" | "loss" | "draw"
    timestamps()
  end
end
