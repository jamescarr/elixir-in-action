defmodule Todo.CacheTest do
  use ExUnit.Case

  setup_all do
    pid = Supervisor.start_link([Todo.Cache], strategy: :one_for_one)
    {:ok, supervisor: pid}
  end


  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end


  test "Todo operations" do
    alice = Todo.Cache.server_process("alice")
    Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "dentist"})

    entries = Todo.Server.entries(alice, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "dentist", id: 1}] == entries
  end

  test "returns the same pid for a todo list each time" do
    bob = Todo.Cache.server_process("bob")
    bob_again = Todo.Cache.server_process("bob")
    alice = Todo.Cache.server_process("alice")

    assert bob == bob_again
    assert alice != bob
  end
end
