defmodule Example.PostgresStore do
  use Elephant.Store.Postgres, repo: Example.Repo
end
