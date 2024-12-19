defmodule Mix.Tasks.Solve do
  @moduledoc """
  Run the solution for a given day.

  ## Examples

      mix solve 1 input/day_1.txt
  """
  use Mix.Task

  @impl Mix.Task
  def run([day, input_path]) do
    module = String.to_atom("Elixir.AdventOfCode.Day#{day}")

    input = module.parse_input(input_path)
    IO.puts("Part 1 answer: #{module.solve_part_1(input)}")
    IO.puts("Part 2 answer: #{module.solve_part_2(input)}")
  end
end
