defmodule Test.Repo do
  use Ecto.Repo,
    otp_app: :test,
    adapter: Ecto.Adapters.Postgres
end
