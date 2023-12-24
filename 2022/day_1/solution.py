import os
input_path = 'input.txt'
# Convert to absolute path
input_path = os.path.join(os.path.dirname(__file__), input_path)

class Food:
    def __init__(self, calories):
        self.calories = calories

class Elf:
    def __init__(self, number):
        self.food = []
        self.number = number

    def add_food(self, food):
        self.food.append(food)

    def total_calories(self):
        return sum([f.calories for f in self.food])

    def total_food(self):
        return len(self.food)

    def __str__(self):
        return f'Elf {self.number} has {self.total_food()} food with {self.total_calories()} calories'

elves = []
# Read file line-by-line
# Empty line is a new elf
with open(input_path, 'r') as f:
    elf_sequence = 1
    elf = Elf(elf_sequence)
    for line in f:
        if line == '' or line == '\n':
            elves.append(elf)
            elf_sequence += 1
            elf = Elf(elf_sequence)
        else:
            food = Food(int(line))
            elf.add_food(food)
    # Add last elf
    elves.append(elf)

# Find elf with most calories
max_elf = max(elves, key=lambda elf: elf.total_calories())

print("Elf with most calories:")
print(max_elf)

# Get the top 3 elves with most calories
top_elves = sorted(elves, key=lambda elf: elf.total_calories(), reverse=True)[:3]
# Get the sum of calories from top_elves
total_calories = sum([elf.total_calories() for elf in top_elves])
print(f'Total calories from top 3 elves: {total_calories}')