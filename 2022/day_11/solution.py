import re
import os
from typing import List, Callable
import copy

class Item:
    def __init__(self, worry_level: int):
        self.worry_level = worry_level

class Monkey:
    def __init__(self, id, items: list[Item], operation: Callable[[int], int], test: int, throw_true: int, throw_false: int):
        self.id = id
        self.items = items
        self.operation = operation
        self.test = test
        self.throw_true = throw_true
        self.throw_false = throw_false
        self.inspection_count = 0

    def add_item(self, item: Item):
        self.items.append(item)

    def process_round(self, other_monkeys, modulo = None):
        # If monkey has no items, return
        if not self.items:
            return
        for item in self.items:
            self.inspection_count += 1
            # Initial worry level
            worry_level = self.operation(item.worry_level)
            if not modulo:
                # Divide worry level by 3 using int division
                worry_level //= 3
            else:
                worry_level %= modulo
            # Update item worry level
            item.worry_level = worry_level
            throw_to = self.throw_true if worry_level % self.test == 0 else self.throw_false
            other_monkeys[throw_to].add_item(item)
        self.items = []
        return

    def __str__(self):
        items = ', '.join(str(item.worry_level) for item in self.items)
        return f"Monkey {self.id}: {items}"


    # Static constructor method from match object
    @staticmethod
    def from_match(match):
        monkey_id = int(match.group(1))
        items = [Item(int(item)) for item in match.group(2).split(', ')]
        # Parse the operation into a lambda function
        operation = eval(f"lambda old: {match.group(3)}")
        monkey = Monkey(monkey_id, items, operation, int(match.group(4)), int(match.group(5)), int(match.group(6)))
        return monkey


def calculate_monkey_business(monkeys):
    # Get the top 2 monkeys by inspection count
    top_monkeys = sorted(monkeys.values(), key=lambda monkey: monkey.inspection_count, reverse=True)[:2]
    # Multiply the inspection counts of the top 2 monkeys
    return top_monkeys[0].inspection_count * top_monkeys[1].inspection_count


# Create dictionary of monkeys with ID as key
monkeys = {}

# Read input file
input_path = os.path.join(os.path.dirname(__file__), 'input.txt')

monkey_pattern = re.compile(r'Monkey (\d+):\n\s+Starting items: ([\d, ]+)\n\s+Operation: new = (.*)\n\s+Test: divisible by (\d+)\n\s+If true: throw to monkey (\d+)\n\s+If false: throw to monkey (\d+)')

with open(input_path, 'r') as input_file:
    # Find all monkey_pattern matches in input file
    monkeys = {monkey.id: monkey for monkey in (Monkey.from_match(match) for match in monkey_pattern.finditer(input_file.read()))}

# Copy initial monkey state
monkeys_part_1 = copy.deepcopy(monkeys)
monkeys_part_2 = copy.deepcopy(monkeys)

rounds = 20
for round in range(rounds):
    # Process each monkey
    for monkey in monkeys_part_1.values():
        monkey.process_round(monkeys_part_1)

part_1_answer = calculate_monkey_business(monkeys_part_1)

# Part 2
rounds = 10000
for round in range(rounds):
    # Use modular arithmetic trick (from Reddit)
    # Get common denominator of all test values
    common_denominator = 1
    for monkey in monkeys_part_2.values():
        common_denominator *= monkey.test
    
    # Process each monkey
    for monkey in monkeys_part_2.values():
        monkey.process_round(monkeys_part_2, modulo=common_denominator)

part_2_answer = calculate_monkey_business(monkeys_part_2)

print(f"Part 1: {part_1_answer}")
print(f"Part 2: {part_2_answer}")