defmodule Elephant.Store do
  @type memory_id :: String.t()
  @callback put(Memory.t()) :: :ok | :error

  @doc ~s(Fetch memories up to the datetime)
  @callback fetch(DateTime.t()) :: {:ok, Stream.t()} | :error

  @callback delete(memory_id) :: :ok | :error
end
