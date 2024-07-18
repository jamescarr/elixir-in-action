defmodule TodoTest do
  use ExUnit.Case
  doctest TodoList

  test "shows entries on date provided" do
    todo_list = TodoList.new() |>
      TodoList.add_entry(%{date: ~D[2023-12-19], title: "Dentist"}) |>
      TodoList.add_entry(%{date: ~D[2023-12-19], title: "Movies"})

    expected = [
      %{id: 1, date: ~D[2023-12-19], title: "Dentist"},
      %{id: 2, date: ~D[2023-12-19], title: "Movies"}
    ]
    assert expected == TodoList.entries(todo_list, ~D[2023-12-19])

  end

  test "Returns empty list for no detail for date" do
    todo_list = TodoList.new() |>
      TodoList.add_entry(%{date: ~D[2023-12-19], title: "Dentist"}) |>
      TodoList.add_entry(%{date: ~D[2023-12-19], title: "Movies"})

    assert [] == TodoList.entries(todo_list, ~D[2023-12-20])
  end

  test "Update behavior when entry exists" do
    todo_list = TodoList.new() |>
      TodoList.add_entry(%{date: ~D[2023-12-19], title: "Dentist"})

    updated = TodoList.update_entry(todo_list, 1, fn entry ->  Map.put(entry, :title, "Endodontist") end)

    assert "Endodontist" == Enum.at(TodoList.entries(updated, ~D[2023-12-19]), 0).title
  end

  test "deletes entry by id when present" do
    expected = [
      %{id: 2, date: ~D[2023-12-19], title: "Movies"}
    ]
    todo_list = TodoList.new() |>
      TodoList.add_entry(%{date: ~D[2023-12-19], title: "Dentist"}) |>
      TodoList.add_entry(%{date: ~D[2023-12-19], title: "Movies"})


    todo_list = TodoList.delete_entry(todo_list, 1)

    assert expected == TodoList.entries(todo_list, ~D[2023-12-19])

  end

  test "add multiple entries at once" do
    entries = [
      %{date: ~D[2023-12-19], title: "Dentist"},
      %{date: ~D[2023-12-20], title: "Shopping"},
      %{date: ~D[2023-12-19], title: "Movies"}
    ]

    todo_list = TodoList.new(entries)

    assert 2 == length(TodoList.entries(todo_list, ~D[2023-12-19]))
    assert 1 == length(TodoList.entries(todo_list, ~D[2023-12-20]))
    assert 0 == length(TodoList.entries(todo_list, ~D[2023-12-21]))
  end

  test "Import from csv" do
    todo_list = TodoList.CsvImporter.import("todos.csv")

    entries = TodoList.entries(todo_list, ~D[2023-02-20])

    assert 1 == length(entries)
    assert "Shopping" == Enum.at(entries, 0).title

  end
end
