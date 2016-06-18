use Mix.Config
config :lager,
  error_logger_redirect: false,
  error_logger_whitelist: [Logger.ErrorHandler],
  crash_log: false,
  handlers: [{BarrelExLogger, [level: :debug]}]
