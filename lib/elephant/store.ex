defmodule Elephant.Store do
  @type action_id :: String.t()
  @callback put(Memory.t()) :: :ok | :error
  @doc ~s(Fetch memories up to the datetime)
  @callback fetch(DateTime.t()) :: {:ok, list()} | :error

  @callback delete(action_id) :: :ok | :error
end
