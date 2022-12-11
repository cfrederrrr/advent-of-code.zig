const std = @import("std");
const fs = std.fs;

const ElfTokenizer = struct {
    buf: []u8,
    idx: usize,
    max: usize,
    line: usize,

    const Self = @This();

    pub fn init(buf: []u8) Self {
        return .{
            .buf = buf,
            .max = buf.len - 1,
            .idx = 0,
            .line = 1,
        };
    }

    fn readLine(self: *Self) []u8 {
        var start: usize = self.idx;
        while (self.idx < self.max and self.buf[self.idx] != '\n') self.idx += 1;
        var line = self.buf[start..self.idx];
        self.line += 1;
        if (self.idx < self.max) self.idx += 1;
        return line;
    }

    pub fn next(self: *Self) ?u32 {
        if (self.idx == self.max) return null;
        var calories: u32 = 0;

        while (self.idx < self.max and self.buf[self.idx] != '\n') {
            var line = self.readLine();
            calories += std.fmt.parseUnsigned(u32, line, 10) catch {
                std.debug.panic("invalid data on line {d} ({s})", .{self.line, line});
            };
        }

        if (self.idx < self.max and self.buf[self.idx] == '\n') self.idx += 1;
        return calories;
    }

    pub fn finished(self: *Self) bool {
        return self.idx == self.max;
    }
};

fn compare(comptime _: type, lhs: u32, rhs: u32) bool {
    return lhs < rhs;
}

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

    var elf1: usize = 0;
    var elf2: usize = 0;
    var elf3: usize = 0;

    var tokenizer = ElfTokenizer.init(file_buffer);
    while (tokenizer.next()) |elf| {
        if (elf > elf1) {
            elf3 = elf2;
            elf2 = elf1;
            elf1 = elf;
        } else if (elf > elf2) {
            elf3 = elf2;
            elf2 = elf;
        } else if (elf > elf3) {
            elf3 = elf;
        }
    }

    _ = try stdout.print("{d}", .{elf1 + elf2 + elf3});
}
