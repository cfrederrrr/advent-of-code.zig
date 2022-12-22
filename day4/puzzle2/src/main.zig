const std = @import("std");
const input = @embedFile("input.txt");

const Assignment = struct {
    const Self = @This();
    top: u8,
    bot: u8,

    pub fn fullyContains(self: Self, other: Self) bool {
        return (self.bot <= other.bot and self.top >= other.top);
    }

    pub fn partlyContains(self: Self, other: Self) bool {
        return (self.bot <= other.bot and self.top >= other.bot);
    }
};

const BuddyPair = [2]Assignment;

const BuddySystemTokenizer = struct {
    const Self = @This();

    buf: []u8,
    pos: usize,
    max: usize,

    pub fn init(buf: []u8) Self {
        return .{
            .buf = buf,
            .pos = 0,
            .max = buf.len,
        };
    }

    pub fn next(self: *Self) anyerror!?BuddyPair {
        if (self.finished()) return null;

        // read the first assignment
        var anchor = self.pos;
        while (self.buf[self.pos] != '-') self.pos += 1;
        var b1_bot = try std.fmt.parseUnsigned(u8, self.buf[anchor..self.pos], 10);

        self.pos += 1; // consume the -
        anchor = self.pos;
        while (self.buf[self.pos] != ',') self.pos += 1;
        var b1_top = try std.fmt.parseUnsigned(u8, self.buf[anchor..self.pos], 10);

        // read the second assignment
        self.pos += 1; // consume the ,
        anchor = self.pos;
        while (self.buf[self.pos] != '-') self.pos += 1;
        var b2_bot = try std.fmt.parseUnsigned(u8, self.buf[anchor..self.pos], 10);

        self.pos += 1; // consume the -
        anchor = self.pos;
        while (!self.finished() and self.buf[self.pos] != '\n') self.pos += 1;
        var b2_top = try std.fmt.parseUnsigned(u8, self.buf[anchor..self.pos], 10);

        if (!self.finished() and self.buf[self.pos] == '\n') self.pos += 1; // consume the \n

        return BuddyPair{
            Assignment{ .bot = b1_bot, .top = b1_top },
            Assignment{ .bot = b2_bot, .top = b2_top },
        };
    }

    pub fn finished(self: *Self) bool {
        return self.pos >= self.max;
    }
};

pub fn main() !void {
    var overlaps: usize = 0;

    var data = input.*;
    var buddypairs = BuddySystemTokenizer.init(&data,);

    while (!buddypairs.finished()) {
        var pair = try buddypairs.next() orelse break;
        if (pair[0].partlyContains(pair[1]) or pair[1].partlyContains(pair[0]))
            overlaps += 1;
    }

    std.debug.print("{d}", .{overlaps});
}