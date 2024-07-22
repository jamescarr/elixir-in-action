defmodule Todo.System do
  use Supervisor

  def start_link do
    IO.puts("[#{inspect(self())}] Starting Todo.System supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts("[#{inspect(self())}] Initializing Todo.System supervisor...")
    children = [
      {Todo.ProcessRegistry, []},
      {Todo.Database, []},
      {Todo.Cache, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
