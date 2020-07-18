const std = @import("std");
const farey = @import("./farey.zig");
const io = std.io;
const fmt = std.fmt;
const process = std.process;

pub fn main() !void {
    var allocator = std.testing.allocator;

    var args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.warn("Usage: farey <decimal>\n", .{});
        return;
    }

    const stdout = io.getStdOut().outStream();
    var input = fmt.parseFloat(f32, args[1]); 

    if (input) |n| {
        var fraction = farey.findFraction(n, 100000);
        try stdout.print("{}/{}\n", .{fraction.numerator, fraction.denominator});
    } else |err| {
        std.debug.warn("farey: Unable to parse input.\n", .{});
        return;
    }
}
