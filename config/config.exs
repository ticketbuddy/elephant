import Mix.Config

config :elephant, polling_interval_seconds: 5

config :elephant, ecto_repos: [Test.Support.Repo]

config :elephant, Test.Support.Repo,
  database: "elephant",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
