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

  def search_row(row, letter) do
    row
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {l, c} when l == letter -> [c]
      _ -> []
    end)
  end

  def exists?(grid, pos) do
    Map.has_key?(grid, pos)
  end

  def letter_at(grid, pos) do
    Map.get(grid, pos)
  end

  def apply_delta({r, c}, {dr, dc}) do
    {r + dr, c + dc}
  end
end

defmodule AdventOfCode.Day4 do
  alias AdventOfCode.Day4.Grid

  def parse_grid(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Grid.new()
  end

  def solve_part_1(grid) do
    grid
    |> Grid.search_all("XMAS")
    |> Enum.count()
  end

  def run() do
    grid = parse_grid("input.txt")

    IO.puts("Part 1: #{solve_part_1(grid)}")
  end
end

AdventOfCode.Day4.run()
