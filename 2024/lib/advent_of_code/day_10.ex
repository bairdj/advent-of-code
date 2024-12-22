defmodule AdventOfCode.Day10 do
  @behaviour AdventOfCode.Solver
  alias AdventOfCode.Grid

  @directions [
    {:up, {0, -1}},
    {:down, {0, 1}},
    {:left, {-1, 0}},
    {:right, {1, 0}}
  ]

  @goal_value 9

  def search_path(%Grid{} = grid, visited, location, destination) do
    cell_value = Grid.get(grid, location)

    cond do
      is_nil(cell_value) ->
        nil

      not_sequential_value?(cell_value, visited) ->
        nil

      already_visited?(location, visited) ->
        nil

      cell_value == destination ->
        Enum.reverse([{cell_value, location} | visited])

      true ->
        search_neighbours(grid, visited, location, cell_value, destination)
    end
  end

  defp not_sequential_value?(current_value, [{last_value, _} | _]) do
    current_value - last_value != 1
  end

  defp not_sequential_value?(_, []), do: false

  defp already_visited?(location, visited) do
    Enum.any?(visited, fn {_value, prev_location} -> prev_location == location end)
  end

  defp search_neighbours(grid, visited, location, cell_value, destination) do
    @directions
    |> Enum.map(fn {_, delta} ->
      new_location = Grid.apply_direction(location, delta)

      search_path(grid, [{cell_value, location} | visited], new_location, destination)
    end)
    # Reject any that have returned nil
    |> Enum.reject(&is_nil/1)
  end

  @impl AdventOfCode.Solver
  def parse_input(path) do
    File.read!(path)
    |> String.split("\n")
    |> Grid.from_lines()
    |> Grid.map(&String.to_integer/1)
  end

  @impl AdventOfCode.Solver
  def solve_part_1(grid) do
    trailheads = Grid.locations_of(grid, 0)

    trailheads
    |> Enum.map(fn trailhead ->
      search_path(grid, [], trailhead, @goal_value)
      |> List.flatten()
      |> Enum.filter(fn {val, _} -> val == @goal_value end)
      |> Enum.uniq_by(fn {_, location} -> location end)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  @impl AdventOfCode.Solver
  def solve_part_2(_grid) do
    raise "Not implemented"
  end
end
