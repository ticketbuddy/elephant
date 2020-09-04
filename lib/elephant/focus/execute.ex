defmodule Elephant.Focus.Execute do
  def run_at(store, {memory_id, target, {mod, func, args}}) do
    :timer.apply_after(wait_time(target), __MODULE__, :do_apply, [
      store,
      memory_id,
      {mod, func, args}
    ])
  end

  def do_apply(store, memory_id, {mod, func, args}) do
    apply(mod, func, args)
    |> case do
      :ok ->
        store.delete(memory_id)

      _error ->
        :error
    end
  end

  defp wait_time(target) do
    max(DateTime.diff(target, DateTime.utc_now(), :millisecond), 0)
  end
end
