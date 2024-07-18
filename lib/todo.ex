defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list_acc ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries = Map.put(
      todo_list.entries,
      todo_list.next_id,
      entry
    )

    %TodoList{todo_list |
      entries: new_entries,
      next_id: todo_list.next_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
      |> Map.values()
      |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, update_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = update_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{
      entries: Map.delete(todo_list.entries, entry_id),
      next_id: todo_list.next_id,
    }
  end

end

defmodule TodoList.CsvImporter do

  def import(file_path) do
    File.stream!(file_path)
    |>  Enum.reduce(TodoList.new(), fn line, todo_list ->
        [date_str, title] = String.split(String.trim(line), ",")
        date = Date.from_iso8601!(date_str)
        TodoList.add_entry(todo_list, %{date: date, title: title})
      end)
  end

end

defmodule TodoServer do
  def init() do
    TodoList.new()
  end

  def start() do
    ServerProcess.start(TodoServer)
  end

  def handle_cast({:add, entry}, todo_list) do
    TodoList.add_entry(todo_list, entry)
  end

  def handle_cast({:remove, entry_id}, todo_list) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end

  # client functions

  def add(server_pid, entry) do
    ServerProcess.cast(server_pid, {:add, entry})
  end

  def remove(server_pid, entry_id) do
    ServerProcess.cast(server_pid, {:remove, entry_id})
  end

  def entries(server_pid, date) do
    ServerProcess.call(server_pid, {:entries, date})
  end

end

# Generic Server Process
defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} =
          callback_module.handle_call(
            request,
            current_state
          )
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(
          request,
          current_state
        )

        loop(callback_module, new_state)
    end

  end


  # client methods
  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})
    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end


end
defmodule KeyValueStore do
  def init do
    %{}
  end
  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end
  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end

  def handle_cast({:put, key, value}, state) do
    Map.put(state, key, value)
  end

  def start() do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, val) do
    ServerProcess.call(pid, {:put, key, val})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})

  end
end



# override to_string
defimpl String.Chars, for: TodoList do
  def to_string(_) do
    "#TodoList"
  end
end

# Make TodoList collectable
defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_todo_list, :halt), do: :ok
end
