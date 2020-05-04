defmodule Elephant.Store do
  @type callback :: {module(), atom(), list()}
  @type timestamp :: DateTime.t()
  @type action_id :: String.t()
  @type time_period :: :minutes | :hours
  @type retry_option :: {pos_integer(), time_period}
  @type failure_strategy :: {:retry, retry_options} | {:retry_until_success, retry_options} | :ignore

  @callback store(timestamp, failure_strategy, callback) :: :ok | :error
  @callback fetch_up_to(timestamp) :: {:ok, Stream.t()} | :error
  @callback delete(action_id) :: :ok | :error
end
