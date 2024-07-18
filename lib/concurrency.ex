defmodule DatabaseServer do
  def start do
    spawn(fn ->
      connection = :rand.uniform(1000)
      loop(connection)
    end)
  end

  defp loop(connection) do
    receive do
      {:run_query, caller, query_def} ->
        query_result = run_query(connection, query_def)
        send(caller, {:query_result, query_result})
    end
    loop(connection)
  end

  defp run_query(connection, query_def) do
    Process.sleep(2000)
    "Connection #{connection}: #{query_def} result"
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end
end

defmodule Calculator do

  def start() do
    spawn(fn -> loop(0) end)
  end

  defp loop(current_value) do
    new_value =
      receive do
        message -> process_message(current_value, message)
      end

    loop(new_value)
  end



  defp process_message(current_value, {:value, caller}) do
    send(caller, {:response,current_value})
    current_value
  end

  defp process_message(current_value, {:add, value}) do
    current_value + value
  end

  defp process_message(current_value, {:sub, value}) do
    current_value - value
  end

  defp process_message(current_value, {:mul, value}) do
    current_value * value
  end

  defp process_message(current_value, {:div, value}) do
    current_value / value
  end

  defp process_message(current_value, invalid_request) do
    IO.puts("Invalid request #{inspect invalid_request}")
    current_value
  end

  # client interface
  def value(server_pid) do
    send(server_pid, {:value, self()})

    receive do
      {:response, value} ->
        value
    end
  end


  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})

end
