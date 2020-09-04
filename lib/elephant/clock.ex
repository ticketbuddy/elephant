defmodule Elephant.Clock do
  @valid_measures [:hours, :minutes, :seconds]

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

  iex> time_travel(~U[2020-05-04 15:32:54.000000Z], {1, :hours})
  ~U[2020-05-04 16:32:54.000000Z]

  iex> time_travel(~U[2020-05-04 15:32:54.000000Z], {1, :minutes})
  ~U[2020-05-04 15:33:54.000000Z]

  iex> time_travel(~U[2020-05-04 15:32:54.000000Z], ~U[2021-09-05 15:32:54.000000Z])
  ~U[2021-09-05 15:32:54.000000Z]
  """
  def time_travel(datetime, {value, measurement})
      when value > 0 and measurement in @valid_measures do
    opts = Keyword.new([{measurement, value}])
    Timex.shift(datetime, opts)
  end

  def time_travel(_now, desired_date_time = %DateTime{}) do
    desired_date_time
  end

  def now do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
