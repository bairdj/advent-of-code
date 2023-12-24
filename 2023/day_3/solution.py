import re
from itertools import chain

class PartNumber:
    def __init__(self, start_x: int, start_y: int, length: int):
        self.start_x = start_x
        self.start_y = start_y
        self.length = length

    def get_number(self, schematic: "EngineSchematic") -> int:
        result = schematic.get_segment(self.start_x, self.start_y, self.length)
        if result.isdigit():
            return int(result)
        raise ValueError(f"Part number {self} is not a number")
    
    def covers_cell(self, cell: (int, int)) -> bool:
        """
        Check if a cell is covered by this part number
        """
        x = cell[0]
        y = cell[1]
        if y != self.start_y:
            return False
        return x >= self.start_x and x < self.start_x + self.length


    def __repr__(self):
        return f"PartNumber(x: {self.start_x}, y: {self.start_y}, len: {self.length})"

class EngineSchematic:
    def __init__(self, schematic: str):
        self.schematic = schematic.splitlines()
        self.height = len(self.schematic)
        self.width = len(self.schematic[0])

    def get_segment(self, start_x: int, start_y: int, length: int) -> str:
        return self.schematic[start_y][start_x:start_x + length]

    def _get_possible_part_numbers(self) -> [PartNumber]:
        """
        Finds all possible part numbers in the schematic.
        Some of these may be invalid - these should be checked
        later using the logic defined in the puzzle.
        """
        part_pattern = re.compile(r"\d+")
        for i in range(self.height):
            for match in part_pattern.finditer(self.schematic[i]):
                yield PartNumber(match.start(), i, match.end() - match.start())

    def check_part_valid(self, part: PartNumber) -> bool:
        """
        Check if a PartNumber object is valid. To be valid,
        it must be adjacent to a symbol (including diagonal).
        """
        part_cells = [(part.start_x + i, part.start_y) for i in range(part.length)]
        neighbours = chain.from_iterable(self.get_cell_neighbours(cell) for cell in part_cells)
        for neighbour in neighbours:
            neighbour_value = self.get_cell_value(neighbour)
            if not neighbour_value.isdigit() and not neighbour_value == ".":
                return True


    def get_cell_neighbours(self, cell: (int, int)) -> [(int, int)]:
        """
        Get the cells adjacent to a cell, within the bounds of the schematic
        """
        x = cell[0]
        y = cell[1]
        x_neighbours = [x - 1, x, x + 1]
        y_neighbours = [y - 1, y, y + 1]
        for x in x_neighbours:
            for y in y_neighbours:
                if x >= 0 and x < self.width and y >= 0 and y < self.height:
                    yield (x, y)

    def get_cell_value(self, cell: (int, int)) -> str:
        """
        Get the value of a cell in the schematic
        """
        x = cell[0]
        y = cell[1]
        if x < 0 or x >= self.width or y < 0 or y >= self.height:
            raise ValueError(f"Cell {cell} is out of bounds")
        return self.schematic[y][x]

    def get_valid_part_numbers(self) -> [PartNumber]:
        """
        Get all valid part numbers in the schematic
        """
        return [part for part in self._get_possible_part_numbers() if self.check_part_valid(part)]

    def find_symbol(self, symbol: str) -> [(int, int)]:
        """
        Find all locations of a symbol in the schematic.
        """
        for y in range(self.height):
            for x in range(self.width):
                if self.schematic[y][x] == symbol:
                    yield (x, y)

    def solve_part_2(self) -> int:
        """
        Solve part 2 of the puzzle.
        
        This involves finding all asterixes that are adjacent
        to two valid part numbers. For these, the gear ratio is
        the product of the two part numbers. The answer is the
        sum of all gear ratios.
        """
        asterixes = list(self.find_symbol("*"))
        if len(asterixes) == 0:
            raise ValueError("No asterixes found in schematic")
        part_numbers = self.get_valid_part_numbers()
        gear_ratios = []
        for asterix in asterixes:
            adjacent_parts = set()
            for neighbour in self.get_cell_neighbours(asterix):
                adjacent = [part for part in part_numbers if part.covers_cell(neighbour)]
                adjacent_parts.update(adjacent)
                # Must be exactly 2, so if more can break early
                if len(adjacent_parts) > 2:
                    break
            if len(adjacent_parts) == 2:
                ratio = adjacent_parts.pop().get_number(self) * adjacent_parts.pop().get_number(self)
                gear_ratios.append(ratio)
        return sum(gear_ratios)





if __name__ == "__main__":
    with open("input.txt", "r") as f:
        schematic = EngineSchematic(f.read())
        parts = list(schematic.get_valid_part_numbers())
        part_1_answer = sum(part.get_number(schematic) for part in parts)
        print(f"Part 1 answer: {part_1_answer}")

        print(f"Part 2 answer: {schematic.solve_part_2()}")
    