defmodule BarrelExLogger.Mixfile do
  use Mix.Project

  def project do
    [app: :barrel_ex_logger,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
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

  defp description do
    """
    Elixir Logger and Lager bridge for Barrel.
    """
  end

  defp package do
    [
     name: :postgrex,
     files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*", "NOTICE"],
     maintainers: ["Sushruth Sivaramakrishnan"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/barrel-db/barrel_ex_logger"}]
  end
end
