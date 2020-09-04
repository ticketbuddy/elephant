defmodule Elephant do
  @moduledoc """
  Documentation for Elephant.
  """

  alias Elephant.{Clock, Memory}

  def remember(store, time_travel_opts, action, now) do
    %Memory{
      at: Clock.time_travel(now, time_travel_opts),
      action: action
    }
    |> store.put()
  end

  defmacro __using__(store: store) do
    quote do
      @store unquote(store)

      def remember(time_travel_opts, action, now \\ Clock.now()) do
        Elephant.remember(@store, time_travel_opts, action, now)
      end
    end
  end
end
