use std::fs::File;
use std::io::Read;
use std::ops::Range;

fn is_valid_number(number: usize, max_repeats: Option<usize>) -> bool {
    let num_str = number.to_string();
    let num_length = num_str.len();

    // Length of a repeated pattern must be a factor of the total length
    let possible_lengths = (1..num_length).filter(|l| num_length % l == 0);

    for poss_length in possible_lengths {
        let buffer = &num_str[0..poss_length];
        let repeats = num_length / poss_length;

        if max_repeats.is_some_and(|max| repeats > max) {
            continue;
        }

        let is_repeating = (0..repeats).all(|i| {
            let start = i * poss_length;
            let end = start + poss_length;
            &num_str[start..end] == buffer
        });

        if is_repeating {
            return false;
        }
    }

    true
}

fn sum_invalid_numbers(ranges: &[Range<usize>], max_repeats: Option<usize>) -> usize {
    ranges
        .iter()
        .flat_map(|range| range.clone())
        .filter(|&num| !is_valid_number(num, max_repeats))
        .sum()
}

fn extract_ranges(input: &str) -> Vec<Range<usize>> {
    input
        .split(',')
        .map(|range| {
            let (start, end) = range.split_once('-').unwrap();
            Range {
                start: start.parse().unwrap(),
                end: end.parse::<usize>().unwrap() + 1,
            }
        })
        .collect()
}

pub fn run(input: &mut File) {
    // Input is a single line
    let mut buffer = String::new();
    input
        .read_to_string(&mut buffer)
        .expect("Failed to read input as string");

    let ranges = extract_ranges(&buffer);

    let result_part_1 = sum_invalid_numbers(&ranges, Some(2));
    println!("Part 1: {}", result_part_1);

    let result_part_2 = sum_invalid_numbers(&ranges, None);
    println!("Part 2: {}", result_part_2);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_valid_number() {
        assert_eq!(is_valid_number(11, Some(2)), false);
        assert_eq!(is_valid_number(12, Some(2)), true);
        assert_eq!(is_valid_number(22, Some(2)), false);
        assert_eq!(is_valid_number(101, Some(2)), true);
        assert_eq!(is_valid_number(1698522, Some(2)), true);
        assert_eq!(is_valid_number(38593859, Some(2)), false);
        assert_eq!(is_valid_number(757575, None), false);
        assert_eq!(is_valid_number(123412341234, None), false);
        assert_eq!(is_valid_number(123412345678, None), true);
    }
}
