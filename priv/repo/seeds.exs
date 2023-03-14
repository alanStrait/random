# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Random.Repo.insert!(%Random.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Random.{Accounts.User, Repo}

now = DateTime.to_naive(DateTime.truncate(DateTime.utc_now(), :second))
user_attr_list = Enum.into(1..10_000, [], fn _ -> %{points: 0, inserted_at: now, updated_at: now} end)

begin_time = System.monotonic_time(:millisecond)

1..100
|> Enum.each(fn _ ->
  Repo.insert_all(User, user_attr_list)
end)
fin_time = System.monotonic_time(:millisecond)

Process.sleep(500)
IO.puts("\nSeed load time\t#{fin_time - begin_time}MS")
