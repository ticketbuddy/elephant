defmodule Elephant.Focus do
  use GenServer
  @polling_interval Application.get_env(:elephant, :polling_interval_seconds)
  @store Application.get_env(:elephant, :store, Elephant.StoreMock)

  def start_link() do
    GenServer.start_link(__MODULE__, :no_state, name: :elephant_focus)
  end

  def init(state) do
    schedule_work()

    {:ok, state}
  end

  def handle_info(:next, state) do
    schedule_work()
    # TODO load the next memories within the
    # @polling_interval amount, and call send_after for each.

    fetch_up_to_datetime =
      Elephant.Clock.time_travel(DateTime.utc_now(), {@polling_interval, :seconds})

    {:ok, stream} = @store.fetch(fetch_up_to_datetime)

    stream
    |> Stream.each(fn {target, {mod, func, args}} ->
      wait_time = max(DateTime.diff(target, DateTime.utc_now(), :second), 0) * 1_000

      :timer.apply_after(wait_time, mod, func, args)
    end)
    |> Stream.run()
  end

  def schedule_work do
    Process.send_after(self(), :next, @polling_interval * 1_000)
  end
end
