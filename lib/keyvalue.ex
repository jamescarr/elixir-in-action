
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


