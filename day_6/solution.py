import os
input_file = os.path.join(os.path.dirname(__file__), 'input.txt')

def find_unique_sequence(f, length):
    buffer = f.read(length)
    if buffer == '':
        return None
    while True:
        if len(set(buffer)) == length:
            return f.tell()
        buffer = buffer[1:] + f.read(1)

# File is a single line
with open(input_file, 'r') as f:
    part_1 = find_unique_sequence(f, 4)
    f.seek(0)
    part_2 = find_unique_sequence(f, 14)

print(f'Part 1: {part_1}')
print(f'Part 2: {part_2}')