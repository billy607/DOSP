use Mix.Config

# Configure your database
config :proj4_2, Proj42.Repo,
  username: "postgres",
  password: "postgres",
  database: "proj4_2_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :proj4_2, Proj42Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
