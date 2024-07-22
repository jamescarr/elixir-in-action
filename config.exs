use Mix.Config

config :logger, :console,
  format: "[$level] $message\n",
  metadata: [:request_id]

# Optionally, set the logger level to debug for more detailed logs
config :logger, level: :debug
