defmodule AdventOfCode.Day6.PatrolMap do
  @typedoc """
  A struct representing a patrol map. At each
  location, an obstruction may or may not be present.

  Coordinates are represented as {x, y}, where the x
  axis is the horizontal axis of the puzzle input and
  the y axis is the vertical axis. The coordinate {0, 0}
  represents the BOTTOM LEFT corner of the map (note that this
  means the puzzle input gets flipped vertically). This is to
  make it easier to reason about the map in the more conventional
  Cartesian coordinate system.
  """
  @type t :: %__MODULE__{
          map: map(),
          guard_start: {integer(), integer()}
        }

  defstruct [:map, :guard_start]

  @spec from_input([String.t()]) :: t
  def from_input(input) do
    base_map =
      input
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        String.graphemes(row)
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          case char do
            "#" -> {{x, y}, :obstructed}
            "^" -> {{x, y}, :guard}
            _ -> {{x, y}, :clear}
          end
        end)
      end)

    # Flip the y axis
    max_y = Enum.map(base_map, fn {{_, y}, _} -> y end) |> Enum.max()

    flipped_map =
      base_map
      |> Enum.map(fn {{x, y}, value} -> {{x, max_y - y}, value} end)
      |> Enum.into(%{})

    # Find and clean the guard start position
    {guard_coord, _} = Enum.find(flipped_map, fn {{_, _}, value} -> value == :guard end)
    cleaned_map = Map.put(flipped_map, guard_coord, :clear)

    %__MODULE__{
      map: cleaned_map,
      guard_start: guard_coord
    }
  end

  def value_at(%__MODULE__{map: map}, {x, y}) do
    Map.get(map, {x, y}, nil)
  end

  def bounds(%__MODULE__{map: map}) do
    max_x = Enum.max_by(map, fn {{x, _}, _} -> x end)
    max_y = Enum.max_by(map, fn {{_, y}, _} -> y end)

    {{0, 0}, {max_x, max_y}}
  end
end

defmodule AdventOfCode.Day6.GuardState do
  alias AdventOfCode.Day6.PatrolMap

  @type t :: %__MODULE__{
          map: PatrolMap.t(),
          position: {integer(), integer()} | nil,
          direction: :up | :down | :left | :right
        }

  defstruct [:map, :position, :direction]

  def advance(%__MODULE__{map: map, position: position, direction: direction} = state) do
    next_position = next_position(position, direction)

    case PatrolMap.value_at(map, next_position) do
      :obstructed -> Map.put(state, :direction, turn(direction))
      # Including going off the map
      _ -> Map.put(state, :position, next_position)
    end
  end

  @doc """
  Continues advancing until the provided cell value is reached. This returns
  a set of the visited locations.
  """
  def advance_until(%__MODULE__{} = state, target_value, visited_locations) do
    case PatrolMap.value_at(state.map, state.position) do
      ^target_value ->
        visited_locations

      _ ->
        visited_locations = MapSet.put(visited_locations, state.position)
        new_state = advance(state)
        advance_until(new_state, target_value, visited_locations)
    end
  end

  def next_position({x, y}, :up) do
    {x, y + 1}
  end

  def next_position({x, y}, :down) do
    {x, y - 1}
  end

  def next_position({x, y}, :left) do
    {x - 1, y}
  end

  def next_position({x, y}, :right) do
    {x + 1, y}
  end

  def turn(:up), do: :right
  def turn(:right), do: :down
  def turn(:down), do: :left
  def turn(:left), do: :up
end

defmodule AdventOfCode.Day6.Solver do
  alias AdventOfCode.Day6.{GuardState, PatrolMap}

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> PatrolMap.from_input()
  end

  def solve_part_1(%PatrolMap{} = map) do
    state = %GuardState{
      map: map,
      position: map.guard_start,
      direction: :up
    }

    GuardState.advance_until(state, nil, MapSet.new())
    |> MapSet.size()
  end

  def run() do
    input = parse_input("input.txt")

    IO.puts("Part 1: #{solve_part_1(input)}")
  end
end

AdventOfCode.Day6.Solver.run()
