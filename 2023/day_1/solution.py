import re

def process_line_part_1(line: str) -> int:
    """
    Extract the first and last digit in a line of text,
    and return them as a combined integer.
    """
    pattern = re.compile(r"\d")
    matches = pattern.findall(line)
    if len(matches) == 0:
        raise ValueError("No digits found in line.")
    return int(matches[0] + matches[-1])


def process_file(path: str) -> int:
    with open(path, "r") as f:
        lines = [process_line_part_1(line) for line in f.readlines()]
    return sum(lines)

if __name__ == "__main__":
    print(f"Part 1 answer: {process_file('input.txt')}")
