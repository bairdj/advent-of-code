import re

def process_line(line: str) -> int:
    """
    Extract the first and last digit in a line of text,
    and return them as a combined integer.
    """
    pattern = re.compile(r"(\d).*(\d)")
    result = pattern.search(line)
    if result is None:
        # If the line has exactly one digit, return it twice
        single_digit_pattern = re.compile(r"\d")
        all_matches = single_digit_pattern.findall(line)
        if len(all_matches) == 1:
            extracted_digit = all_matches[0]
            return int(extracted_digit + extracted_digit)

        raise ValueError("Line does not contain exactly one digit")
    return int(result.group(1) + result.group(2))


def process_file(path: str) -> int:
    with open(path, "r") as f:
        lines = [process_line(line) for line in f.readlines()]
    return sum(lines)

if __name__ == "__main__":
    print(process_file("input.txt"))
