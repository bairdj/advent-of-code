use std::{fs::File, io::Read};

const RADIX: u32 = 10;

fn get_largest_joltage(bank: &str) -> u32 {
    let batteries: Vec<u32> = bank
        .chars()
        .map(|c| c.to_digit(10).expect("Must be a digit"))
        .collect();

    let mut max: u32 = 0;
    for i in 0..batteries.len() {
        for j in (i + 1)..batteries.len() {
            let combination = batteries[i] * RADIX + batteries[j];
            if combination > max {
                max = combination;
            }
        }
    }

    max
}

fn get_largest_joltage_part_2(bank: &str, n_digits: usize) -> u64 {
    let digits: Vec<u64> = bank
        .chars()
        .map(|c| c.to_digit(RADIX).expect("Must be a digit") as u64)
        .collect();

    let mut remaining_digits = n_digits;
    let mut value: u64 = 0;
    let mut current_index = 0;

    while remaining_digits > 0 {
        // Greedily take the largest digit in the search space
        let search_space = current_index..=(digits.len() - remaining_digits);
        let mut max: u64 = 0;
        let mut max_index: usize = current_index;
        for i in search_space {
            if digits[i] > max {
                max = digits[i];
                max_index = i;
            }
        }
        value = value * (RADIX as u64) + max;
        remaining_digits -= 1;
        current_index = max_index + 1;
    }

    value
}

pub fn run(input: &mut File) {
    let mut buffer = String::new();
    input.read_to_string(&mut buffer).expect("Failed to read");

    let banks: Vec<&str> = buffer.lines().collect();

    let part_1_result: u32 = banks.iter().map(|bank| get_largest_joltage(bank)).sum();
    println!("Part 1: {}", part_1_result);

    let part_2_result: u64 = banks
        .iter()
        .map(|bank| get_largest_joltage_part_2(bank, 12))
        .sum();
    println!("Part 2: {}", part_2_result);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_largest_joltage() {
        assert_eq!(get_largest_joltage("987654321111111"), 98);
        assert_eq!(get_largest_joltage("811111111111119"), 89);
        assert_eq!(get_largest_joltage("234234234234278"), 78);
        assert_eq!(get_largest_joltage("818181911112111"), 92);
    }

    #[test]
    fn test_get_largest_joltage_part_2() {
        assert_eq!(
            get_largest_joltage_part_2("987654321111111", 12),
            987654321111
        );
        assert_eq!(
            get_largest_joltage_part_2("818181911112111", 12),
            888911112111
        );
    }
}
