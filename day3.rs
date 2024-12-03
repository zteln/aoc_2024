use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let file = &args[1];

    let input = fs::read_to_string(file).expect("failed to read file");

    let part_one_result = part_one(&input);
    let part_two_result = part_two(&input);

    println!("Part one result: {}", part_one_result);
    println!("Part two result: {}", part_two_result);
}

fn part_one(mem: &String) -> u64 {
    let mut str_acc = String::from("");
    let mut sum: u64 = 0;
    let mut arg1: u32 = 0;
    let mut arg2: u32 = 0;
    const RADIX: u32 = 10;

    for c in mem.chars() {
        if c == 'm' && str_acc == "" {
            str_acc.push(c);
        } else if c == 'u' && str_acc == "m" {
            str_acc.push(c);
        } else if c == 'l' && str_acc == "mu" {
            str_acc.push(c);
        } else if c == '(' && str_acc == "mul" {
            str_acc.push(c);
        } else if c == ',' && str_acc == "mul(" {
            str_acc.push(c);
        } else if c == ')' && str_acc == "mul(," {
            str_acc = String::from("");
            sum += u64::from(arg1) * u64::from(arg2);
            arg1 = 0;
            arg2 = 0;
        } else if c.is_numeric() && str_acc == "mul(" {
            arg1 = arg1 * 10 + c.to_digit(RADIX).unwrap();
        } else if c.is_numeric() && str_acc == "mul(," {
            arg2 = arg2 * 10 + c.to_digit(RADIX).unwrap();
        } else {
            str_acc = String::from("");
            arg1 = 0;
            arg2 = 0;
        }
    }

    return sum;
}

fn part_two(mem: &String) -> u64 {
    let mut str_acc = String::from("");
    let mut enabled_acc = String::from("");
    let mut sum: u64 = 0;
    let mut arg1: u32 = 0;
    let mut arg2: u32 = 0;
    let mut is_enabled: bool = true;
    const RADIX: u32 = 10;

    for c in mem.chars() {
        if c == 'm' && str_acc == "" {
            str_acc.push(c);
        } else if c == 'u' && str_acc == "m" {
            str_acc.push(c);
        } else if c == 'l' && str_acc == "mu" {
            str_acc.push(c);
        } else if c == '(' && str_acc == "mul" {
            str_acc.push(c);
        } else if c == ',' && str_acc == "mul(" {
            str_acc.push(c);
        } else if c == ')' && str_acc == "mul(," {
            str_acc = String::from("");
            sum += if is_enabled {u64::from(arg1) * u64::from(arg2)} else {0};
            arg1 = 0;
            arg2 = 0;
        } else if c.is_numeric() && str_acc == "mul(" {
            arg1 = arg1 * 10 + c.to_digit(RADIX).unwrap();
        } else if c.is_numeric() && str_acc == "mul(," {
            arg2 = arg2 * 10 + c.to_digit(RADIX).unwrap();
        } else if c == 'd' && enabled_acc == "" {
            enabled_acc.push(c);
        } else if c == 'o' && enabled_acc == "d" {
            enabled_acc.push(c);
        } else if c == '(' && enabled_acc == "do" {
            enabled_acc.push(c);
        } else if c == ')' && enabled_acc == "do(" {
            is_enabled = true;
            enabled_acc = String::from("");
        } else if c == 'n' && enabled_acc == "do" {
            enabled_acc.push(c);
        } else if c == '\'' && enabled_acc == "don" {
            enabled_acc.push(c);
        } else if c == 't' && enabled_acc == "don'" {
            enabled_acc.push(c);
        } else if c == '(' && enabled_acc == "don't" {
            enabled_acc.push(c);
        } else if c == ')' && enabled_acc == "don't(" {
            is_enabled = false;
            enabled_acc = String::from("");
        } else {
            str_acc = String::from("");
            enabled_acc = String::from("");
            arg1 = 0;
            arg2 = 0;
        }
    }

    return sum;
}
