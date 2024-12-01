defmodule AdventOfCode.Day6.Race do
  defstruct [:duration, :record]

  def distance_travelled(%__MODULE__{duration: duration}, charge_time)
      when charge_time > duration,
      do: 0

  def distance_travelled(_, 0), do: 0

  def distance_travelled(%__MODULE__{duration: duration}, charge_time) do
    speed = charge_time
    travel_duration = duration - charge_time
    speed * travel_duration
  end

  def find_winning_charges(%__MODULE__{duration: duration} = race) do
    0..duration
    |> Enum.filter(fn charge_time -> distance_travelled(race, charge_time) > race.record end)
  end

  def count_winning_charges(%__MODULE__{} = race) do
    race
    |> find_winning_charges()
    |> Enum.count()
  end

  @doc """
  d = distance, t = duration, c = charge

  d = c * (t - c)

  Rearrange as quadratic equation:
  c^2 - t * c + d = 0

  Solve for c using quadratic formula: ax^2 + bx + c = 0
  """
  def solve_for_charge(%__MODULE__{duration: duration, record: record}) do
    a = 1
    b = -duration
    c = record

    x1 = (-b + :math.sqrt(:math.pow(b, 2) - 4 * a * c)) / (2 * a)
    x2 = (-b - :math.sqrt(:math.pow(b, 2) - 4 * a * c)) / (2 * a)

    {x1, x2}
  end
end

defmodule AdventOfCode.Day6.Solution do
  alias AdventOfCode.Day6.Race
  @line_pattern ~r/\:(.+)$/

  def parse_input(path) do
    File.read!(path)
    |> String.split("\n", trim: true, parts: 2)
    |> Enum.map(&parse_line/1)
    |> Enum.zip()
  end

  defp parse_line(line) do
    [_, data] = Regex.run(@line_pattern, line)

    data
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_input_part_2(path) do
    File.read!(path)
    |> String.split("\n")
    # Select all digits in the line and condense them
    |> Enum.map(fn line ->
      Regex.scan(~r/\d+/, line)
      |> Enum.join()
      |> String.to_integer()
    end)
  end

  def run(path) do
    races =
      parse_input(path)
      |> Enum.map(fn {duration, record} ->
        %Race{duration: duration, record: record}
      end)

    # Part 1: count winning charges per race and multiply them
    part_1_answer =
      races
      |> Enum.map(&Race.count_winning_charges/1)
      |> Enum.reduce(&Kernel.*/2)

    IO.puts("Part 1: #{part_1_answer}")

    [race_2_time, race_2_distance] =
      parse_input_part_2(path)

    [min_solved, max_solved] =
      %Race{duration: race_2_time, record: race_2_distance}
      |> Race.solve_for_charge()
      |> Tuple.to_list()
      |> Enum.sort()

    part_2_solutions = :math.floor(max_solved) - :math.ceil(min_solved) + 1

    IO.puts("Part 2: #{part_2_solutions}")
  end
end

AdventOfCode.Day6.Solution.run("input.txt")
