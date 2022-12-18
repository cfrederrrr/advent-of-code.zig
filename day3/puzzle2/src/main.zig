const std = @import("std");
const input = @embedFile("input.txt");


fn priority(c: u8) u8 {
    return switch (c) {
        'a'...'z' => c - 0x60,  //  1..26
        'A'...'Z' => c - 0x26,  // 27..52
        else => 0,              // this should never happen given the dataset
    };
}

const ElfGroup = [3][]u8;
const ElfGroupTokenizer = struct {
    const Self = @This();

    buf: []u8,
    idx: usize,
    max: usize,

    pub fn init(buf: []u8) Self {
        return .{
            .buf = buf,
            .max = buf.len - 1,
            .idx = 0,
        };
    }

    // naive implementation taht only works because we know that the
    // input has a line count divisible by 3
    //
    // if we didn't, we would have to write all kinds of error handling
    // which i don't really feel like doing since this isn't production
    // code
    pub fn next(self: *Self) ?ElfGroup {
        if (self.finished()) return null;

        var start = self.idx;
        while (!self.finished() and self.buf[self.idx] != '\n') self.idx += 1;
        var contents_1 = self.buf[start..self.idx];
        if (!self.finished() and self.buf[self.idx] == '\n') self.idx += 1;

        start = self.idx;
        while (!self.finished() and self.buf[self.idx] != '\n') self.idx += 1;
        var contents_2 = self.buf[start..self.idx];
        if (!self.finished() and self.buf[self.idx] == '\n') self.idx += 1;

        start = self.idx;
        while (!self.finished() and self.buf[self.idx] != '\n') self.idx += 1;
        var contents_3 = self.buf[start..self.idx];
        if (!self.finished() and self.buf[self.idx] == '\n') self.idx += 1;

        return .{contents_1, contents_2, contents_3};
    }

    pub fn finished(self: *Self) bool {
        return self.idx >= self.max;
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var data = input[0..].*;
    var it = ElfGroupTokenizer.init(&data);

    var total: usize = 0;
    while (it.next()) |group| {
        var member_1 = group[0];
        var member_2 = group[1];
        var member_3 = group[2];

        out: for (member_1) |item1| {
            for (member_2) |item2| {
                if (item1 == item2) {
                    for (member_3) |item3| {
                        if (item1 == item3) {
                            var prio = priority(item1);
                            total += prio;
                            break :out;
                        }
                    }
                }
            }
        }
    }

    _ = try stdout.print("{d}", .{total});
}