use std::fs;

fn main() {
    let input = fs::read_to_string("./day1.input").expect("failed to read file");
    let lines: Vec<String> = input.split('\n').filter(|s| !s.is_empty()).map(|s| s.to_string()).collect();
    let mut left: Vec<i32> = Vec::new();
    let mut right: Vec<i32> = Vec::new();

    for line in lines {
        let entry: Vec<i32> = line
            .split(' ')
            .filter(|s| !s.is_empty())
            .map(|s| s.to_string().parse().expect("failed to parse"))
            .collect();
        left.push(entry[0]);
        right.push(entry[1]);
    }

    let part_one_result = part_one(&mut left, &mut right);
    println!("Part one result: {}", part_one_result);

    let part_two_result = part_two(&mut left, &mut right);
    println!("Part two result: {}", part_two_result);
}

fn part_one(left: &mut Vec<i32>, right: &mut Vec<i32>) -> i32 {
    let mut diffs: Vec<i32> = Vec::new();

    left.sort();
    right.sort();

    for i in 0..left.len() {
        let diff = left[i] - right[i];
        diffs.push(diff.abs())
    }

    let diffs = diffs.into_iter().fold(0, |sum, diff| sum + diff);
    return diffs;
}

fn part_two(left: &mut Vec<i32>, right: &mut Vec<i32>) -> i32 {
    let mut similarities: Vec<i32> = Vec::new();

    for i in 0..left.len() {
        let similarity = right.iter().fold(0, |count, val| if *val == left[i] {
            count + 1
        } else {
            count
        });
        similarities.push(left[i] * similarity);
    }

    let similarity = similarities.into_iter().fold(0, |sum, val| sum + val);
    return similarity;
}

// fn part_one(input: &String) {
//     let lines: Vec<String> = input.split('\n').filter(|s| !s.is_empty()).map(|s| s.to_string()).collect();
//     let mut left: Vec<i32> = Vec::new();
//     let mut right: Vec<i32> = Vec::new();
//     let mut diffs: Vec<i32> = Vec::new();
//
//     for line in lines {
//         let entry: Vec<i32> = line
//             .split(' ')
//             .filter(|s| !s.is_empty())
//             .map(|s| s.to_string().parse().expect("failed to parse"))
//             .collect();
//         left.push(entry[0]);
//         right.push(entry[1]);
//     }
//
//     left.sort();
//     right.sort();
//
//     for i in 0..left.len() {
//         let diff = left[i] - right[i];
//         diffs.push(diff.abs())
//     }
//
//     let sum = diffs.into_iter().fold(0, |sum, diff| sum + diff);
//     println!("Part 1 result: {}", sum);
// }
//
// fn part_two(input: &String) {
//     let lines: Vec<String> = input.split('\n').filter(|s| !s.is_empty()).map(|s| s.to_string()).collect();
//     let mut left: Vec<i32> = Vec::new();
//     let mut right: Vec<i32> = Vec::new();
//     let mut similarities: Vec<i32> = Vec::new();
//
//     for line in lines {
//         let entry: Vec<i32> = line
//             .split(' ')
//             .filter(|s| !s.is_empty())
//             .map(|s| s.to_string().parse().expect("failed to parse"))
//             .collect();
//         left.push(entry[0]);
//         right.push(entry[1]);
//     }
//
//     for i in 0..left.len() {
//         let similarity = right.iter().fold(0, |count, val| if *val == left[i] {
//             count + 1
//         } else {
//             count
//         });
//         similarities.push(left[i] * similarity);
//     }
//
//     let similarity = similarities.into_iter().fold(0, |sum, val| sum + val);
//
//     println!("Part 2 result: {}", similarity);
// }
