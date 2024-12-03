defmodule AdventOfCode.Day3 do
  @mul_pattern ~r/mul\((\d+),(\d+)\)/

  @spec extract_mul(String.t()) :: [{integer(), integer()}]
  def extract_mul(string) do
    Regex.scan(@mul_pattern, string)
    |> Enum.map(fn [_, a, b] -> {String.to_integer(a), String.to_integer(b)} end)
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

  def run do
    input = File.read!("input.txt")

    IO.puts("Part 1: #{solve_part_1(input)}")
  end
end

AdventOfCode.Day3.run()
