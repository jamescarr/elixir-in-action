
defmodule Todo.Server do
  use GenServer

  @impl GenServer
  def init(name) do
    {:ok, {name, nil}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  @impl GenServer
  def handle_cast({:add, entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_list)

    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:remove, entry_id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {_, todo_list}) do
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
