defmodule AdventOfCode.Day7 do
  @behaviour AdventOfCode.Solver
  @operators [
    &(&1 + &2),
    &(&1 * &2)
  ]

  @part_2_operators [
    &(&1 + &2),
    &(&1 * &2),
    &AdventOfCode.Day7.concat_integers/2
  ]

  def valid_equation?(%{result: result, inputs: inputs}, operators \\ @operators) do
    inputs
    |> build_candidate_tree(operators)
    |> resolve_candidate()
    |> Enum.find(&(&1 == result)) != nil
  end

  def build_candidate_tree(inputs, operators \\ @operators)

  def build_candidate_tree([last], _) do
    last
  end

  def build_candidate_tree([head | rest], operators) do
    Enum.map(operators, fn op ->
      {head, op, build_candidate_tree(rest, operators)}
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

  def concat_integers(a, b) when is_integer(a) and is_integer(b) do
    String.to_integer("#{a}#{b}")
  end

  @impl AdventOfCode.Solver
  def parse_input(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [result, inputs] = String.split(line, ": ", trim: true)

    inputs_numeric =
      inputs
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    %{
      result: String.to_integer(result),
      inputs: inputs_numeric
    }
  end

  @impl AdventOfCode.Solver
  def solve_part_1(input) do
    input
    |> Enum.filter(&valid_equation?/1)
    |> Enum.map(& &1.result)
    |> Enum.sum()
  end

  @impl AdventOfCode.Solver
  def solve_part_2(input) do
    input
    |> Enum.filter(&valid_equation?(&1, @part_2_operators))
    |> Enum.map(& &1.result)
    |> Enum.sum()
  end
end
