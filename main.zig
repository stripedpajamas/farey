const std = @import("std");
const farey = @import("./farey.zig");
const io = std.io;
const fmt = std.fmt;
const process = std.process;

fn getInput(allocator: *std.mem.Allocator) !f32 {
    if (process.argsAlloc(allocator)) |args| {
        defer process.argsFree(allocator, args);
        if (args.len < 2) {
            return error.IllegalArgument;
        }

        return fmt.parseFloat(f32, args[1]);
    } else |err| return err;
}

pub fn main() !void {
    var buffer: [200]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var allocator = &fba.allocator;

    const stdout = io.getStdOut().outStream();
    const input = getInput(allocator);
    if (input) |n| {
        var number = farey.floatToNumber(n, std.math.maxInt(i32));
        if (number.whole == 0) {
            try stdout.print("{}/{}\n", .{
                number.fraction.numerator,
                number.fraction.denominator
            });
        } else {
            try stdout.print("{} {}/{}\n", .{
                number.whole,
                number.fraction.numerator,
                number.fraction.denominator
            });
        }
    } else |err| switch (err) {
        error.InvalidCharacter => {
            std.debug.warn("farey: unable to parse input.\n", .{});
        },
        error.IllegalArgument => {
            std.debug.warn("Usage: farey <decimal>\n", .{});
        },
        error.OutOfMemory => {
            std.debug.warn("farey: input too long", .{});
        },
        error.Overflow => {
            std.debug.warn("farey: overflow", .{});
        }
    }
}
