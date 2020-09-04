defmodule Elephant.Focus do
  use GenServer
  require Logger
  @startup_grace_period_ms 250

  def start_link(opts) do
    store = Keyword.get(opts, :store)
    polling_interval_seconds = Keyword.get(opts, :polling_interval_seconds)
    init_state = {store, polling_interval_seconds}

    GenServer.start_link(__MODULE__, init_state, opts)
  end

  def init(state) do
    Process.send_after(self(), :next, @startup_grace_period_ms)

    {:ok, state}
  end

  def handle_info(:next, state) do
    {store, polling_interval} = state
    schedule_work(polling_interval)
    up_to_date = up_to(polling_interval)

    store.fetch(up_to_date, fn stream ->
      stream
      |> Stream.each(&Elephant.Focus.Execute.run_at(store, &1))
      |> Stream.run()
    end)

    {:noreply, state}
  end

  def schedule_work(polling_interval) do
    Process.send_after(self(), :next, polling_interval * 1_000)
  end

  defp up_to(polling_interval) do
    Elephant.Clock.time_travel(Elephant.Clock.now(), {polling_interval, :seconds})
  end
end
