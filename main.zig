const std = @import("std");
const farey = @import("./farey.zig");
const io = std.io;
const fmt = std.fmt;
const process = std.process;

pub fn main() !void {
    var buffer: [200]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var allocator = &fba.allocator;

    if (process.argsAlloc(allocator)) |args| {
        defer process.argsFree(allocator, args);
        if (args.len < 2) {
            std.debug.warn("Usage: farey <decimal>\n", .{});
            return;
        }

        const stdout = io.getStdOut().outStream();
        if (fmt.parseFloat(f32, args[1])) |n| { 
            var fraction = farey.findFraction(n, 100000);
            try stdout.print("{}/{}\n", .{fraction.numerator, fraction.denominator});
        } else |err| {
            std.debug.warn("farey: unable to parse input.\n", .{});
            return;
        }
    } else |err| switch (err) {
        error.OutOfMemory => {
            std.debug.warn("farey: input too long", .{});
        },
        error.Overflow => {
            std.debug.warn("farey: overflow", .{});
        }
    }
}
