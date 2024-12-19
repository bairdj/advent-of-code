defmodule AdventOfCode.Day3 do
  @behaviour AdventOfCode.Solver

  @mul_pattern ~r/mul\((\d+),(\d+)\)/
  @do_pattern ~r/do\(\)/
  @dont_pattern ~r/don't\(\)/

  @spec extract_mul(String.t()) :: [{integer(), integer()}]
  def extract_mul(string) do
    Regex.scan(@mul_pattern, string)
    |> Enum.map(fn [_, a, b] -> {String.to_integer(a), String.to_integer(b)} end)
  end

  def extract_mul_conditional("", _), do: []

  def extract_mul_conditional(string, :enabled) do
    case Regex.split(@dont_pattern, string, parts: 2) do
      [to_parse, rest] ->
        extract_mul(to_parse) ++ extract_mul_conditional(rest, :disabled)

      [to_parse] ->
        extract_mul(to_parse)
    end
  end

  def extract_mul_conditional(string, :disabled) do
    case Regex.split(@do_pattern, string, parts: 2) do
      [_, rest] ->
        extract_mul_conditional(rest, :enabled)

      [to_parse] ->
        extract_mul(to_parse)
    end
  end

  def eval_mul({a, b}) do
    a * b
  end

  @impl AdventOfCode.Solver
  def parse_input(path) do
    File.read!(path)
  end

  @impl AdventOfCode.Solver
  def solve_part_1(input) do
    input
    |> extract_mul()
    |> Enum.map(&eval_mul/1)
    |> Enum.sum()
  end

  @impl AdventOfCode.Solver
  def solve_part_2(input) do
    input
    |> extract_mul_conditional(:enabled)
    |> Enum.map(&eval_mul/1)
    |> Enum.sum()
  end
end
