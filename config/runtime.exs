import Config

http_port =
  if config_env() != :test,
    do: System.get_env("TODO_HTTP_PORT", "5454"),
    else: System.get_env("TODO_TEST_HTTP_PORT", "5455")
config :todo, http_port: String.to_integer(http_port)

db_path =
  if config_env() != :test,
    do: System.get_env("TODO_DB_PATH", "./persist/todo"),
    else: System.get_env("TODO_DB_PATH", "./persist/todo-test")

config :todo, db_path: db_path


