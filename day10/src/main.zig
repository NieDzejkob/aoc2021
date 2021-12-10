const std = @import("std");

fn popping(stack: *std.ArrayList(u8), expect: u8) bool {
    if (stack.popOrNull()) |c| {
        return c == expect;
    } else {
        return false;
    }
}

const Verdict = enum {
    wrong_char,
    incomplete,
};

const Result = struct {
    verdict: Verdict,
    score: u64,
};

fn fuckit(verdict: Verdict, score: u64) Result {
    return .{.verdict = verdict, .score = score};
}

fn firstWrongChar(alloc: *std.mem.Allocator, line: []const u8) anyerror!Result {
    var stack = try std.ArrayList(u8).initCapacity(alloc, 100);
    defer stack.deinit();

    for (line) |c| switch (c) {
        '(', '[', '{', '<' => try stack.append(c),
        ')' => if (!popping(&stack, '(')) { return fuckit(.wrong_char, 3); },
        ']' => if (!popping(&stack, '[')) { return fuckit(.wrong_char, 57); },
        '}' => if (!popping(&stack, '{')) { return fuckit(.wrong_char, 1197); },
        '>' => if (!popping(&stack, '<')) { return fuckit(.wrong_char, 25137); },
        else => return error.UnexpectedCharacter,
    };

    var score: u64 = 0;
    var i: usize = 0;
    while (i < stack.items.len) {
        i += 1;
        switch (stack.items[stack.items.len - i]) {
            '(' => { score *= 5; score += 1; },
            '[' => { score *= 5; score += 2; },
            '{' => { score *= 5; score += 3; },
            '<' => { score *= 5; score += 4; },
            else => unreachable,
        }
    }
    return fuckit(.incomplete, score);
}

fn doTestcase(alloc: *std.mem.Allocator, filename: []const u8) anyerror!void {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const reader = file.reader();
    var line_buffer = try std.ArrayList(u8).initCapacity(alloc, 300);
    defer line_buffer.deinit();

    var part1: u64 = 0;
    var part2 = try std.ArrayList(u64).initCapacity(alloc, 100);
    defer part2.deinit();

    while (true) {
        reader.readUntilDelimiterArrayList(&line_buffer, '\n', std.math.maxInt(usize)) catch |err| switch (err) {
            error.EndOfStream => { break; },
            else => |e| return e,
        };
        var line = line_buffer.items;

        // here's how to trim the line if you want
        line.len = std.mem.trimRight(u8, line, "\n\r").len;

        var result = try firstWrongChar(alloc, line);
        switch (result.verdict) {
            .wrong_char => part1 += result.score,
            .incomplete => try part2.append(result.score),
        }

        try line_buffer.resize(0);
    }

    std.sort.sort(u64, part2.items, {}, comptime std.sort.asc(u64));
    var mid = part2.items.len / 2;

    std.log.info("Result for {s}: {d}, {d}", .{filename, part1, part2.items[mid]});
}

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    try doTestcase(&gpa.allocator, "input-example.txt");
    try doTestcase(&gpa.allocator, "input.txt");
}
