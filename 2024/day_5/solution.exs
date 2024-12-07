defmodule AdventOfCode.Day5.Rule do
  @type t :: %__MODULE__{pre: integer(), post: integer()}

  defstruct [:pre, :post]

  def new(pre, post) when is_integer(pre) and is_integer(post) do
    %__MODULE__{pre: pre, post: post}
  end

  @spec rule_met?(Rule.t(), [integer()]) :: boolean()
  def rule_met?(%__MODULE__{pre: pre, post: post}, update) when is_list(update) do
    case {Enum.find_index(update, &(&1 == pre)), Enum.find_index(update, &(&1 == post))} do
      {nil, _} -> true
      {_, nil} -> true
      {pre_index, post_index} when pre_index < post_index -> true
      _ -> false
    end
  end

  def update_valid?(rules, update) do
    Enum.all?(rules, &rule_met?(&1, update))
  end

  def middle_value(list) do
    split = div(Enum.count(list), 2)
    Enum.at(list, split)
  end
end

defmodule AdventOfCode.Day5.Solver do
  alias AdventOfCode.Day5.Rule

  def parse_input(path) do
    [rule_block, update_block] =
      path
      |> File.read!()
      |> String.split("\n\n")

    rules =
      rule_block
      |> String.split("\n")
      |> Enum.map(&parse_rule/1)

    updates =
      update_block
      |> String.split("\n")
      |> Enum.map(&parse_update/1)

    {rules, updates}
  end

  defp parse_rule(line) do
    [pre, post] = String.split(line, "|")
    Rule.new(String.to_integer(pre), String.to_integer(post))
  end

  defp parse_update(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def solve_part_1(rules, updates) do
    updates
    |> Enum.filter(&Rule.update_valid?(rules, &1))
    |> Enum.map(&Rule.middle_value/1)
    |> Enum.sum()
  end

  def run do
    {rules, updates} = parse_input("input.txt")

    IO.puts("Part 1: #{solve_part_1(rules, updates)}")
  end
end

AdventOfCode.Day5.Solver.run()
