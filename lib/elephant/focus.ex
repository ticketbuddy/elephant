defmodule Elephant.Focus do
  use GenServer
  @polling_interval Application.get_env(:elephant, :polling_interval_seconds)
  @store Application.get_env(:elephant, :store, Elephant.StoreMock)
  @startup_grace_period_ms 250

  def start_link() do
    GenServer.start_link(__MODULE__, :no_state, name: :elephant_focus)
  end

  def init(state) do
    Process.send_after(self(), :next, @startup_grace_period_ms)

    {:ok, state}
  end

  def handle_info(:next, _state) do
    schedule_work()

    {:ok, stream} = @store.fetch(fetch_up_to_datetime())

    stream
    |> Stream.each(&wait_and_run_callback/1)
    |> Stream.run()
  end

  def schedule_work do
    Process.send_after(self(), :next, @polling_interval * 1_000)
  end

  defp wait_and_run_callback({target, {mod, func, args}}) do
    :timer.apply_after(wait_time(target), mod, func, args)
  end

  defp wait_time(target) do
    max(DateTime.diff(target, DateTime.utc_now(), :millisecond), 0)
  end

  defp fetch_up_to_datetime() do
    Elephant.Clock.time_travel(DateTime.utc_now(), {@polling_interval, :seconds})
  end
end
