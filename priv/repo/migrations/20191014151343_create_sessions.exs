defmodule BeespotBackend.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :session_id, :string

      timestamps()
    end

    create unique_index(:sessions, [:session_id])
  end
end
