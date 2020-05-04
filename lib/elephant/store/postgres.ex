defmodule Elephant.Store.Postgres do
  defmacro __using__(repo: repo) do
    quote do
      @behaviour Elephant.Store
      @repo unquote(repo)
      alias Elephant.Memory
      alias Elephant.Store.Postgres.Schema

      def put(memory = %Memory{}) do
        @repo.insert(%Schema.Memory{
          target: memory.at,
          action: :erlang.term_to_binary(memory.action)
        })
        |> case do
          {:ok, _memory} -> :ok
          {:error, reason} -> :error
        end
      end

      def fetch(up_to_datetime, callback) do
        import Ecto.Query, only: [from: 2]

        query = from(m in Schema.Memory, where: m.target <= ^up_to_datetime, order_by: m.target)

        stream = @repo.all(query)

        @repo.transaction(fn ->
          stream
          |> Stream.map(fn memory ->
            {memory.target, :erlang.binary_to_term(memory.action)}
          end)
          |> callback.()
        end)
        |> case do
          {:ok, true} -> :ok
          _error -> :error
        end
      end

      def delete(memory_id) do
        @repo.delete(%Schema.Memory{memory_id: memory_id}, stale_error_field: :errors)

        :ok
      end
    end
  end
end
