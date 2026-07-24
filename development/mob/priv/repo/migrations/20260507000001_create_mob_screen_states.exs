defmodule MishkaMob.Repo.Migrations.CreateMobScreenStates do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:mob_screen_states, primary_key: false) do
      add :key,        :text,    primary_key: true, null: false
      add :vsn,        :integer, null: false, default: 0
      add :data,       :binary,  null: false
      add :updated_at, :integer, null: false
    end
  end
end
