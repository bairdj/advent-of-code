import re

class Game:
    GAME_PATTERN = re.compile(r"Card\s+(\d+): (.*) \| (.*)$")

    def __init__(self, winning_numbers: [int], selected_numbers: [int]):
        self.winning_numbers: set = set(winning_numbers)
        self.selected_numbers: set = set(selected_numbers)

    def get_winners(self) -> [int]:
        return self.winning_numbers.intersection(self.selected_numbers)

    def get_score(self) -> int:
        """
        Return the number of points earned in this game. The first winning
        number is worth 1 point, then subsequent winners are worth double
        the previous winner.
        """
        n_winners = len(self.get_winners())
        if n_winners == 0:
            return 0
        score = 1
        for _ in range(1, n_winners):
            score *= 2
        return score

    @classmethod
    def from_line(cls, line: str) -> "Game":
        match = cls.GAME_PATTERN.match(line)
        if match is None:
            raise ValueError(f"Invalid game line: {line}")
        winning_numbers = [int(x.strip()) for x in match.group(2).split()]
        selected_numbers = [int(x.strip()) for x in match.group(3).split()]
        return cls(winning_numbers, selected_numbers)
    
if __name__ == "__main__":
    with open("input.txt", "r") as f:
        games = [Game.from_line(line) for line in f.readlines()]
        scores = [game.get_score() for game in games]
        print(f"Part 1 answer: {sum(scores)}")
