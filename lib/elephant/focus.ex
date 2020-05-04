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

    fetch_up_to_datetime =
      Elephant.Clock.time_travel(DateTime.utc_now(), {@polling_interval, :seconds})

    {:ok, stream} = @store.fetch(fetch_up_to_datetime)

    stream
    |> Stream.each(fn {target, {mod, func, args}} ->
      :timer.apply_after(wait_time(target), mod, func, args)
    end)
    |> Stream.run()
  end

  def schedule_work do
    Process.send_after(self(), :next, @polling_interval * 1_000)
  end

  defp wait_time(target) do
    max(DateTime.diff(target, DateTime.utc_now(), :millisecond), 0)
  end
end
