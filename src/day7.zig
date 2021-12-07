const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;


pub fn day7(alloc: *std.mem.Allocator, comptime inputFile: []const u8 ) anyerror!void
{
    var lines = std.mem.tokenize(u8, inputFile, "\r\n");
    var numbersIter = std.mem.tokenize(u8, lines.next().?, ",");
    
    // cos of allocator
    var board = std.ArrayList(u64).init(alloc);
    defer board.deinit();

    var spawns: [2000]u64 = std.mem.zeroes([2000]u64);

    while (numbersIter.next()) |numberString|
    {
        const num = try std.fmt.parseInt(u64, numberString, 10);
        spawns[num] += 1;
    }

    {
        var lowFuel:u64 = 0;
        var lowIndex:u32 = 0;
        var lowSumAtIndex:u64 = spawns[lowIndex];

        var highFuel:u64 = 0;
        var highIndex:u32 = 1999;
        var highSumAtIndex:u64 = spawns[highIndex];

        while(lowIndex < highIndex)
        {
            if(lowSumAtIndex <= highSumAtIndex)
            {
                lowFuel += lowSumAtIndex;
                lowIndex += 1;
                lowSumAtIndex += spawns[lowIndex];
            }
            else
            {
                highFuel += highSumAtIndex;
                highIndex -= 1;
                highSumAtIndex += spawns[highIndex];
            }
        }
        print("Day7-1: Index: {}, fuel consumption: {}\n", .{lowIndex, lowFuel + highFuel});
    }
    
    {
        var lowestFuel:u64 = calculateToDistance(&spawns, 0);
        var i:u32 = 1;
        while(i < 2000) : (i += 1)
        {
            lowestFuel = @minimum(lowestFuel, calculateToDistance(&spawns, i));
        }
        print("Day7-2: Fuel consumption: {}\n", .{lowestFuel});
    }
}

fn calculateToDistance(numbers: []const u64, target: u32) u64
{
    var result:u64 = 0;
    var i:u32 = 0;
    while(i < 2000) : (i += 1)
    {
        const d:u64 = getDistance(i, target);
        result += numbers[i] * d * (d + 1) / 2; // arithmetic sum
    }
    return result;
}

fn getDistance(a: u32, b: u32) u64
{
    return if(a < b) b - a else a - b;
}