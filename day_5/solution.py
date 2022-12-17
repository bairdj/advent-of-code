import os
import re
import copy
class Environment:
    def __init__(self, n_stacks, debug=False):
        self.stacks = [[] for _ in range(n_stacks)]
        self.debug = debug

    # Add crate to bottom of stack
    # Used for initialisation as file is read from top to bottom
    def add_to_bottom(self, stack: int, crate: int):
        self.stacks[stack].insert(0, crate)

    def move(self, from_stack: int, to_stack: int, n: int):
        # Move crates one by one
        # Take crate from top of stack and add to top of other stack
        i = 0
        while i < n:
            # Will raise IndexError if stack is empty
            crate_to_move = self.stacks[from_stack].pop()
            if self.debug:
                print(f'Moving {crate_to_move} from stack {from_stack} to stack {to_stack}')
            self.stacks[to_stack].append(crate_to_move)
            i += 1

    # Allow moving a stack of crates in one go
    def move_stack(self, from_stack: int, to_stack: int, n: int):
        # Crates to move
        crates_to_move = self.stacks[from_stack][-n:]
        # Remove crates from stack
        self.stacks[from_stack] = self.stacks[from_stack][:-n]
        # Append crates to other stack
        self.stacks[to_stack].extend(crates_to_move)

    # Don't actually need this for AOC just for testing
    def pretty_print(self):
        # Get the maximum stack height
        max_height = max([len(stack) for stack in self.stacks])
        i = max_height
        while i >= 0:
            # Join stack elements at this height together
            stack_row = ''.join([f'[{stack[i]}]' if i < len(stack) else '   ' for stack in self.stacks])
            print(stack_row)
            i -= 1
        # Horizontal line
        print('-' * (len(self.stacks) * 3))
        # Print stack numbers
        print(''.join([f' {i} ' for i in range(len(self.stacks))]))

    @property
    def top_stacks(self) -> str:
        # Get the top elements of each stack
        return ''.join([stack[-1] if len(stack) > 0 else ' ' for stack in self.stacks])


input_file = os.path.join(os.path.dirname(__file__), 'input.txt')

with open(input_file, 'r') as f:
    # Get width of first line to determine number of stacks
    n_stacks = len(f.readline()) // 4
    environment = Environment(n_stacks)
    f.seek(0)
    for line in f:
        # Check if stack labels have been reached. Line starts with 1
        if line[1] == '1':
            break
        # Split line into n_stacks
        stack_elements = [line[i:i+3] for i in range(0, len(line), 4)]
        for stack_index, stack_element in enumerate(stack_elements):
            # Check there is a crate here (index 1 is where it should be)
            if stack_element[1] == ' ':
                continue
            # Add to bottom of stack
            environment.add_to_bottom(stack_index, stack_element[1])

    # Skip blank line before moves
    next(f)
    environment.pretty_print()
    # Clone environment for part 2
    environment_2 = copy.deepcopy(environment)

    # Start parsing moves
    move_pattern = re.compile(r'move (\d+) from (\d+) to (\d+)')
    for line in f:
        # Get move parameters
        move = move_pattern.match(line)
        n, from_stack, to_stack = [int(i) for i in move.groups()]
        # Moves are 1-indexed
        from_stack -= 1
        to_stack -= 1
        environment.move(from_stack, to_stack, n)
        environment_2.move_stack(from_stack, to_stack, n)
        
    print("Part 1:")
    environment.pretty_print()
    print(f"Top of stacks: {environment.top_stacks}")
    print("Part 2:")
    environment_2.pretty_print()
    print(f"Top of stacks: {environment_2.top_stacks}")