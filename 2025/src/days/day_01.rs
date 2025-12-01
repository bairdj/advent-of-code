use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

const DIAL_SIZE: usize = 100;
const TARGET: usize = 0;
const INITIAL_VALUE: usize = 50;

enum Direction {
    Left,
    Right,
}

struct Rotation {
    direction: Direction,
    clicks: usize,
}

fn parse_line(line: String) -> Rotation {
    let (direction, clicks) = line.split_at(1);

    let direction = match direction {
        "L" => Direction::Left,
        "R" => Direction::Right,
        _ => panic!("Invalid direction"),
    };

    let clicks: usize = clicks.parse().expect("Clicks must be a number");

    Rotation { direction, clicks }
}

fn apply_rotation(value: usize, rotation: &Rotation) -> usize {
    match rotation.direction {
        Direction::Right => (value + rotation.clicks) % DIAL_SIZE,
        Direction::Left => (value + DIAL_SIZE - (rotation.clicks % DIAL_SIZE)) % DIAL_SIZE,
    }
}

fn solve_part_1(rotations: &Vec<Rotation>, initial_value: usize) -> usize {
    let mut value = initial_value;
    let mut hit_target = 0;

    for rotation in rotations {
        value = apply_rotation(value, rotation);
        if value == TARGET {
            hit_target += 1;
        }
    }

    hit_target
}

fn solve_part_2(rotations: &Vec<Rotation>, initial_value: usize) -> usize {
    let mut value = initial_value;
    let mut crossed_target = 0;

    // Iterate through each rotation and check if the target is hit
    for rotation in rotations {
        for _i in 0..rotation.clicks {
            value = match rotation.direction {
                Direction::Right => (value + 1) % DIAL_SIZE,
                Direction::Left => (value + DIAL_SIZE - 1) % DIAL_SIZE,
            };

            if value == TARGET {
                crossed_target += 1;
            }
        }
    }

    crossed_target
}

pub fn run(input: File) {
    let reader = BufReader::new(input);

    let rotations: Vec<Rotation> = reader
    .lines()
    .filter_map(Result::ok)
    .map(parse_line)
    .collect();

    let part_1 = solve_part_1(&rotations, INITIAL_VALUE);
    println!("Part 1: {}", part_1);

    let part_2 = solve_part_2(&rotations, INITIAL_VALUE);
    println!("Part 2: {}", part_2);

}