const std = @import("std");
const input = @embedFile("input.txt");

const Shape = enum(u8) { Rock=1, Paper=2, Scissor=3, };

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

        var hero: Shape = switch (self.buf[self.idx]) {
            'X' => .Rock,       // 1
            'Y' => .Paper,      // 2
            'Z' => .Scissor,    // 3
            else => std.debug.panic( // i don't think panic is wise here but it's easier
                "invalid hero choice '{c}' in match {d}", .{self.buf[self.idx], self.match}),
        };

        // consume the newline char if there is one to consume
        self.idx += 1;
        if (!self.finished()) self.idx += 1;

        var match_result: u8 = @enumToInt(hero);

        // ties mean +3
        // victories mean +6
        // everything else means +0, so noop
        if (hero == villain)
            match_result += 3
        else if ((hero == Shape.Rock and villain == Shape.Scissor) or
                (hero == Shape.Scissor and villain == Shape.Paper) or
                (hero == Shape.Paper and villain == Shape.Rock))
            match_result += 6;

        return match_result;
    }

    pub fn finished(self: *Self) bool {
        return self.idx >= self.max;
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var data = input[0..].*;
    // std.debug.print("{s}", .{@typeName(@TypeOf(data))});

    var it = MatchTokenizer.init(&data);

    var score: usize = 0;
    while (it.next()) |match| {
        // std.debug.print("{d} => {c}\n", .{it.idx, it.buf[it.idx]});
        score += match;
    }

    _ = try stdout.print("{d}", .{score});
}