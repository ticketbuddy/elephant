defmodule Example.Repo.Migrations.Memory do
  use Ecto.Migration

  def change do
    Elephant.Store.Postgres.Migration.Memory.change()
  end
end
