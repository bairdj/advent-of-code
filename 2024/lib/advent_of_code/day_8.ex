defmodule AdventOfCode.Day8 do
  @behaviour AdventOfCode.Solver
  alias AdventOfCode.Grid

  @doc """
  Determine the location of antinodes for a given set of locations. This
  assumes that you have already filtered these to be of the same frequency.
  """
  def build_antinodes(locations) do
    locations
    |> all_location_pairs()
    |> Enum.flat_map(fn {loc_1, loc_2} ->
      [get_antinode(loc_1, loc_2), get_antinode(loc_2, loc_1)]
    end)
  end

  def build_antinodes_part_2(locations, grid) do
    locations
    |> all_location_pairs()
    |> Enum.flat_map(fn {loc_1, loc_2} ->
      # The difference to part 1 is that the same logic applies but it loops
      # adding antinodes until we hit the edge of the grid instead of just 1
      dir_1 = apply_until_edge(loc_1, location_delta(loc_1, loc_2), grid)
      dir_2 = apply_until_edge(loc_2, location_delta(loc_2, loc_1), grid)
      dir_1 ++ dir_2
    end)
  end

  defp all_location_pairs(locations) when is_list(locations) do
    locations
    |> Enum.with_index()
    |> Enum.flat_map(fn {location_1, index_1} ->
      locations
      |> Enum.drop(index_1 + 1)
      |> Enum.map(fn location_2 ->
        [location_1, location_2]
        # Ensure consistent ordering (x then y [both ascending])
        |> Enum.sort(&Grid.compare_points/2)
        |> List.to_tuple()
      end)
    end)
  end

  defp location_delta({x1, y1}, {x2, y2}) do
    {x2 - x1, y2 - y1}
  end

  defp invert_delta({dx, dy}) do
    {-dx, -dy}
  end

  # Call again in other direction to get the other antinode
  defp get_antinode(loc_1, loc_2) do
    delta = location_delta(loc_1, loc_2) |> invert_delta()
    Grid.apply_direction(loc_1, delta)
  end

  defp apply_until_edge(location, delta, grid) do
    case Grid.in_bounds?(grid, location) do
      true ->
        [
          location
          | apply_until_edge(Grid.apply_direction(location, delta), delta, grid)
        ]

      false ->
        []
    end
  end

  defp build_frequencies(points) do
    points
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Map.new()
  end

  @impl AdventOfCode.Solver
  def parse_input(path) do
    grid =
      File.read!(path)
      |> String.split("\n")
      |> Grid.from_lines()

    # Rearrange the points map to be grouped by value (as we will be doing pairwise stuff)
    frequencies = build_frequencies(grid.points)

    {grid, frequencies}
  end

  @impl AdventOfCode.Solver
  def solve_part_1({grid, frequencies}) do
    # For each frequency, build a list of antinodes
    frequencies
    |> Enum.flat_map(fn {_, locations} ->
      build_antinodes(locations)
    end)
    # Deduplicate
    |> MapSet.new()
    # Filter out any antinodes that are outside the grid
    |> Enum.filter(&Grid.in_bounds?(grid, &1))
    |> Enum.count()
  end

  @impl AdventOfCode.Solver
  def solve_part_2({grid, frequencies}) do
    frequencies
    |> Enum.flat_map(fn {_, locations} ->
      build_antinodes_part_2(locations, grid)
    end)
    |> MapSet.new()
    |> Enum.count()
  end
end
