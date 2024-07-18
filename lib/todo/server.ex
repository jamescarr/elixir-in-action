
defmodule Todo.Server do
  use GenServer

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def handle_cast({:add, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  @impl GenServer
  def handle_cast({:remove, entry_id}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end

  # client functions

  def add_entry(server_pid, entry) do
    GenServer.cast(server_pid, {:add, entry})
  end

  def remove(server_pid, entry_id) do
    GenServer.cast(server_pid, {:remove, entry_id})
  end

  def entries(server_pid, date) do
    GenServer.call(server_pid, {:entries, date})
  end

end
