const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

const inputFile = @embedFile("../input_day5.txt");

pub fn day5(alloc: *std.mem.Allocator) anyerror!void
{
    var lines = std.mem.tokenize(u8, inputFile, "\r\n");
    var board = std.ArrayList(u32).init(alloc);
    defer board.deinit();
    const boardSize: u32 = 1000;
    var lineBoard: [boardSize * boardSize]u32 = std.mem.zeroes([boardSize * boardSize]u32);
    var lineBoard2: [boardSize * boardSize]u32 = std.mem.zeroes([boardSize * boardSize]u32);

    while (lines.next()) |line|
    {
        var fromTo = std.mem.tokenize(u8, line, " -> ");
        var parsedValues: [4]u32 = std.mem.zeroes([4]u32);
        var i:u32 = 0;
        while(fromTo.next()) |numberIter|
        {
            var numbIter = std.mem.tokenize(u8, numberIter, ",");
            parsedValues[i] = try std.fmt.parseInt(u32, numbIter.next().?, 10);
            parsedValues[i + 1] = try std.fmt.parseInt(u32, numbIter.next().?, 10);
            i += 2;
        }
        const d1:u32 = distance(parsedValues[2], parsedValues[0]);
        const d2:u32 = distance(parsedValues[3], parsedValues[1]);

        if(d1 == 0 or d2 == 0)
        {
            var ii1:u32 = @minimum(parsedValues[0], parsedValues[2]);
            var ii2:u32 = @maximum(parsedValues[0], parsedValues[2]);
            var j1:u32 = @minimum(parsedValues[1], parsedValues[3]);
            var j2:u32 = @maximum(parsedValues[1], parsedValues[3]);
            if(ii1 < ii2)
            {
                while(ii1 <= ii2) : (ii1 += 1)
                   lineBoard[ii1 + boardSize * j1] += 1;

            }
            else
            {
                while(j1 <= j2) : (j1 += 1)
                   lineBoard[ii1 + boardSize * j1] += 1;

            }

        }
        else if(d1 == d2)
        {
            var dir1:i32 = direction(parsedValues[0], parsedValues[2]);
            var dir2:i32 = direction(parsedValues[1], parsedValues[3]);

            var p1:u32 = parsedValues[0];
            var p2:u32 = parsedValues[1];
            var ii1:u32 = 0;
            while(ii1 <= d1) : (ii1 += 1)
            {
                lineBoard2[p1 + p2 * boardSize] += 1;

                //... integer overflows possibly if last point on edge..
                if(ii1 < d1)
                {
                    p1 = if(dir1 > 0) p1 + 1 else p1 - 1;
                    p2 = if(dir2 > 0) p2 + 1 else p2 - 1;
                }
            }

        }

    }
    var i:u32 = 0;
    var overLappingPoints: u32 = 0;
    var overLappingPoints2: u32 = 0;
    while(i < boardSize * boardSize)
    {
        if(lineBoard[i] > 1)
            overLappingPoints += 1;
        if(lineBoard[i] + lineBoard2[i] > 1)
            overLappingPoints2 += 1;
        i+=1;
    }
    print("Day5-1: Overlapping points: {d}\n", .{overLappingPoints});
    print("Day5-2: Overlapping points: {d}\n", .{overLappingPoints2});
}

fn distance(a: u32, b: u32) u32
{
    if(a > b)
        return a - b;
    return b - a;
}

fn direction(a: u32, b: u32) i32
{
    if(a > b)
        return -1;
    return 1;
}