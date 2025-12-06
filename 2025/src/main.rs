use std::{env::{Args, args}, fs::File};

mod days{
    pub mod day_01;
    pub mod day_02;
    pub mod day_03;
}

struct AocArgs {
    day: u8,
    path: String
}

fn parse_args(args: &mut Args) -> AocArgs {
    let day: u8 = args.nth(1).expect("Must provide day").parse().expect("Day must be a number");
    let path: String = args.next().expect("Must provide path");

    return AocArgs { day, path };
}


fn main() {
    let args = parse_args(&mut args());

    let mut input = File::open(args.path).expect("Failed to open input file");

    match args.day {
        1 => days::day_01::run(input),
        2 => days::day_02::run(&mut input),
        3 => days::day_03::run(&mut input),
        _ => panic!("Day not implemented"),
    }
}
