import re
import os
from typing import List, Callable

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

    def process_round(self):
        thrown_items = {}
        # If monkey has no items, return
        if not self.items:
            return thrown_items
        for item in self.items:
            self.inspection_count += 1
            # Initial worry level
            worry_level = self.operation(item.worry_level)
            # Divide worry level by 3 using int division
            worry_level //= 3
            # Update item worry level
            item.worry_level = worry_level
            throw_to = self.throw_true if worry_level % self.test == 0 else self.throw_false
            if throw_to not in thrown_items:
                thrown_items[throw_to] = [item]
            else:
                thrown_items[throw_to].append(item)
        self.items = []
        return thrown_items

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

# Create dictionary of monkeys with ID as key
monkeys = {}

# Read input file
input_path = os.path.join(os.path.dirname(__file__), 'input.txt')

monkey_pattern = re.compile(r'Monkey (\d+):\n\s+Starting items: ([\d, ]+)\n\s+Operation: new = (.*)\n\s+Test: divisible by (\d+)\n\s+If true: throw to monkey (\d+)\n\s+If false: throw to monkey (\d+)')

with open(input_path, 'r') as input_file:
    # Find all monkey_pattern matches in input file
    monkeys = {monkey.id: monkey for monkey in (Monkey.from_match(match) for match in monkey_pattern.finditer(input_file.read()))}

rounds = 20
for round in range(rounds):
    # Process each monkey
    for monkey in monkeys.values():
        thrown_items = monkey.process_round()
        if thrown_items:
            for monkey_id, items in thrown_items.items():
                monkeys[monkey_id].items.extend(items)

# Get the top 2 monkeys by inspection count
top_monkeys = sorted(monkeys.values(), key=lambda monkey: monkey.inspection_count, reverse=True)[:2]
# Multiply the inspection counts of the top 2 monkeys
print(top_monkeys[0].inspection_count * top_monkeys[1].inspection_count)