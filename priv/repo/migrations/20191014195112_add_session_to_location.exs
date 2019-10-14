defmodule BeespotBackend.Repo.Migrations.AddSessionToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :session_id, references(:sessions)
    end

    create index(:locations, [:session_id])
  end
end
