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

  @doc """
  Reorder an update so that all rules are met.
  """
  @spec reorder_update([Rule.t()], [integer()]) :: [integer()]
  def reorder_update(rules, update) when is_list(rules) and is_list(update) do
    rule_map = as_rule_map(rules)
    Enum.sort(update, fn a, b -> compare_elements(a, b, rule_map) end)
  end

  def compare_elements(a, b, rule_map) do
    {smaller, larger} = if a < b, do: {a, b}, else: {b, a}

    # Return true if a precedes b
    # Returns false if b precedes a
    case Map.get(rule_map, {smaller, larger}) do
      # No rule - consider them equal
      nil -> true
      # Smaller before larger, therefore true if a is smaller
      :lt -> smaller == a
      # Larger before smaller, therefore true if a is larger
      :gt -> larger == a
    end
  end

  @doc """
  Converts a list of rules into a map for faster lookup. The key is a tuple
  of form {smaller, larger} and the value is either :lt or :gt.
  """
  def as_rule_map(rules) do
    rules
    |> Enum.map(fn %__MODULE__{pre: pre, post: post} ->
      case {pre, post} do
        {a, b} when a < b -> {{a, b}, :lt}
        {a, b} when a > b -> {{b, a}, :gt}
        _ -> raise "Invalid rule"
      end
    end)
    |> Enum.into(%{})
  end
end

defmodule AdventOfCode.Day5 do
  @behaviour AdventOfCode.Solver
  alias AdventOfCode.Day5.Rule

  @impl AdventOfCode.Solver
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

  @impl AdventOfCode.Solver
  def solve_part_1({rules, updates}) do
    updates
    |> Enum.filter(&Rule.update_valid?(rules, &1))
    |> Enum.map(&Rule.middle_value/1)
    |> Enum.sum()
  end

  @impl AdventOfCode.Solver
  def solve_part_2({rules, updates}) do
    updates
    |> Enum.filter(fn update -> not Rule.update_valid?(rules, update) end)
    |> Enum.map(fn update ->
      Rule.reorder_update(rules, update)
    end)
    |> Enum.map(&Rule.middle_value/1)
    |> Enum.sum()
  end
end
