defmodule AdventOfCode.Day3 do
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
      [to_parse, rest] ->
        extract_mul_conditional(rest, :enabled)

      [to_parse] ->
        extract_mul(to_parse)
    end
  end

  def eval_mul({a, b}) do
    a * b
  end

  def solve_part_1(input) do
    input
    |> extract_mul()
    |> Enum.map(&eval_mul/1)
    |> Enum.sum()
  end

  def solve_part_2(input) do
    input
    |> extract_mul_conditional(:enabled)
    |> Enum.map(&eval_mul/1)
    |> Enum.sum()
  end

  def run do
    input = File.read!("input.txt")

    IO.puts("Part 1: #{solve_part_1(input)}")
    IO.puts("Part 2: #{solve_part_2(input)}")
  end
end

AdventOfCode.Day3.run()
