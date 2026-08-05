defmodule MishkaMob.Repo.Migrations.CreateRounds do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :user_choice,     :string, null: false
      add :computer_choice, :string, null: false
      add :result,          :string, null: false
      timestamps()
    end
  end
end
