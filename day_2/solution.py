import os
# Define rock paper scissors moves
# Each class should implement comparison operators
# Each class also has a static score attribute

class Rock:
    score = 1
    def __gt__(self, other):
        return isinstance(other, Scissors)

    def __lt__(self, other):
        return isinstance(other, Paper)

    def __eq__(self, other):
        return isinstance(other, Rock)

class Paper:
    score = 2
    def __gt__(self, other):
        return isinstance(other, Rock)

    def __lt__(self, other):
        return isinstance(other, Scissors)

    def __eq__(self, other):
        return isinstance(other, Paper)

class Scissors:
    score = 3
    def __gt__(self, other):
        return isinstance(other, Paper)

    def __lt__(self, other):
        return isinstance(other, Rock)

    def __eq__(self, other):
        return isinstance(other, Scissors)

move_library = [Rock(), Paper(), Scissors()]

# Map elf codes to moves
elf_moves = {
    'A': Rock(),
    'B': Paper(),
    'C': Scissors()
}

your_moves = {
    'Y': Paper(),
    'X': Rock(),
    'Z': Scissors()
}

# Read elf moves and your moves from input file
input_path = os.path.join(os.path.dirname(__file__), 'input.txt')

# Read line-by-line
# First letter is elf move
# Second letter is your move
total_score = 0
with open(input_path, 'r') as f:
    for line in f:
        elf_move = elf_moves[line[0]]
        your_move = your_moves[line[2]]
        # Default match score is zero. This is score for a loss
        match_score = 0
        if elf_move == your_move:
            match_score = 3
        elif your_move > elf_move:
            match_score = 6
        game_score = match_score + your_move.score
        total_score += game_score

print(f'Total score: {total_score}')
        
# Part 2
your_results = {
    'X': 'lose',
    'Y': 'draw',
    'Z': 'win'
}

def get_move_from_result(opponent_move, result):
    possible_moves = []
    if result == 'win':
        possible_moves = [move for move in move_library if move > opponent_move]
    elif result == 'lose':
        possible_moves = [move for move in move_library if move < opponent_move]
    elif result == 'draw':
        possible_moves = [move for move in move_library if move == opponent_move]
    if len(possible_moves) == 1:
        return possible_moves[0]
    else:
        return None


total_score_2 = 0
with open(input_path, 'r') as f:
    for line in f:
        elf_move = elf_moves[line[0]]
        # Get the specified result and find the move that
        # would result in that outcome in light of the elf's move
        your_result = your_results[line[2]]
        your_move = get_move_from_result(elf_move, your_result)
        match_score = 0
        if your_result == 'draw':
            match_score = 3
        elif your_result == 'win':
            match_score = 6
        game_score = match_score + your_move.score
        total_score_2 += game_score

print(f'Total score 2: {total_score_2}')
        
