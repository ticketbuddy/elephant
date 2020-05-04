defmodule Elephant.Focus do
  use GenServer
  require Logger
  @polling_interval Application.get_env(:elephant, :polling_interval_seconds)
  @store Application.get_env(:elephant, :store, Elephant.StoreMock)
  @startup_grace_period_ms 250

  def start_link(_opts) do
    init_state = DateTime.utc_now()
    GenServer.start_link(__MODULE__, init_state, name: :elephant_focus)
  end

  def init(state) do
    Process.send_after(self(), :next, @startup_grace_period_ms)

    {:ok, state}
  end

  def handle_info(:next, state) do
    previous_up_to_datetime = state
    next_up_to_datetime = next_up_to_datetime(previous_up_to_datetime)
    schedule_work()

    @store.fetch(next_up_to_datetime, fn stream ->
      Logger.info("Running the stream")

      stream
      |> Stream.map(&wait_and_run_callback/1)
      |> Stream.run()
    end)

    {:noreply, next_up_to_datetime}
  end

  def schedule_work do
    Logger.info("Scheduling work")
    Process.send_after(self(), :next, @polling_interval * 1_000)
  end

  defp wait_and_run_callback({memory_id, target, {mod, func, args}}) do
    Logger.info("#{inspect({target, mod, func, args})}")
    :timer.apply_after(wait_time(target), __MODULE__, :do_apply, [memory_id, {mod, func, args}])
  end

  def do_apply(memory_id, {mod, func, args}) do
    apply(mod, func, args)
    |> case do
      :ok ->
        @store.delete(memory_id)

      _error ->
        :error
    end
  end

  defp wait_time(target) do
    max(DateTime.diff(target, DateTime.utc_now(), :millisecond), 0)
  end

  defp next_up_to_datetime(datetime) do
    Elephant.Clock.time_travel(datetime, {@polling_interval, :seconds})
  end
end
