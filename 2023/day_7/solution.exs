defmodule AdventOfCode.Day7 do
  @card_strength ~w(2 3 4 5 6 7 8 9 T J Q K A)
  @type_patterns [
    {:five_of_a_kind, [5]},
    {:four_of_a_kind, [1, 4]},
    {:full_house, [2, 3]},
    {:three_of_a_kind, [1, 1, 3]},
    {:two_pair, [1, 2, 2]},
    {:one_pair, [1, 1, 1, 2]},
    {:high_card, [1, 1, 1, 1, 1]}
  ]

  def compare_cards(card_1, card_2) when card_1 == card_2, do: true
  def compare_cards(card_1, card_2), do: card_strength(card_1) >= card_strength(card_2)

  def compare_types(type_1, type_2) when type_1 == type_2, do: true
  def compare_types(type_1, type_2), do: type_strength(type_1) >= type_strength(type_2)

  def hand_type(hand) do
    frequencies = hand_frequency(hand)

    Enum.find_value(@type_patterns, fn {type, pattern} ->
      if frequencies == pattern, do: type
    end)
  end

  @doc """
  Compare two hands of cards. This is intended to be used in a sort function.

  The cards are first compared by type.
  If this is equal, the order of the cards is compared on a card by card basis.
  """
  def compare_hands(hand_1, hand_2) do
    case {hand_type(hand_1), hand_type(hand_2)} do
      {same, same} -> compare_cards_in_order(hand_1, hand_2)
      {type_1, type_2} -> compare_types(type_1, type_2)
    end
  end

  def compare_cards_in_order([card_1 | rest_1], [card_2 | rest_2]) do
    case {card_1, card_2} do
      {same, same} -> compare_cards_in_order(rest_1, rest_2)
      {card_1, card_2} -> compare_cards(card_1, card_2)
    end
  end

  def compare_cards_in_order([], []), do: false

  def hand_frequency(hand) do
    hand
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort()
  end

  defp card_strength(card), do: Enum.find_index(@card_strength, &(&1 == card))

  defp type_strength(type) do
    @type_patterns
    |> Enum.reverse()
    |> Enum.find_index(fn {t, _} -> t == type end)
  end

  def parse_input(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.map(&parse_hand/1)
  end

  defp parse_hand(hand) do
    [cards, bid] = String.split(hand, " ", parts: 2)
    {String.graphemes(cards), String.to_integer(bid)}
  end

  def solve_part_1(input) do
    input
    |> Enum.sort(fn {hand_1, _}, {hand_2, _} -> compare_hands(hand_1, hand_2) end)
    # Put lowest rankings first
    |> Enum.reverse()
    |> Enum.with_index(1)
    # Value is rank * bid
    |> Enum.map(fn {{_, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  def run do
    input = parse_input("input.txt")

    IO.puts("Part 1: #{solve_part_1(input)}")
  end
end

AdventOfCode.Day7.run()
