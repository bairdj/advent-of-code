import os
# Rucksack stores an array of items
# Each item is represented by a character (case sensitive)
# The first 1/2 of the items are in compartment 1
# The second 1/2 of the items are in compartment 2
class Rucksack:
    def __init__(self, items):
        self.items = items

    @property
    def num_items(self):
        return len(self.items)

    @property
    def compartment_1(self):
        return self.items[:self.num_items // 2]

    @property
    def compartment_2(self):
        return self.items[self.num_items // 2:]

    # Items that are in both compartments
    # Return only unique items
    @property
    def common_items(self):
        return list(set(self.compartment_1).intersection(set(self.compartment_2)))


# Map item priorities
# a-z = 1:26
# A-Z = 27:52
item_priorities = {}
for i in range(1, 27):
    item_priorities[chr(i + 96)] = i
for i in range(1, 27):
    item_priorities[chr(i + 64)] = i + 26

# Read rucksack items from input file
input_path = os.path.join(os.path.dirname(__file__), 'input.txt')

priority_sum = 0
with open(input_path, 'r') as f:
    for line in f:
        rucksack = Rucksack(line.strip())
        # Find the common item (by definition should only be 1)
        common_items = rucksack.common_items
        if len(common_items) != 1:
            raise Exception('There should only be 1 common item')
        common_item = common_items[0]
        priority_sum += item_priorities[common_item]

print(f"Priority sum of common items: {priority_sum}")

# Part 2
part_2_sum = 0
with open(input_path, 'r') as f:
    # Read in sets of 3 lines
    while True:
        i = 0
        group_rucksacks = []
        while i < 3:
            line = f.readline()
            # EOF
            if not line:
                break
            group_rucksacks.append(Rucksack(line.strip()))
            i += 1
        if len(group_rucksacks) == 0:
            break
        # Find intersection of all 3 rucksacks
        # There should only be 1 common item
        common_items = set.intersection(*[set(r.items) for r in group_rucksacks])
        if len(common_items) != 1:
            raise Exception('There should only be 1 common item')
        common_item = common_items.pop()
        part_2_sum += item_priorities[common_item]

print(f"Sum of group priorities: {part_2_sum}")

        
        