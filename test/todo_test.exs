defmodule TodoTest do
  use ExUnit.Case
  doctest Todo.List

  test "shows entries on date provided" do
    todo_list = Todo.List.new() |>
      Todo.List.add_entry(%{date: ~D[2023-12-19], title: "Dentist"}) |>
      Todo.List.add_entry(%{date: ~D[2023-12-19], title: "Movies"})

    expected = [
      %{id: 1, date: ~D[2023-12-19], title: "Dentist"},
      %{id: 2, date: ~D[2023-12-19], title: "Movies"}
    ]
    assert expected == Todo.List.entries(todo_list, ~D[2023-12-19])

  end

  test "Returns empty list for no detail for date" do
    todo_list = Todo.List.new() |>
      Todo.List.add_entry(%{date: ~D[2023-12-19], title: "Dentist"}) |>
      Todo.List.add_entry(%{date: ~D[2023-12-19], title: "Movies"})

    assert [] == Todo.List.entries(todo_list, ~D[2023-12-20])
  end

  test "Update behavior when entry exists" do
    todo_list = Todo.List.new() |>
      Todo.List.add_entry(%{date: ~D[2023-12-19], title: "Dentist"})

    updated = Todo.List.update_entry(todo_list, 1, fn entry ->  Map.put(entry, :title, "Endodontist") end)

    assert "Endodontist" == Enum.at(Todo.List.entries(updated, ~D[2023-12-19]), 0).title
  end

  test "deletes entry by id when present" do
    expected = [
      %{id: 2, date: ~D[2023-12-19], title: "Movies"}
    ]
    todo_list = Todo.List.new() |>
      Todo.List.add_entry(%{date: ~D[2023-12-19], title: "Dentist"}) |>
      Todo.List.add_entry(%{date: ~D[2023-12-19], title: "Movies"})


    todo_list = Todo.List.delete_entry(todo_list, 1)

    assert expected == Todo.List.entries(todo_list, ~D[2023-12-19])

  end

  test "add multiple entries at once" do
    entries = [
      %{date: ~D[2023-12-19], title: "Dentist"},
      %{date: ~D[2023-12-20], title: "Shopping"},
      %{date: ~D[2023-12-19], title: "Movies"}
    ]

    todo_list = Todo.List.new(entries)

    assert 2 == length(Todo.List.entries(todo_list, ~D[2023-12-19]))
    assert 1 == length(Todo.List.entries(todo_list, ~D[2023-12-20]))
    assert 0 == length(Todo.List.entries(todo_list, ~D[2023-12-21]))
  end

end
