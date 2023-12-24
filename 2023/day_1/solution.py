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

def process_line_part_2(line: str) -> int:
    """
    Extract the first and last digit in a line of text,
    including if the digit is spelled out.

    This takes the first digit using a regular expression. As regex
    matches are non-overlapping, this can cause issues when there is
    a combined digit at the end of the line. For example, if the input
    is "oneeight" the regex will only match "one" and not "eight". This
    is desirable for the first digit, but not for the last digit. Instead,
    we can iterate backwards from the end of the line to find the first match.
    """
    pattern = re.compile(r"(\d|one|two|three|four|five|six|seven|eight|nine)")
    digit_one = pattern.search(line)
    if digit_one is None:
        raise ValueError("No digits found in line.")
    # Map the spelled out digits to their numerical value
    digit_map = {
        "one": 1,
        "two": 2,
        "three": 3,
        "four": 4,
        "five": 5,
        "six": 6,
        "seven": 7,
        "eight": 8,
        "nine": 9
    }

    # Start searching backward from the end of the line
    i = len(line) - 1
    digit_two = None
    while i >= 0 and digit_two is None:
        current_char = line[i]
        if current_char.isdigit():
            digit_two = int(current_char)
            break
        available_length = i + 1
        for width in range(0, available_length):
            segment = line[i-width:i+1]
            if digit_map.get(segment) is not None:
                digit_two = digit_map[segment]
                break

        i -= 1
    if digit_two is None:
        raise ValueError("No second digit found.")

    int_one = digit_map[digit_one.group()] if digit_one.group() in digit_map else int(digit_one.group())
    return int_one * 10 + digit_two



def process_file(path: str) -> int:
    with open(path, "r") as f:
        lines = [process_line_part_1(line) for line in f.readlines()]
    return sum(lines)


def process_file_part_2(path: str) -> int:
    with open(path, "r") as f:
        lines = [process_line_part_2(line) for line in f.readlines()]
    return sum(lines)

if __name__ == "__main__":
    print(f"Part 1 answer: {process_file('input.txt')}")
    print(f"Part 2 answer: {process_file_part_2('input.txt')}")
