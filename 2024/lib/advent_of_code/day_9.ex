defmodule AdventOfCode.Day9.Chunk do
  defstruct [:type, :size, :id]

  @type t :: %__MODULE__{
          type: :file | :free,
          size: integer(),
          id: integer() | nil
        }

  def to_string(%__MODULE__{type: type, size: size, id: id}) do
    case type do
      :free -> String.duplicate(".", size)
      :file -> String.duplicate("#{id}", size)
    end
  end

  def combine_blocks(chunks) when is_list(chunks) do
    chunks
    |> Enum.flat_map(&as_block/1)
  end

  def as_block(%__MODULE__{type: :free, size: size}) do
    repeat_n(size, nil)
  end

  def as_block(%__MODULE__{type: :file, size: size, id: id}) do
    repeat_n(size, id)
  end

  defp repeat_n(0, _), do: []

  defp repeat_n(n, value) when n > 0 do
    0..(n - 1)
    |> Enum.map(fn _ -> value end)
  end

  @spec solve([integer() | nil]) :: [integer() | nil]
  def solve(blocks) when is_list(blocks) do
    solve(blocks, [])
  end

  def solve([], acc), do: Enum.reverse(acc)

  def solve([val | rest], acc) when is_integer(val) do
    solve(rest, [val | acc])
  end

  def solve([nil | rest], acc) do
    case last_non_nil_index(rest) do
      nil ->
        Enum.reverse(acc)

      {val, index} ->
        acc = [val | acc]
        rest = List.replace_at(rest, index, nil)
        solve(rest, acc)
    end
  end

  defp last_non_nil_index([]), do: nil

  defp last_non_nil_index(blocks) do
    blocks
    |> Enum.with_index()
    |> Enum.reverse()
    |> Enum.find(fn {val, _} -> is_integer(val) end)
  end

  @doc "Calculate the checksum of a sequence of blocks"
  def checksum(blocks) do
    blocks
    |> Enum.with_index()
    |> Enum.map(fn {val, index} ->
      case val do
        nil -> 0
        _ -> val * index
      end
    end)
    |> Enum.sum()
  end
end

defmodule AdventOfCode.Day9 do
  @behaviour AdventOfCode.Solver
  alias AdventOfCode.Day9.Chunk

  @impl AdventOfCode.Solver
  def parse_input(path) do
    File.read!(path)
    |> String.graphemes()
    |> Enum.reduce({:file, [], 0}, fn digit, {mode, parsed_data, file_id} ->
      chunk = %Chunk{
        type: mode,
        size: String.to_integer(digit),
        id: calculate_file_id(mode, file_id)
      }

      case mode do
        :file -> {:free, [chunk | parsed_data], file_id + 1}
        :free -> {:file, [chunk | parsed_data], file_id}
      end
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  @impl AdventOfCode.Solver
  def solve_part_1(input) do
    input
    |> Chunk.combine_blocks()
    |> Chunk.solve()
    |> Chunk.checksum()
  end

  @impl AdventOfCode.Solver
  def solve_part_2(_input) do
    raise "Not implemented"
  end

  defp calculate_file_id(:file, file_id), do: file_id
  defp calculate_file_id(_, _), do: nil
end
