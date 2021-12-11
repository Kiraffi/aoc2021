const std = @import("std");

const print = std.debug.print;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const startDur:i128 = std.time.nanoTimestamp();

    var allocator = &arena.allocator;
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day1.zig").day1(allocator);
        const t1:i128 = std.time.nanoTimestamp();
        print("Day1 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day2.zig").day2(allocator);
        const t1:i128 = std.time.nanoTimestamp();
        print("Day2 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day3.zig").day3(allocator, "../input_day3.txt");
        const t1:i128 = std.time.nanoTimestamp();
        print("Day3 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day4.zig").day4(allocator, "../input_day4.txt");
        const t1:i128 = std.time.nanoTimestamp();
        print("Day4 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day5.zig").day5(allocator, "../input_day5.txt");
        const t1:i128 = std.time.nanoTimestamp();
        print("Day5 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day6.zig").day6(allocator, "../input_day6.txt");
        const t1:i128 = std.time.nanoTimestamp();
        print("Day6 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day7.zig").day7(allocator, @embedFile("../input_day7.txt"));
        const t1:i128 = std.time.nanoTimestamp();
        print("Day7 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day8.zig").day8(allocator, @embedFile("../input_day8.txt"));
        const t1:i128 = std.time.nanoTimestamp();
        print("Day8 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day9.zig").day9(allocator, @embedFile("../input_day9.txt"));
        const t1:i128 = std.time.nanoTimestamp();
        print("Day9 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day10.zig").day10(allocator, @embedFile("../input_day10.txt"));
        const t1:i128 = std.time.nanoTimestamp();
        print("Day10 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }
    {
        const t:i128 = std.time.nanoTimestamp();
        try @import("day11.zig").day11(allocator, @embedFile("../input_day11.txt"));
        const t1:i128 = std.time.nanoTimestamp();
        print("Day11 dur: {}us\n\n", .{@divTrunc(t1 - t, @as(i128, 1000))});
    }

    const endDur:i128 = std.time.nanoTimestamp();
    print("Total dur: {}us\n\n", .{@divTrunc(endDur - startDur, @as(i128, 1000))});

}
