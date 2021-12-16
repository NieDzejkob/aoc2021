use std::io::BufReader;
use std::io::prelude::*;
use std::fs::File;
use std::cmp::Reverse;
use priority_queue::PriorityQueue;

fn read_grid(filename: &str) -> Vec<Vec<u32>> {
    let file = BufReader::new(File::open(filename).unwrap());
    file.lines()
        .map(|line| line.unwrap().trim().chars().map(|c| c.to_digit(10).unwrap()).collect())
        .collect()
}

fn inc_by(v: u32, d: u32) -> u32 {
    let v = v + d;
    if v > 9 {
        v - 9
    } else {
        v
    }
}

fn wrap_row(row: &[u32], d: u32) -> Vec<u32> {
    (0..5).flat_map(|i| row.iter().map(move |&v| inc_by(v, i + d))).collect()
}

fn wrap_grid(input: &[Vec<u32>]) -> Vec<Vec<u32>> {
    (0..5).flat_map(|d| input.iter().map(move |row| wrap_row(row, d))).collect()
}

fn do_grid(grid: &[Vec<u32>]) -> u32 {
    let height = grid.len();
    let width = grid[0].len();

    let target: (i32, i32) = (height as i32 - 1, width as i32 - 1);

    let mut visited: Vec<Vec<bool>> = vec![vec![false; width]; height];
    let mut queue = PriorityQueue::new();

    queue.push((0, 0), Reverse(0));

    while let Some(((y, x), Reverse(cost))) = queue.pop() {
        visited[y as usize][x as usize] = true;

        if (y, x) == target {
            return cost;
        }

        let mut consider = |y, x| {
            if let Some(c) = grid.get(y as usize).and_then(|row| row.get(x as usize)) {
                if !visited[y as usize][x as usize] {
                    queue.push_increase((y, x), Reverse(cost + c));
                }
            }
        };

        consider(y, x - 1);
        consider(y, x + 1);
        consider(y - 1, x);
        consider(y + 1, x);
    }

    unreachable!();
}

fn do_test(filename: &str) -> (u32, u32) {
    let grid = read_grid(filename);
    let part1 = do_grid(&grid);
    let part2 = do_grid(&wrap_grid(&grid));
    (part1, part2)
}

fn main() {
    println!("Example: {:?}", do_test("example"));
    println!("Input: {:?}", do_test("input"));
}
