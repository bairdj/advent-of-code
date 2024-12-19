defmodule AdventOfCode.Day4.Grid do
  @moduledoc """
  Utility methods for working with a grid of letters for a word search.

  The grid is represented as a list of a list of characters. The first
  axis is the row, and the second axis is the column. To avoid ambiguity,
  the row axis is referred to as `r` and the column axis is referred to as `c`.
  Coordinates should be given as `{r, c}` tuples.
  """
  @deltas [
    {0, 1},
    {1, 0},
    {1, 1},
    {1, -1},
    {0, -1},
    {-1, 0},
    {-1, -1},
    {-1, 1}
  ]

  @diag_deltas %{
    ul: {-1, -1},
    ur: {-1, 1},
    dl: {1, -1},
    dr: {1, 1}
  }

  def new(grid) do
    grid
    |> Enum.with_index()
    |> Enum.flat_map(fn {row_contents, r} ->
      row_contents
      |> Enum.with_index()
      |> Enum.map(fn {letter, c} -> {{r, c}, letter} end)
    end)
    |> Enum.into(%{})
  end

  def search_all(%{} = grid, word) do
    # Find starting positions
    search_letter(grid, String.at(word, 0))
    |> Enum.flat_map(fn start ->
      Enum.map(@deltas, fn delta ->
        {start, delta}
      end)
    end)
    |> Enum.map(fn {start, delta} ->
      search(grid, start, word, delta)
    end)
    |> Enum.filter(fn result -> Enum.count(result) == String.length(word) end)
  end

  def search(_, start, "", _), do: [start]

  def search(grid, start, word, delta) do
    next_pos = apply_delta(start, delta)

    case {String.at(word, 1), letter_at(grid, next_pos)} do
      {nil, _} ->
        [start]

      {_, nil} ->
        []

      {letter, letter} ->
        [start | search(grid, next_pos, String.slice(word, 1..-1//1), delta)]

      _ ->
        []
    end
  end

  def search_letter(%{} = grid, letter) do
    grid
    |> Enum.flat_map(fn
      {pos, l} when l == letter -> [pos]
      _ -> []
    end)
  end

  def letter_at(grid, pos) do
    Map.get(grid, pos)
  end

  def apply_delta({r, c}, {dr, dc}) do
    {r + dr, c + dc}
  end

  @doc """
  An X-MAS is a cross symbol made up of two diagonal lines with letters MAS
  intersecting at the middle. The SAMs can be in any direction. The A is
  always the intersection. Therefore, we can search for finding A and then
  checking if any of the neighbours have the correct pattern.
  """
  def xmas?(grid, a_position) do
    diagonal_neighbours(grid, a_position)
    |> diagonal_xmas?()
  end

  defp diagonal_neighbours(grid, pos) do
    @diag_deltas
    |> Enum.map(fn {label, delta} -> {label, letter_at(grid, apply_delta(pos, delta))} end)
    |> Enum.into(%{})
  end

  defp diagonal_xmas?(%{} = neighbours) do
    diagonal_pair_valid?(neighbours.ul, neighbours.dr) and
      diagonal_pair_valid?(neighbours.ur, neighbours.dl)
  end

  defp diagonal_pair_valid?("M", "S"), do: true
  defp diagonal_pair_valid?("S", "M"), do: true
  defp diagonal_pair_valid?(_, _), do: false
end

defmodule AdventOfCode.Day4 do
  @behaviour AdventOfCode.Solver
  alias AdventOfCode.Day4.Grid

  @impl AdventOfCode.Solver
  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Grid.new()
  end

  @impl AdventOfCode.Solver
  def solve_part_1(grid) do
    grid
    |> Grid.search_all("XMAS")
    |> Enum.count()
  end

  @impl AdventOfCode.Solver
  def solve_part_2(grid) do
    grid
    |> Grid.search_letter("A")
    |> Enum.count(fn pos -> Grid.xmas?(grid, pos) end)
  end
end
