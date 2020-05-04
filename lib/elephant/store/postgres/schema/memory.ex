defmodule Elephant.Store.Postgres.Schema.Memory do
  use Ecto.Schema
  @primary_key {:memory_id, :binary_id, autogenerate: true}

  schema "memory" do
    field(:target, :utc_datetime, null: false)
    field(:action, :binary, null: false)
  end
end
