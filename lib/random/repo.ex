defmodule Random.Repo do
  use Ecto.Repo,
    otp_app: :random,
    adapter: Ecto.Adapters.Postgres
end
