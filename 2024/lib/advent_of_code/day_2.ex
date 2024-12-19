defmodule AdventOfCode.Day2 do
  @behaviour AdventOfCode.Solver

  @spec safe?([integer()]) :: boolean()
  def safe?(sequence) do
    [start | rest] = sequence

    result =
      rest
      |> Enum.reduce_while({nil, start}, fn current, {direction, previous} ->
        case delta(previous, current) do
          {_, x} when x > 3 or x < 1 -> {:halt, false}
          {new_direction, _} when is_nil(direction) -> {:cont, {new_direction, current}}
          {new_direction, _} when new_direction != direction -> {:halt, false}
          {new_direction, _} -> {:cont, {new_direction, current}}
        end
      end)

    result != false
  end

  @spec without_one([integer()]) :: [[integer()]]
  def without_one(sequence) do
    0..(length(sequence) - 1)
    |> Enum.map(fn to_drop ->
      List.delete_at(sequence, to_drop)
    end)
  end

  defp delta(previous, current) do
    change = abs(current - previous)

    case current > previous do
      true -> {:increase, change}
      false -> {:decrease, change}
    end
  end

  @impl AdventOfCode.Solver
  def parse_input(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  @impl AdventOfCode.Solver
  def solve_part_1(input) do
    input
    |> Enum.count(&safe?(&1))
  end

  @impl AdventOfCode.Solver
  def solve_part_2(input) do
    input
    |> Enum.count(fn seq ->
      case AdventOfCode.Day2.safe?(seq) do
        true -> true
        # If failed, try all of the possibilities with one number removed
        false -> Enum.any?(without_one(seq), &AdventOfCode.Day2.safe?/1)
      end
    end)
  end
end
