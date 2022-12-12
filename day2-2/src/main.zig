const std = @import("std");
const input = @embedFile("input.txt");

const Shape = enum(u8) { Rock=1, Paper=2, Scissor=3, };
const Result = enum(u8) { Loss=0, Draw=3, Win=6, };

const MatchTokenizer = struct {
    const Self = @This();

    buf: []u8,
    max: usize,
    idx: usize,
    match: usize,

    pub fn init(buf: []u8) Self {
        return .{
            .buf = buf,
            .max = buf.len-1,
            .idx = 0,
            .match = 0,
        };
    }

    pub fn next(self: *Self) ?u8 {
        if (self.finished()) return null;

        self.match += 1;

        var villain: Shape = switch (self.buf[self.idx]) {
            'A' => .Rock,       // 1
            'B' => .Paper,      // 2
            'C' => .Scissor,    // 3
            else => std.debug.panic( // i don't think panic is wise here but it's easier
                "invalid villain choice '{c}' in match {d}", .{self.buf[self.idx], self.match}),
        };

        self.idx += 2;

        var result: Result = switch (self.buf[self.idx]) {
            'X' => .Loss,       // 1
            'Y' => .Draw,       // 2
            'Z' => .Win,        // 3
            else => std.debug.panic( // i don't think panic is wise here but it's easier
                "invalid hero choice '{c}' in match {d}", .{self.buf[self.idx], self.match}),
        };

        // consume the newline char if there is one to consume
        self.idx += 1;
        if (!self.finished()) self.idx += 1;

        var hero: Shape = switch (result) {
            .Loss => switch (villain) { .Rock => .Scissor, .Scissor => .Paper, .Paper => .Rock },
            .Win  => switch (villain) { .Rock => .Paper, .Scissor => .Rock, .Paper => .Scissor },
            .Draw => villain,
        };

        return @enumToInt(result) + @enumToInt(hero);
    }

    pub fn finished(self: *Self) bool {
        return self.idx >= self.max;
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var data = input[0..].*;

    var it = MatchTokenizer.init(&data);

    var score: usize = 0;
    while (it.next()) |match| score += match;

    _ = try stdout.print("{d}", .{score});
}