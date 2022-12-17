import os
input_file = os.path.join(os.path.dirname(__file__), 'input.txt')

# File is a single line
with open(input_file, 'r') as f:
    # Read first 4 characters
    buffer = f.read(4)
    while True:
        # Check number of unique characters
        if len(set(buffer)) == 4:
            print(f'Unique sequence ends at {f.tell()}')
            exit()
        # Read next character
        buffer = buffer[1:] + f.read(1)