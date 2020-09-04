alias Elephant.Store.Postgres.Schema
alias Test.Support.Repo

{:ok, _} = Ecto.Adapters.Postgres.ensure_all_started(Repo, :temporary)
{:ok, _pid} = Repo.start_link()

Repo.insert!(%Schema.Memory{
  memory_id: "c8d10874-f3eb-4b8b-92d1-877160703da8",
  target: ~U[2020-02-04 20:12:14Z],
  action: :erlang.term_to_binary({IO, :puts, ["Hello there!"]})
})

Repo.insert!(%Schema.Memory{
  memory_id: "c8d10874-f3eb-4b8b-92d1-877160703da7",
  target: ~U[2020-05-04 20:12:14Z],
  action: :erlang.term_to_binary({IO, :puts, ["Hello World!"]})
})

Repo.insert!(%Schema.Memory{
  memory_id: "c8d10874-f3eb-4b8b-92d1-877160703da5",
  target: ~U[2020-01-04 20:12:14Z],
  action: :erlang.term_to_binary({IO, :puts, ["Hello James!"]})
})

IO.puts("Seed data done.")
