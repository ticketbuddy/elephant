defmodule Test.Example.Store.PostgresTest do
  use ExUnit.Case
  use Test.Support.Helper, repo: [Example.Repo]

  test "stores a memory" do
    assert :ok ==
             Example.PostgresStore.put(%Elephant.Memory{
               at: Elephant.Clock.now(),
               action: {IO, :puts, ["Hello World"]}
             })
  end

  describe "fetches a memory" do
    test "when no memories exist within specified datetime" do
      up_to_datetime = ~U[2019-05-04 20:30:14Z]

      assert :ok ==
               Example.PostgresStore.fetch(up_to_datetime, fn stream ->
                 assert Enum.to_list(stream) == []
               end)
    end

    test "memories are ordered by datetime" do
      up_to_datetime = ~U[2020-10-04 21:12:14Z]

      assert :ok ==
               Example.PostgresStore.fetch(up_to_datetime, fn stream ->
                 assert [
                          {~U[2020-01-04 20:12:14Z], {IO, :puts, ["Hello James!"]}},
                          {~U[2020-02-04 20:12:14Z], {IO, :puts, ["Hello there!"]}},
                          {~U[2020-05-04 20:12:14Z], {IO, :puts, ["Hello World!"]}}
                        ] == Enum.to_list(stream)
               end)
    end

    test "when memories exist within specified datetime" do
      up_to_datetime = ~U[2020-01-04 21:12:14Z]

      assert :ok ==
               Example.PostgresStore.fetch(up_to_datetime, fn stream ->
                 assert [
                          {~U[2020-01-04 20:12:14Z], {IO, :puts, ["Hello James!"]}}
                        ] == Enum.to_list(stream)
               end)
    end
  end
end
