use Mix.Config

config :logger, :sumologic,
  client: LoggerSumologicBackend.Clients.Test
