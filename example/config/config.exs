import Mix.Config

config :example, ecto_repos: [Example.Repo]
config :example, Example.Repo, migration_timestamps: [type: :utc_datetime]
config :elephant, store: Example.PostgresStore, polling_interval_seconds: 300

config :example, Example.Repo,
  username: "postgres",
  password: "postgres",
  database: "headwater_example_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
