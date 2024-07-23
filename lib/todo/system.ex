defmodule Todo.System do
  use Supervisor
  require Logger

  def start_link do
    Logger.info("Starting Todo.System supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info("Initializing Todo.System supervisor...")
    children =
      [
        Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache
      ]

    Supervisor.init(children, strategy: :one_for_one)
  end


  def handle_info({:EXIT, pid, reason}, state) do
    Logger.error("Process #{inspect(pid)} exited with reason: #{inspect(reason)}")
    {:noreply, state}
  end
end
