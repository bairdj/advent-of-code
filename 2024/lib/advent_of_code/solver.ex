defmodule AdventOfCode.Solver do
  @type puzzle_input :: any()
  @doc """
  Parse the input file and return a data structure designed to be passed to the
  part 1 and part 2 solvers.
  """
  @callback parse_input(path :: String.t()) :: puzzle_input

  @doc """
  Solve part 1 of the puzzle.
  """
  @callback solve_part_1(puzzle_input) :: integer()

  @doc """
  Solve part 2 of the puzzle.
  """
  @callback solve_part_2(puzzle_input) :: integer()
end
