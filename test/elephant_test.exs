defmodule ElephantTest do
  use ExUnit.Case
  import Mox
  setup :verify_on_exit!

  describe "stores an action" do
    test "when a specific date is provided" do
      # time_travel_opts = {5, :minutes}
      action = {Printer, :print, []}
      expected_at = Elephant.Clock.now()

      Elephant.StoreMock
      |> expect(:put, fn %Elephant.Memory{at: ^expected_at, action: ^action} ->
        :ok
      end)

      assert :ok == Elephant.remember(expected_at, action)
    end

    test "when time travel options are provided" do
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
end
