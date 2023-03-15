defmodule Random.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :points, :integer, null: false

      timestamps()
    end
  end
end
