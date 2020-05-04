defmodule Elephant.Store.Postgres.Migration.Memory do
  use Ecto.Migration

  def change do
    create table("memory") do
      add(:memory_id, :uuid, primary_key: true, null: false)
      add(:target, :utc_datetime, null: false)
      add(:action, :binary, null: false)
    end
  end
end
