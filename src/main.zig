const std = @import("std");

const day1 = @import("day1.zig").day1;
const day2 = @import("day2.zig").day2;
const day3 = @import("day3.zig").day3;
const day4 = @import("day4.zig").day4;
const day5 = @import("day5.zig").day5;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = &arena.allocator;

    try day1(allocator);
    try day2(allocator);
    try day3(allocator, "../input_day3.txt");
    try day4(allocator, "../input_day4.txt");
    try day5(allocator, "../input_day5.txt");
}