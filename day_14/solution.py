from typing import Tuple, List, Optional
import os


class Coordinate:
    def __init__(self, x: int, y: int):
        self.x = x
        self.y = y

    def __repr__(self):
        return f"({self.x}, {self.y})"

class Line:
    def __init__(self, origin: Coordinate, destination: Coordinate):
        self.origin = origin
        self.destination = destination

    def cells_covered(self) -> List[Coordinate]:
        # Vertical line
        if self.origin.x == self.destination.x:
            min_y = min(self.origin.y, self.destination.y)
            max_y = max(self.origin.y, self.destination.y)
            return [Coordinate(self.origin.x, y) for y in range(min_y, max_y + 1)]
        # Horizontal line
        if self.origin.y == self.destination.y:
            min_x = min(self.origin.x, self.destination.x)
            max_x = max(self.origin.x, self.destination.x)
            return [Coordinate(x, self.origin.y) for x in range(min_x, max_x + 1)]
        raise Exception("Line is not horizontal or vertical")

    def __repr__(self):
        return f"{self.origin}->{self.destination}"


class Cave:
    pour_position = Coordinate(500, 0)

    def __init__(self, lines):
        # Get all x and y coordinates
        all_coordinates = [line.origin for line in lines] + [line.destination for line in lines]
        self.min_x = min([coordinate.x for coordinate in all_coordinates])
        max_x = max([coordinate.x for coordinate in all_coordinates])
        # Pad by 1 on each side to detect the abyss
        self.min_x -= 1
        max_x += 1
        width = max_x - self.min_x + 1
        # Y coordinates are inverse i.e. 0 is at the top, 1 is below that
        max_y = max([coordinate.y for coordinate in all_coordinates])
        height = max_y + 1
        self.grid = [['.' for _ in range(width)] for _ in range(height)]
        for line in lines:
            for coordinate in line.cells_covered():
                self.grid[coordinate.y][coordinate.x - self.min_x] = '#'
        # Set pour position in grid
        self.grid[self.pour_position.y][self.pour_position.x - self.min_x] = '+'

        
    def pretty_print(self):
        """
        Pretty prints the cave.
        Includes row numbers.
        Print column numbers vertically above.
        """
        col_numbers = [self.min_x + i for i in range(len(self.grid[0]))]
        # Get the max number of digits in the column numbers
        max_digits = len(str(max(col_numbers)))
        # Print column numbers vertically
        column_strings = [''.join([str(col_number)[i] for col_number in col_numbers]) for i in range(max_digits)]
        for row in column_strings:
            print(f"{' ' * 3} {row}")
        for i, row in enumerate(self.grid):
            print(f"{i:3d} {''.join(row)}")

    
    def pour(self) -> bool:
        current_drop = Cave.pour_position
        while True:
            self[current_drop] = '~'
            below_coordinate = Coordinate(current_drop.x, current_drop.y + 1)
            below = self[below_coordinate]
            if below == '.' or below == '~':
                current_drop = below_coordinate
                continue
            if below is None:
                return False
            # Check left diagonal
            left_diagonal_coordinate = Coordinate(current_drop.x - 1, current_drop.y + 1)
            left_diagonal = self[left_diagonal_coordinate]
            if left_diagonal == '.' or left_diagonal == '~':
                current_drop = left_diagonal_coordinate
                continue
            if left_diagonal is None:
                return False
            right_diagonal_coordinate = Coordinate(current_drop.x + 1, current_drop.y + 1)
            right_diagonal = self[right_diagonal_coordinate]
            if right_diagonal == '.' or right_diagonal == '~':
                current_drop = right_diagonal_coordinate
                continue
            if right_diagonal is None:
                return False
            # All possible paths are blocked. Block this cell
            self[current_drop] = 'o'
            return True

    
    def pour_n(self, n: int):
        for pours in range(n):
            result = self.pour()
            if not result:
                return pours
        return None


    def __getitem__(self, coordinate: Coordinate) -> Optional[str]:
        if not self.coordinate_exists(coordinate):
            return None
        return self.grid[coordinate.y][coordinate.x - self.min_x]


    def __setitem__(self, coordinate: Coordinate, value: str):
        if not self.coordinate_exists(coordinate):
            raise Exception(f"Coordinate {coordinate} does not exist")
        self.grid[coordinate.y][coordinate.x - self.min_x] = value


    def coordinate_exists(self, coordinate: Coordinate) -> bool:
        if coordinate.y < 0:
            return False
        if coordinate.y >= len(self.grid):
            return False
        if coordinate.x < self.min_x:
            return False
        if coordinate.x >= self.min_x + len(self.grid[0]):
            return False
        return True



input_path = os.path.join(os.path.dirname(__file__), 'input.txt')

lines = []
with open(input_path, 'r') as f:
    for line in f:
        previous_coordinate = None
        coordinates = line.split('->')
        for coordinate in coordinates:
            coordinate = coordinate.strip()
            x, y = coordinate.split(',')
            x = int(x)
            y = int(y)
            if previous_coordinate is None:
                previous_coordinate = Coordinate(x, y)
            else:
                line = Line(previous_coordinate, Coordinate(x, y))
                lines.append(line)
                previous_coordinate = Coordinate(x, y)


cave = Cave(lines)
cave.pretty_print()

poured = 0
while True:
    result = cave.pour()
    if not result:
        break
    poured += 1
print(f"Poured {poured} times before reaching the abyss")

cave.pretty_print()