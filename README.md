# BarrelExLogger

Elixir Logger and Lager bridge for Barrel

## Installation

The package can be installed as:

  1. Add barrel_ex_logger to your list of dependencies in `mix.exs`:

        def deps do
          [{:barrel_ex_logger, "~> 0.0.1"}]
        end

  2. Ensure barrel_ex_logger is started before your application:

        def application do
          [applications: [:barrel_ex_logger]]
        end

