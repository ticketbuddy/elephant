defmodule ElephantTest do
  use ExUnit.Case
  import Mox
  setup :verify_on_exit!

  alias Elephant.Store.Postgres.Schema

  use Test.Support.Helper, repo: [Test.Support.Repo]

  defmodule MyMemory.Store do
    use Elephant.Store.Postgres, repo: Test.Support.Repo
  end

  defmodule MyMemory do
    use Elephant, store: MyMemory.Store
  end

  describe "stores an action" do
    test "when a specific date is provided" do
      action = {Printer, :print, []}
      expected_at = Elephant.Clock.now()

      assert {:ok, _memory_id} = MyMemory.remember(expected_at, action)
    end

    test "when time travel options are provided" do
      action = {Printer, :print, []}
      time_travel_opts = {5, :minutes}

      assert {:ok, _memory_id} = MyMemory.remember(time_travel_opts, action)
    end
  end

  describe "stores, runs an action" do
    setup do
      opts = [store: MyMemory.Store, polling_interval_seconds: 1]
      {:ok, _pid} = Elephant.Focus.start_link(opts)

      :ok
    end

    test "runs an action successfully, and deletes it" do
      action = {Kernel, :send, [self(), :ok]}
      time_travel_opts = {2, :seconds}

      assert {:ok, memory_id} = MyMemory.remember(time_travel_opts, action)
      assert_receive(:ok, 3_000)

      # allow time to remove record in the background
      :timer.sleep(50)

      assert nil == Test.Support.Repo.get(Schema.Memory, memory_id)
    end

    test "runs an action that fails, and keeps it" do
      action = {Kernel, :send, [self(), :failed]}
      time_travel_opts = {2, :seconds}

      assert {:ok, memory_id} = MyMemory.remember(time_travel_opts, action)
      assert_receive(:failed, 3_000)

      # allow time to remove record in the background
      :timer.sleep(50)

      refute nil == Test.Support.Repo.get(Schema.Memory, memory_id)
    end
  end
end
