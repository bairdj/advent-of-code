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
  end
end

AdventOfCode.Day6.Solution.run("input.txt")
