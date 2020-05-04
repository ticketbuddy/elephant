defmodule Elephant.FocusTest do
  use ExUnit.Case
  alias Elephant.Clock

  import Mox
  setup :verify_on_exit!

  def to_stream(list) do
    list |> Stream.map(& &1)
  end

  test "fetches and runs callbacks" do
    callbacks = [
      {
        Clock.time_travel(DateTime.utc_now(), {1, :seconds}),
        {Kernel, :send, [self(), :done_first]}
      },
      {
        Clock.time_travel(DateTime.utc_now(), {2, :seconds}),
        {Kernel, :send, [self(), :done_second]}
      }
    ]

    Elephant.StoreMock
    |> expect(:fetch, fn _ ->
      {:ok, to_stream(callbacks)}
    end)

    Elephant.Focus.handle_info(:next, :no_state)

    # no message for first 999 milliseconds
    refute_receive(:done_first, 999)

    # then should receive within next 2 milliseconds
    assert_receive(:done_first, 2)

    # still waiting for second message
    refute_receive(:done_second, 1_000)

    # then should receive within next 2 milliseconds
    assert_receive(:done_second, 2)
  end
end
