defmodule AdventOfCode.Grid do
  @moduledoc """
  Generic module for working with grids. These are commonly used in AoC problems,
  so building now with the likelihood of this being required in the future.

  This allows grids to be used as a Cartesian plane, with the origin at the top-left
  corner of the grid, with the x-axis increasing to the right and the y-axis increasing
  downwards (note some solutions have used different orientations).

  Given that many grids typically have many empty cells, we only store the cells that
  have values using a map with the key being an {x, y} tuple. However, this is abstracted away
  from the caller.
  """
  defstruct points: %{}, max_x: 0, max_y: 0

  @type t :: %__MODULE__{
          points: %{point => any()},
          max_x: non_neg_integer(),
          max_y: non_neg_integer()
        }
  @type point :: {non_neg_integer(), non_neg_integer()}

  @directions %{
    up: {0, -1},
    down: {0, 1},
    left: {-1, 0},
    right: {1, 0},
    up_left: {-1, -1},
    up_right: {1, -1},
    down_left: {-1, 1},
    down_right: {1, 1}
  }

  @doc """
  Create a new grid from a list of lines.

  ## Options
    * `:empty_char` - The character to use to represent an empty cell (default: ".")

  """
  @spec from_lines([String.t()]) :: %__MODULE__{}
  def from_lines(lines, opts \\ []) when is_list(lines) do
    empty_char = Keyword.get(opts, :empty_char, ".")

    lines
    |> Enum.with_index()
    |> Enum.reduce(%__MODULE__{}, fn {line, y}, grid ->
      {max_x, row_values} = parse_line(line, y, empty_char)

      %__MODULE__{
        points: Map.merge(grid.points, row_values),
        max_x: max_x,
        max_y: y
      }
    end)
  end

  @doc """
  Get the value at a given point in the grid.

  If the point is outside the grid, this will return `nil`.
  """
  @spec get(%__MODULE__{}, point) :: any() | nil
  def get(%__MODULE__{points: points}, {x, y}), do: Map.get(points, {x, y})

  @doc """
  Get the dimensions of the grid.
  """
  @spec dimensions(%__MODULE__{}) :: {integer(), integer()}
  def dimensions(%__MODULE__{max_x: max_x, max_y: max_y}), do: {max_x + 1, max_y + 1}

  @doc """
  Check if a point is within the bounds of the grid.
  """
  def in_bounds?(%__MODULE__{max_x: max_x, max_y: max_y}, {x, y}) do
    x >= 0 and x <= max_x and y >= 0 and y <= max_y
  end

  @doc """
  Get the neighbours of a given point in the grid.

  This will not return neighbours that are outside the grid.
  """
  def neighbours(%__MODULE__{} = grid, {x, y}) do
    Enum.map(@directions, fn {_, direction} ->
      apply_direction({x, y}, direction)
    end)
    |> Enum.filter(&in_bounds?(grid, &1))
  end

  @doc """
  Comparator function for comparing two points.
  Points are sorted ascending by x, then by y.

  Returns true if the first point precedes or equals the second point.
  """
  def compare_points({x1, y1}, {x2, y2}) do
    dx = x1 - x2
    dy = y1 - y2

    case {dx, dy} do
      {0, 0} -> true
      {0, _} -> dy < 0
      _ -> dx < 0
    end
  end

  defp parse_line(line, y, empty_char) when is_binary(line) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce({0, %{}}, fn {cell, x}, {_max_x, points} ->
      case cell do
        ^empty_char -> {x, points}
        _ -> {x, Map.put(points, {x, y}, cell)}
      end
    end)
  end

  @doc """
  Apply a direction (dx, dy) to a point (x, y).
  """
  def apply_direction({x, y}, {dx, dy}), do: {x + dx, y + dy}

  @doc """
  Get the locations where the cell has the given value.
  """
  def locations_of(%__MODULE__{points: points}, value) do
    points
    |> Map.filter(fn {_point, cell_value} -> cell_value == value end)
    |> Map.keys()
  end

  def map(%__MODULE__{points: points} = grid, fun) do
    converted =
      Enum.map(points, fn {{x, y}, value} -> {{x, y}, fun.(value)} end)
      |> Map.new()

    %__MODULE__{grid | points: converted}
  end
end
