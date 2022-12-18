import os
from functools import reduce

class Grid:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.grid = [[0 for _ in range(height)] for _ in range(width)]

    def __getitem__(self, item):
        x = item[0]
        y = item[1]
        return self.grid[x][y]

    def __setitem__(self, key, value):
        x = key[0]
        y = key[1]
        self.grid[x][y] = value

    def pretty_print(self):
        for y in range(self.height):
            for x in range(self.width):
                print(self.grid[x][y], end='')
            print()


class GridSolver:
    def __init__(self, grid):
        self.grid = grid

    # Candidates are those that are not in the outside border
    def get_candidates(self):
        candidates = []
        for y in range(1, self.grid.height - 1):
            for x in range(1, self.grid.width - 1):
                candidates.append((x, y))
        return candidates

    def move_and_check_invisibility(self, x: int, y: int, dx: int, dy: int, height: int) -> bool:
        # New coordinate
        x += dx
        y += dy
        new_value = self.grid[x, y]
        # Is visible if new_value is lower than height
        invisible = new_value >= height
        # Check if an edge has been reached
        if x == 0 or x == self.grid.width - 1 or y == 0 or y == self.grid.height - 1:
            return invisible
        # If invisible, don't need to check further
        if invisible:
            return invisible
        # If not visible, check next cell
        return self.move_and_check_invisibility(x, y, dx, dy, height)

    def solve(self):
        candidates = self.get_candidates()
        visible_trees = []
        # All trees on edge are visible
        for x in range(self.grid.width):
            visible_trees.append((x, 0))
            visible_trees.append((x, self.grid.height - 1))
        for y in range(self.grid.height):
            # Don't add corners twice
            if y == 0 or y == self.grid.height - 1:
                continue
            visible_trees.append((0, y))
            visible_trees.append((self.grid.width - 1, y))
        invisible_trees = []
        for x, y in candidates:
            tree_height = self.grid[x, y]
            # Check visibility left, right, up, down
            moves = [(-1, 0), (1, 0), (0, -1), (0, 1)]
            visibilities = [self.move_and_check_invisibility(x, y, dx, dy, tree_height) for dx, dy in moves]
            # Tree is invisible if all visibilities are False
            invisible = all(visibilities)
            if invisible:
                invisible_trees.append((x, y))
            else:
                visible_trees.append((x, y))
        return {'visible': visible_trees, 'invisible': invisible_trees}

    # For part 2
    # Move and accumulate the number of cells that are lower than height
    # Stop when an edge is reached or a cell >= height is reached
    def move_until_height(self, x: int, y: int, dx: int, dy: int, height: int) -> int:
        # New coordinate
        x += dx
        y += dy
        new_value = self.grid[x, y]
        if new_value < height:
            # Check if an edge has been reached
            if x == 0 or x == self.grid.width - 1 or y == 0 or y == self.grid.height - 1:
                return 1
            return 1 + self.move_until_height(x, y, dx, dy, height)
        return 1

    def solve_part_2(self):
        candidates = self.get_candidates()
        # Calculate scenic score for each candidate
        scenic_scores = []
        for x, y in candidates:
            height = self.grid[x, y]
            moves = [(-1, 0), (1, 0), (0, -1), (0, 1)]
            scores = [self.move_until_height(x, y, dx, dy, height) for dx, dy in moves]
            # Multiply all scores
            scenic_score = reduce(lambda x, y: x * y, scores)
            scenic_scores.append((x, y, scenic_score))
        # Find the maximum scenic score
        max_score = max(scenic_scores, key=lambda x: x[2])
        return max_score

    

input_file = os.path.join(os.path.dirname(__file__), 'input.txt')

with open(input_file, 'r') as f:
    lines = f.readlines()
    # Get dimensions of grid
    width = len(lines[0].strip())
    height = len(lines)
    grid = Grid(width, height)
    for y, line in enumerate(lines):
        
        for x, value in enumerate(line):
            if value == '\n':
                continue
            grid[x, y] = int(value)

grid.pretty_print()

solver = GridSolver(grid)
tree_visibility = solver.solve()
# Print number of visible and invisible trees
print(f"Visible trees: {len(tree_visibility['visible'])}")
print(f"Invisible trees: {len(tree_visibility['invisible'])}")
print()
print("Part 2:")
max_score = solver.solve_part_2()
print(f"Max score: {max_score[2]} at ({max_score[0]}, {max_score[1]})")