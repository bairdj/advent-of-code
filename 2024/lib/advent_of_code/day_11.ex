defmodule AdventOfCode.Day11 do
  @behaviour AdventOfCode.Solver

  def blink_n(stones, n) when is_list(stones) and is_integer(n) do
    0..(n - 1)
    |> Enum.reduce(stones, fn _, acc -> blink_stones(acc) end)
  end

  def blink_stones(stones) when is_list(stones) do
    stones
    |> Enum.flat_map(&blink_stone/1)
  end

  def blink_stone(0), do: [1]

  def blink_stone(n) when is_integer(n) do
    cond do
      even_digits?(n) ->
        split_digits(n)

      true ->
        [n * 2024]
    end
  end

  defp n_digits(n) when is_integer(n) do
    Integer.digits(n)
    |> Enum.count()
  end

  defp even_digits?(n) when is_integer(n) do
    n_digits(n) |> rem(2) == 0
  end

  defp split_digits(n) when is_integer(n) do
    digits = Integer.digits(n)
    n_digits = Enum.count(digits)

    {half_1, half_2} = Enum.split(digits, div(n_digits, 2))

    [Enum.join(half_1), Enum.join(half_2)]
    |> Enum.map(&String.to_integer/1)
  end

  @impl AdventOfCode.Solver
  def parse_input(path) do
    File.read!(path)
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  @impl AdventOfCode.Solver
  def solve_part_1(stones) do
    stones
    |> blink_n(25)
    |> Enum.count()
  end

  @impl AdventOfCode.Solver
  def solve_part_2(stones) do
    raise "Not implemented"
  end
end
