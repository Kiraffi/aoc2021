const std = @import("std");

const print = std.debug.print;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

   
    var totalTimer : std.time.Timer =  try std.time.Timer.start();
    defer print("Total dur: {}us\n\n", .{totalTimer.read() / 1000});

    var allocator = &arena.allocator;
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        //try @import("day1.zig").day1(allocator); orig
        try @import("day1.zig").day1(allocator, @embedFile("../input_day1.txt"));
        print("Day1 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day2.zig").day2(allocator, @embedFile("../input_day2.txt"));
        print("Day2 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day3.zig").day3(allocator, @embedFile("../input_day3.txt"));
        print("Day3 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day4.zig").day4(allocator, @embedFile("../input_day4.txt"));
        print("Day4 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day5.zig").day5(@embedFile("../input_day5.txt"));
        print("Day5 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day6.zig").day6(allocator, @embedFile("../input_day6.txt"));
        print("Day6 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day7.zig").day7(allocator, @embedFile("../input_day7.txt"));
        print("Day7 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day8.zig").day8(allocator, @embedFile("../input_day8.txt"));
        print("Day8 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day9.zig").day9(allocator, @embedFile("../input_day9.txt"));
        print("Day9 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day10.zig").day10(allocator, @embedFile("../input_day10.txt"));
        print("Day10 dur: {}us\n\n", .{timer.read() / 1000});
    }
    {
        var timer : std.time.Timer =  try std.time.Timer.start();
        try @import("day11.zig").day11(allocator, @embedFile("../input_day11.txt"));
        print("Day11 dur: {}us\n\n", .{timer.read() / 1000});
    }

  
}
