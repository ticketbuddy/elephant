defmodule Test.Example.Store.PostgresTest do
  use ExUnit.Case

  test "stores a memory" do
    assert :ok ==
             Example.PostgresStore.put(%Elephant.Memory{
               at: Elephant.Clock.now(),
               action: {IO, :puts, ["Hello World"]}
             })
  end

  test "fetches a memory" do
    up_to_datetime = ~U[2020-05-04 20:30:14Z]

    assert :ok ==
             Example.PostgresStore.fetch(up_to_datetime, fn stream ->
               assert Enum.to_list(stream) == []
             end)
  end
end
