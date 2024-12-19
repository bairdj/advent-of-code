defmodule AdventOfCode.Day8 do
  @behaviour AdventOfCode.Solver

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

  defp all_location_pairs(locations) when is_list(locations) do
    locations
    |> Enum.with_index()
    |> Enum.flat_map(fn {location_1, index_1} ->
      locations
      |> Enum.drop(index_1 + 1)
      |> Enum.map(fn location_2 ->
        [location_1, location_2]
        # Ensure consistent ordering (x then y [both ascending])
        |> Enum.sort(&AdventOfCode.Grid.compare_points/2)
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
    AdventOfCode.Grid.apply_direction(loc_1, delta)
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
      |> AdventOfCode.Grid.from_lines()

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
    |> Enum.filter(&AdventOfCode.Grid.in_bounds?(grid, &1))
    |> Enum.count()
  end

  @impl AdventOfCode.Solver
  def solve_part_2(_) do
    raise "Not implemented"
  end
end
