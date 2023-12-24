import os

# Expand the section representation to a set of all sections
# E.g. 1-4 becomes {1, 2, 3, 4}
def expand_section(section):
    start, end = section.split('-')
    return set(range(int(start), int(end) + 1))

input_file = os.path.join(os.path.dirname(__file__), 'input.txt')

subset_count = 0
overlap_count = 0
with open(input_file, 'r') as f:
    for line in f:
        # Get expanded sections for each elf
        # Elves are separated by a comma
        sections = [expand_section(section) for section in line.split(',')]
        if sections[0].issubset(sections[1]):
            subset_count += 1
        elif sections[1].issubset(sections[0]):
            subset_count += 1
        # Check for overlap between sections
        if len(sections[0].intersection(sections[1])) > 0:
            overlap_count += 1

print(f'Number of subsets: {subset_count}')
print(f'Number of overlaps: {overlap_count}')