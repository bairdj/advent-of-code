defmodule AdventOfCode.Day7 do
  @operators [
    &(&1+&2),
    &(&1*&2)
  ]

  def valid_equation?(%{result: result, inputs: inputs}) do
    inputs
    |> build_candidate_tree()
    |> resolve_candidate()
    |> Enum.find(&(&1 == result)) != nil
  end

  def build_candidate_tree([last]) do
    last
  end

  def build_candidate_tree([head | rest]) do
    Enum.map(@operators, fn op ->
      {head, op, build_candidate_tree(rest)}
    end)
  end

  def resolve_candidate({lhs, op, rhs}) when is_integer(rhs) do
    [op.(lhs, rhs)]
  end

  def resolve_candidate({lhs, op, rhs}) when is_list(rhs) do
    Enum.flat_map(rhs, fn {current_rhs, next_op, next_rhs} ->
      intermediate = op.(lhs, current_rhs)
      resolve_candidate({intermediate, next_op, next_rhs})
    end)
  end

  def resolve_candidate(candidates) when is_list(candidates) do
    candidates
    |> Enum.flat_map(&resolve_candidate/1)
  end

  def parse_input(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [result, inputs] = String.split(line, ": ", trim: true)
    inputs_numeric = inputs
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)

    %{
      result: String.to_integer(result),
      inputs: inputs_numeric
    }
  end

  def solve_part_1(input) do
    input
    |> Enum.filter(&valid_equation?/1)
    |> IO.inspect()
    |> Enum.map(&(&1.result))

    |> Enum.sum()
  end

  def run() do
    input = parse_input("input.txt")

    IO.puts("Part 1: #{solve_part_1(input)}")

  end

end

AdventOfCode.Day7.run()
