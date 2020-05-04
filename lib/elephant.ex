defmodule Elephant do
  @moduledoc """
  Documentation for Elephant.
  """

  alias Elephant.Clock

  @store Application.get_env(:elephant, :store, Elephant.StoreMock)

  def exec(time_travel_opts, payload, now \\ DateTime.utc_now()) do
    # @store
    Clock.time_travel(now, time_travel_opts)
  end
end
