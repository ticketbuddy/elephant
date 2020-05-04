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

        query = from m in Schema.Memory, select: m

        stream = @repo.all(query)
        @repo.transaction(fn() ->
          stream
          |> Stream.map(fn memory ->
            {memory.target, :erlang.binary_to_term(memory.action)}
          end)
          |> callback.()
        end)
      end

      def delete(action_id) do
        # :ok | :error
      end
    end
  end
end
