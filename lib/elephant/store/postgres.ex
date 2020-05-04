defmodule Elephant.Store.Postgres do
  defmacro __using__(repo: repo) do
    quote do
      @behaviour Elephant.Store
      @repo unquote(repo)
      alias Elephant.Memory

      def put(memory = %Memory{}) do
         # :ok | :error
      end

      def fetch(up_to_datetime) do
        # {:ok, Stream.t()} | :error
      end

      def delete(action_id) do
        # :ok | :error
      end
    end
  end
end
