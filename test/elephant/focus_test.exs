defmodule Elephant.FocusTest do
  use ExUnit.Case
  alias Elephant.Clock

  import Mox
  setup :set_mox_global
  setup :verify_on_exit!

  def to_stream(list) do
    list |> Stream.map(& &1)
  end

  defmodule FakeCallback do
    def run(destination, msg) do
      send(destination, msg)

      :ok
    end
  end

  test "schedules work on init" do
    Elephant.Focus.init(:no_state)

    assert_receive(:next, 500)
  end

  test "fetches and runs callbacks" do
    test_pid = self()
    now = DateTime.utc_now()

    callbacks = [
      {
        "memory-id-1",
        Clock.time_travel(now, {1, :seconds}),
        {FakeCallback, :run, [test_pid, :done_first]}
      },
      {
        "memory-id-2",
        Clock.time_travel(now, {2, :seconds}),
        {FakeCallback, :run, [test_pid, :done_second]}
      }
    ]

    Elephant.StoreMock
    |> expect(:fetch, fn _up_to_datetime, cb ->
      callbacks
      |> to_stream()
      |> cb.()

      :ok
    end)

    Elephant.StoreMock
    |> expect(:delete, 2, fn
      "memory-id-1" -> :ok
      "memory-id-2" -> :ok
    end)

    Elephant.Focus.handle_info(:next, :no_state)

    # no message for first 900 milliseconds
    refute_receive(:done_first, 900)

    # then should receive within next x milliseconds
    assert_receive(:done_first, 100)

    # still waiting for second message
    refute_receive(:done_second, 990)

    # then should receive within next x milliseconds
    assert_receive(:done_second, 50)
  end
end
