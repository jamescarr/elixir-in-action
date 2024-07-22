defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_path, worker_id}) do
    IO.puts("[#{inspect(self())}] Starting DB worker #{worker_id} #{db_path}")
    GenServer.start_link(
      __MODULE__,
      db_path,
      name: via_tuple(worker_id)
    )
  end

  @impl GenServer
  def init(db_path) do
    {:ok, db_path}
  end


  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  @impl GenServer
  def handle_cast({:store, key, data}, path) do
    IO.puts("[#{inspect(self())}] persisting #{key}")
    key
    |> file_name(path)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, path}
  end

  @impl GenServer
  def handle_call({:get, key}, _, path) do
    IO.puts("[#{inspect(self())}] restoring #{key}")
    data = case File.read(file_name(key, path)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, path}

  end

  defp file_name(key, path) do
    full_path = Path.join(path, to_string(key))
    IO.puts("Full path: #{full_path}")
    full_path
  end

end
