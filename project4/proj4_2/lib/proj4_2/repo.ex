defmodule Proj42.Repo do
  use Ecto.Repo,
    otp_app: :proj4_2,
    adapter: Ecto.Adapters.Postgres
end
