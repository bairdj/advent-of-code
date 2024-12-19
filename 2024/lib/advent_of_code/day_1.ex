defmodule AdventOfCode.Day1 do
  @behaviour AdventOfCode.Solver

  @impl AdventOfCode.Solver
  def parse_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_line/1)
    |> Enum.unzip()
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(~r/\s+/, parts: 2)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  @impl AdventOfCode.Solver
  def solve_part_1({lhs, rhs}) do
    Enum.zip(Enum.sort(lhs), Enum.sort(rhs))
    |> Enum.map(fn {l, r} -> abs(l - r) end)
    |> Enum.sum()
  end

  @impl AdventOfCode.Solver
  def solve_part_2({lhs, rhs}) do
    # Cache RHS counts
    rhs_counts = rhs |> Enum.frequencies()

    lhs
    |> Enum.map(fn x ->
      x * Map.get(rhs_counts, x, 0)
    end)
    |> Enum.sum()
  end
end
