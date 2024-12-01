defmodule AdventOfCode.Day5.Range do
  defstruct [:source_start, :offset, :length]

  def new(source_start, destination_start, length) do
    %__MODULE__{
      source_start: source_start,
      offset: destination_start - source_start,
      length: length
    }
  end

  def get(%__MODULE__{source_start: start, length: length}, key)
      when key < start or key >= start + length,
      do: nil

  def get(%__MODULE__{source_start: start, offset: offset}, key) do
    key + offset
  end
end

defmodule AdventOfCode.Day5.Mapping do
  defstruct [:from, :to, :ranges]
  alias AdventOfCode.Day5.Range

  def new(from, to, ranges) do
    %__MODULE__{from: from, to: to, ranges: ranges}
  end

  def get(%__MODULE__{ranges: ranges}, key) do
    Enum.find_value(ranges, key, &Range.get(&1, key))
  end
end

defmodule AdventOfCode.Day5 do
  @mapping_regex ~r/^(?<from>[[:alpha:]]+)-to-(?<to>[[:alpha:]]+) map:$/
  alias AdventOfCode.Day5.Mapping
  alias AdventOfCode.Day5.Range

  def build_id_mapping({destination_start, source_start, length}) do
    [source_start, destination_start]
    |> Enum.map(&build_range(&1, length))
    |> Enum.zip()
    |> Enum.into(%{})
  end

  defp build_range(start, length) do
    start..(start + length - 1)
  end

  defp parse_seeds("seeds: " <> seed_ids) do
    seed_ids
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_block(block) do
    [labels | ids] = String.split(block, "\n")

    label_address =
      Regex.named_captures(@mapping_regex, labels)

    mapped_ids =
      ids
      |> Enum.map(&parse_id_line/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(fn {destination, source, length} ->
        Range.new(source, destination, length)
      end)

    AdventOfCode.Day5.Mapping.new(
      label_address["from"],
      label_address["to"],
      mapped_ids
    )
  end

  defp search_paths(mapping, source_type, source_id, destination_type) do
    # This is slow because it's searching the mapping each time, could convert
    # this to something smarter
    case Enum.find(mapping, &(&1.from == source_type)) do
      nil ->
        IO.puts("No mapping found for #{source_type}")
        nil

      matched_map when matched_map.to == destination_type ->
        Mapping.get(matched_map, source_id)

      matched_map ->
        search_paths(
          mapping,
          matched_map.to,
          Mapping.get(matched_map, source_id),
          destination_type
        )
    end
  end

  defp parse_id_line("") do
    nil
  end

  defp parse_id_line(line) do
    [source, destination, length] =
      String.split(line, " ", parts: 3)
      |> Enum.map(&String.to_integer/1)

    {source, destination, length}
  end

  defp parse_input(path) do
    [seeds | map_blocks] =
      File.read!(path)
      |> String.split("\n\n", trim: true)

    seed_ids = parse_seeds(seeds)
    maps = Enum.map(map_blocks, &parse_block/1)

    %{
      seed_ids: seed_ids,
      maps: maps
    }
  end

  def run do
    input = parse_input("input.txt")

    # Find the destination paths for each of the seeds, then pick the lowest
    destinations =
      input.seed_ids
      |> Enum.map(&search_paths(input.maps, "seed", &1, "location"))

    IO.puts("Part 1 solution: #{Enum.min(destinations)}")
  end
end

AdventOfCode.Day5.run()
