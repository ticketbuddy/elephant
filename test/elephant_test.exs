defmodule ElephantTest do
  use ExUnit.Case
  import Mox
  setup :verify_on_exit!

  test "stores an action" do
    time_travel_opts = {5, :minutes}
    action = {Printer, :print, []}
    now = DateTime.utc_now()
    expected_at = Elephant.Clock.time_travel(now, time_travel_opts)

    Elephant.StoreMock
    |> expect(:put, fn %Elephant.Memory{at: ^expected_at, action: ^action} ->
      :ok
    end)

    assert :ok == Elephant.remember(time_travel_opts, action, now)
  end
end
