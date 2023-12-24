import re

class GameSet:
    SET_PATTERN = re.compile(r"(\d+) (\w+)")

    def __init__(self):
        self.colours = {}

    def add_colour(self, colour: str, n: int):
        self.colours[colour] = n

    def __repr__(self):
        return str(self.colours)
    
    @staticmethod
    def from_set_string(set_string: str) -> "GameSet":
        game_set = GameSet()
        for set_match in GameSet.SET_PATTERN.finditer(set_string):
            game_set.add_colour(set_match.group(2), int(set_match.group(1)))
        return game_set



class Game:
    GAME_PATTERN = re.compile(r"^Game (\d+):(.*)$")
    def __init__(self, id: int, sets: [GameSet]):
        self.id = id
        self.sets = sets

    @staticmethod
    def from_line(line: str) -> "Game":
        match = Game.GAME_PATTERN.match(line)
        if match is None:
            raise ValueError("Line does not match game pattern.")
        game_id = int(match.group(1))
        # Split the sets by semicolon
        set_strings = match.group(2).split(";")
        sets = [GameSet.from_set_string(set_string) for set_string in set_strings]
        return Game(game_id, sets)

    def __repr__(self):
        return f"Game {self.id}: {self.sets}"

    def check_colour_n(self, colour: str, n: int) -> bool:
        """
        Checks that no set contains > n of the given colour.
        """
        for game_set in self.sets:
            if colour in game_set.colours and game_set.colours[colour] > n:
                return False
        return True

    def check_multiple_colours(self, colours: {str: int}) -> bool:
        """
        Checks that no set contains > n of any of the given colours.
        
        colours: a dictionary mapping colours to the maximum number of
        cubes of that colour that can be in a set.
        """
        for colour, n in colours.items():
            if not self.check_colour_n(colour, n):
                return False
        return True



def solve(puzzle_input: [str]) -> int:
    games = [Game.from_line(line) for line in puzzle_input]
    # Need to know which games are possible if the bag only
    # contained 12 red cubes, 13 green cubes and 14 blue cubes
    colours = {"red": 12, "green": 13, "blue": 14}
    possible_games = [game for game in games if game.check_multiple_colours(colours)]
    return sum(game.id for game in possible_games)

if __name__ == "__main__":
    with open("input.txt", "r", encoding="utf-8") as f:
        puzzle_input = [line.strip() for line in f.readlines()]
        print(solve(puzzle_input))
