defmodule Example.Application do
  use Application

  def start(_type, _args) do
    children = [Example.Repo, Elephant.Focus]

    Supervisor.start_link(children, name: Example.Supervisor, strategy: :one_for_one)
  end
end
