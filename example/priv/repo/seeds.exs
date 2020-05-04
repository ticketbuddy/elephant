alias Elephant.Store.Postgres.Schema

Example.Repo.insert!(%Schema.Memory{
  memory_id: "c8d10874-f3eb-4b8b-92d1-877160703da3",
  target: ~U[2020-05-04 20:12:14Z],
  action: :erlang.term_to_binary({IO, :puts, ["Hello World!"]})
 })

IO.puts "Seed data done."
