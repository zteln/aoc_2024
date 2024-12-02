use std::fs;

fn main() {
    let input = fs::read_to_string("./day2.input").expect("failed to read file");

    let reports: Vec<Vec<i32>> = input
        .split('\n')
        .filter(|s| !s.is_empty())
        .map(|s| s.split(' ').map(|ss| ss.to_string().parse().expect("failed to parse")).collect())
        .collect();

    println!("Part one result: {}", part_one(&reports));
    println!("Part two result: {}", part_two(&reports));
}

fn part_one(reports: &Vec<Vec<i32>>) -> usize {
    let mut report_diffs: Vec<Vec<i32>> = Vec::new();
    for report in reports {
        let level_diffs = gen_level_diffs(report);
        report_diffs.push(level_diffs);
    }
    let filtered_report_diffs: Vec<&Vec<i32>> = report_diffs
        .iter()
        .filter(|level_diffs| is_safe(*level_diffs))
        .collect::<Vec<_>>();
    
    return filtered_report_diffs.len();
}

fn part_two(reports: &Vec<Vec<i32>>) -> u32 {
    let mut count = 0;

    for report in reports {
        let level_diffs = gen_level_diffs(&report);
        if is_safe(&level_diffs) {
            count += 1;
        } else {
            for idx in 0..report.len() {
                let mut rd = report.clone();
                rd.remove(idx);
                let level_diffs = gen_level_diffs(&rd);
                if is_safe(&level_diffs) {
                    count += 1;
                    break;
                }
            }
        }
    }

    return count;
}

fn gen_level_diffs(report: &Vec<i32>) -> Vec<i32> {
    let mut level_diffs: Vec<i32> = Vec::new();
    for level_idx in 0..(report.len() - 1) {
        let level_diff = report[level_idx] - report[level_idx + 1];
        level_diffs.push(level_diff)
    }
    return level_diffs;
}

fn is_safe(level_diffs: &Vec<i32>) -> bool {
    (level_diffs.iter().all(|&x| x > 0) || level_diffs.iter().all(|&x| x < 0)) && level_diffs.iter().all(|&x| match x.abs() {
            1..=3 => true,
            _ => false
        })
}
