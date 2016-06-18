defmodule BarrelExLogger.Mixfile do
  use Mix.Project

  def project do
    [app: :barrel_ex_logger,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:lager, :logger]]
  end

  defp deps do
    [
      {:lager, "3.0.2"}
    ]
  end
end
