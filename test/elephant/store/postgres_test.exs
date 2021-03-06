defmodule Elephant.Store.PostgresTest do
  use ExUnit.Case
  use Test.Support.Helper, repo: [Test.Support.Repo]

  defmodule PostgresTestDb do
    use Elephant.Store.Postgres, repo: Test.Support.Repo
  end

  test "stores a memory" do
    assert {:ok, _memory_id} =
             PostgresTestDb.put(%Elephant.Memory{
               at: Elephant.Clock.now(),
               action: {IO, :puts, ["Hello World"]}
             })
  end

  describe "fetches a memory" do
    test "when no memories exist within specified datetime" do
      up_to_datetime = ~U[2019-05-04 20:30:14Z]

      assert :ok ==
               PostgresTestDb.fetch(up_to_datetime, fn stream ->
                 assert Enum.to_list(stream) == []
               end)
    end

    test "memories are ordered by datetime" do
      up_to_datetime = ~U[2020-10-04 21:12:14Z]

      assert :ok ==
               PostgresTestDb.fetch(up_to_datetime, fn stream ->
                 assert [
                          {"c8d10874-f3eb-4b8b-92d1-877160703da5", ~U[2020-01-04 20:12:14Z],
                           {IO, :puts, ["Hello James!"]}},
                          {"c8d10874-f3eb-4b8b-92d1-877160703da8", ~U[2020-02-04 20:12:14Z],
                           {IO, :puts, ["Hello there!"]}},
                          {"c8d10874-f3eb-4b8b-92d1-877160703da7", ~U[2020-05-04 20:12:14Z],
                           {IO, :puts, ["Hello World!"]}}
                        ] == Enum.to_list(stream)
               end)
    end

    test "when memories exist within specified datetime" do
      up_to_datetime = ~U[2020-01-04 21:12:14Z]

      assert :ok ==
               PostgresTestDb.fetch(up_to_datetime, fn stream ->
                 assert [
                          {"c8d10874-f3eb-4b8b-92d1-877160703da5", ~U[2020-01-04 20:12:14Z],
                           {IO, :puts, ["Hello James!"]}}
                        ] == Enum.to_list(stream)
               end)
    end
  end

  describe "deletes a memory" do
    test "when memory exists" do
      assert :ok == PostgresTestDb.delete("c8d10874-f3eb-4b8b-92d1-877160703da8")
    end

    test "when memory does not exists" do
      assert :ok == PostgresTestDb.delete("c8d10874-f3eb-4b8b-92d1-877160703da9")
    end
  end
end
