const std = @import("std");
const fs = std.fs;

const U8LineIterator = struct {
    buf: []u8,
    idx: usize,
    max: usize,

    const Self = @This();

    pub fn init(buf: []u8) Self {
        return .{
            .buf = buf,
            .max = buf.len - 1,
            .idx = 0,
        };
    }

    pub fn next(self: *Self) ?[]u8 {
        if (self.idx == self.max) return null;
        var start: usize = self.idx;
        while (self.idx < self.max and self.buf[self.idx] != '\n') self.idx += 1;
        var line = self.buf[start..self.idx];
        if (self.idx < self.max and self.buf[self.idx] == '\n') self.idx += 1;
        return line;
    }

    pub fn finished(self: *Self) bool {
        return self.max == self.idx;
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const gpa = &gp.allocator();

    var infile: fs.File = try fs.cwd().openFile("input.txt", .{});
    var input_len = (try infile.stat()).size;

    const file_buffer = try gpa.alloc(u8, input_len);
    _ = try infile.read(file_buffer);
    defer gpa.free(file_buffer);

    infile.close();

    var elf: usize = 0;
    var most: usize = 0;

    var it = U8LineIterator.init(file_buffer);
    while (it.next()) |line| {
        if (it.finished()) {
            elf += try std.fmt.parseUnsigned(usize, line, 10);
            if (elf > most) most = elf;
            elf = 0;
        } else if (line.len != 0) {
            elf += try std.fmt.parseUnsigned(usize, line, 10);
        } else if (line.len == 0) {
            if (elf > most) most = elf;
            elf = 0;
        }
    }

    _ = try stdout.print("{d}", .{most});
}
