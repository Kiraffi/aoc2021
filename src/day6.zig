const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;


pub fn day6(alloc: *std.mem.Allocator, comptime inputFileName: []const u8 ) anyerror!void
{
    const inputFile = @embedFile(inputFileName);
    var lines = std.mem.tokenize(u8, inputFile, "\r\n");
    var numbersIter = std.mem.tokenize(u8, lines.next().?, ",");
    
    // cos of allocator
    var board = std.ArrayList(u64).init(alloc);
    defer board.deinit();

    var spawns: [9]u64 = std.mem.zeroes([9]u64);

    while (numbersIter.next()) |numberString|
    {
        const num = try std.fmt.parseInt(u64, numberString, 10);
        spawns[num] += 1;
    }

    print("Day6-1: Fish Count: {d}\n", .{simulate(spawns, 80)});
    print("Day6-2: Fish Count: {d}\n", .{simulate(spawns, 256)});
}

// making copy of the input counts, sadly spawninput becomes constant?
fn simulate(spawnInput: [9]u64, days: u64) u64
{
    var spawns: [9]u64 = spawnInput;
    var day:u32 = 0;
    while(day < days) : (day += 1)
    {
        const spawnsAtZero = spawns[0];
        var i:u64 = 0;
        while (i < 8) : (i += 1)
        {
            spawns[i] = spawns[i + 1];
        }
        spawns[6] += spawnsAtZero;
        spawns[8] = spawnsAtZero;
    }

    var sum: u64 = 0;
    var i: u32 = 0;
    while (i < 9) : (i += 1)
    {
        sum += spawns[i];
    }
    return sum;
}