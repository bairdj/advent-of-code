use std::io::Read;
use std::ops::Range;
use std::fs::File;

fn is_valid_number(number: usize) -> bool {
    let num_str = number.to_string();

    if num_str.len() % 2 != 0 {
        return true;
    }

    let midpoint = num_str.len() / 2;
    let (segment_1, segment_2) = num_str.split_at(midpoint);

    segment_1.ne(segment_2)
}

fn sum_invalid_numbers(ranges: Vec<Range<usize>>) -> usize {
    let mut sum = 0;
    for range in ranges {
        for n in range {
            if !is_valid_number(n) {
                sum += n;
            }
        }
    }
    
    sum
}

fn extract_ranges(input: &str) -> Vec<Range<usize>> {
    input.split(',').map(|range| {
        let (start, end) = range.split_once('-').unwrap();
        Range {
            start: start.parse().unwrap(),
            end: end.parse::<usize>().unwrap() + 1,
        }
    }).collect()
}

pub fn run(input: &mut File) {
    // Input is a single line
    let mut buffer = String::new();
    input.read_to_string(&mut buffer).expect("Failed to read input as string");

    let ranges = extract_ranges(&buffer);

    let result_part_1 = sum_invalid_numbers(ranges);
    println!("Part 1: {}", result_part_1);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_valid_number() {
        assert_eq!(is_valid_number(11), false);
        assert_eq!(is_valid_number(12), true);
        assert_eq!(is_valid_number(22), false);
        assert_eq!(is_valid_number(101), true);
        assert_eq!(is_valid_number(1698522), true);
        assert_eq!(is_valid_number(38593859), false);
    }

    #[test]
    fn test_extract_ranges() {
        let input = "10-20,30-40,50-60";
        let ranges = extract_ranges(input);
        assert_eq!(ranges.len(), 3);
        assert_eq!(ranges[0], 10..20);
        assert_eq!(ranges[1], 30..40);
        assert_eq!(ranges[2], 50..60);
    }

    #[test]
    fn test_integration() {
        let ranges = extract_ranges("11-22");
        let result = sum_invalid_numbers(ranges);
        assert_eq!(result, 33);
    }
}