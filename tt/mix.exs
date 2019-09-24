defmodule Tt.MixProject do
  use Mix.Project

  def project do
    [
      app: :example_app,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      escript: escript()
    ]
  end

  defp escript do
    [main_module: ExampleApp.CLI]
  end
end

