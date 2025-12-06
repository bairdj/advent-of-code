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

pub fn run(input: &mut File) {
    let mut buffer = String::new();
    input.read_to_string(&mut buffer).expect("Failed to read");

    let banks = buffer.lines();

    let part_1_result: u32 = banks.map(|bank| get_largest_joltage(bank)).sum();
    println!("Part 1: {}", part_1_result);
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
}
