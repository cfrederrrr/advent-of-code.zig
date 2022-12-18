const std = @import("std");
const input = @embedFile("input.txt");

const sort = std.sort;

// this turned out to be unnecessary since there would only ever be
// one matching element between the left and right compartments, but
// i misunderstood the word-problem; it sounded like there could be
// any number of matching items on the left and right.
//
// what remains is a stripped down version of what would have worked
// if that were the case, but i'm not reimplementing the solution
// without all this
const UniqueCharIterator = struct {
    const Self = @This();

    buf: []u8,
    idx: usize,

    pub fn init(buf: []u8) Self {
        std.sort.sort(u8, buf, {}, std.sort.asc(u8));
        return .{
            .buf = buf,
            .idx = 0,
        };
    }

    pub fn next(self: *Self) ?u8 {
        if (self.finished()) return null;
        var char: u8 = self.buf[self.idx];
        while (!self.finished() and char == self.buf[self.idx]) self.idx += 1;
        return char;
    }

    pub fn finished(self: *Self) bool {
        return self.idx >= self.buf.len;
    }

    pub fn rewind(self: *Self) void {
        self.idx = 0;
    }
};

const Rucksack = struct {
    const Self = @This();

    left: []u8,
    right: []u8,

    pub fn init(left: []u8, right: []u8) Self {
        return .{
            .left = left,
            .right = right,
        };
    }

    pub fn sharedContents(self: *Self) !u8 {
        var leftchars = UniqueCharIterator.init(self.left);
        var rightchars = UniqueCharIterator.init(self.right);

        var shared: u8 = 0;
        outer: while (leftchars.next()) |lchar| {
            while (rightchars.next()) |rchar| {
                shared = lchar;
                if (lchar == rchar) break :outer;
            }

            rightchars.rewind();
        }

        std.debug.print("{c} {d}\t {s} {s}\n", .{shared, priority(shared), self.left, self.right});
        return shared;
    }
};

fn priority(c: u8) u8 {
    return switch (c) {
        'a'...'z' => c - 0x60,
        'A'...'Z' => c - 0x26,
        else => 0, // this should never happen given the dataset
    };
}

const RucksackTokenizer = struct {
    const Self = @This();

    buf: []u8,
    idx: usize,
    sack: usize,
    max: usize,

    pub fn init(buf: []u8) Self {
        return .{
            .buf = buf,
            .max = buf.len - 1,
            .idx = 0,
            .sack = 1,
        };
    }

    pub fn next(self: *Self) ?Rucksack {
        if (self.finished()) return null;

        // parse the line
        var start = self.idx;
        while (!self.finished() and self.buf[self.idx] != '\n') self.idx += 1;
        var contents = self.buf[start..self.idx];

        // consume the newline if there is one. the while loop above guarantees
        // that either we're at the end of the file, or the current char is \n
        if (!self.finished()) self.idx += 1;

        // return a Rucksack
        var left = contents[0..(contents.len/2)];
        var right = contents[(contents.len/2)..];
        return Rucksack.init(left, right);
    }

    pub fn finished(self: *Self) bool {
        return self.idx >= self.max;
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var data = input[0..].*;
    var it = RucksackTokenizer.init(&data);

    var total: usize = 0;
    var counter: usize = 0;
    while (!it.finished()) {
        counter += 1;
        std.debug.print("{d}\t", .{counter});
        var sack = it.next() orelse break;
        var shared = try sack.sharedContents();
        total += priority(shared);
    }
    // while (it.next()) |sack| {

    //     std.debug.print("starting sack {d}\n", .{counter});
    //     var shared = try sack.sharedContents();
    //     std.debug.print("shared {d} = {s}\n", .{counter, shared});
    //     std.debug.print("finished sack {d}\n", .{counter});
    //     // std.debug.print("{s}", .{shared});
    //     // for (shared) |item| {
    //     //     var prio = priority(item);
    //     //     total += prio;
    //     // }

    //     counter += 1;
    // }

    _ = try stdout.print("{d}", .{total});
}