defmodule Elephant do
  @moduledoc """
  Documentation for Elephant.
  """

  alias Elephant.{Clock, Memory}

  @store Application.get_env(:elephant, :store, Elephant.StoreMock)

  def remember(time_travel_opts, action, now \\ Clock.now()) do
    %Memory{
      at: Clock.time_travel(now, time_travel_opts),
      action: action
    }
    |> @store.put()
  end
end
