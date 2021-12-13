const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;


pub fn day11(_: *std.mem.Allocator, comptime inputFile: []const u8, printVals: bool) anyerror!void
{
    var board: [12*12]u8 = std.mem.zeroes([12*12]u8);
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        var y:u32 = 1;
        while (lines.next()) |line|
        {
            var x: u32 = 0;
            while(x < line.len) : (x += 1)
            {
                const index:u32 = x + 1 + y * 12;
                board[index] = line[x] - '0';
            }
            y += 1;
        }
    }

    {
        var steps: u32 = 0;
        var allFlashStep: u32 = 0;
        var flashesAt100: u32 = 0;
        while(steps < 100 or allFlashStep == 0) : (steps += 1)
        {
            var y:u32 = 1;
            while(y < 11) : (y += 1)
            {
                var x: u32 = 1;
                while(x < 11) : (x += 1)
                {
                    addValue(&board, x, y);
                }
            }
            var flashCountPerStep: u32 = 0;
            y = 13;
            while(y < 12 * 12) : (y += 1)
            {
                if(board[y] > 9)
                {
                    flashCountPerStep += 1;
                    board[y] = 0;
                }
            }
            y = 0;
            while(y < 12) : (y += 1)
            {
                board[y] = 0;
                board[y + 11 * 12] = 0;
                board[y * 12] = 0;
                board[11 + y * 12] = 0;
            }

            if(flashCountPerStep == 100 and allFlashStep == 0)
            {
                allFlashStep = steps;
            }
            if(steps < 100)
            {
                flashesAt100 += flashCountPerStep;
            }
        }
        if(printVals)
        {
            print("Day11-1: Flashes: {}\n", .{flashesAt100});
            print("Day11-2: All flash step: {}\n", .{allFlashStep + 1});
        }
    }
}


fn addValue(board: []u8, x: u32, y: u32) void
{
    const index:u32 = x + y * 12;
    board[index] += 1;
    if(board[index] == 10)
    {
        const x2: u32 = x + 1;
        const y2: u32 = y + 1;

        var y1: u32 = y - 1;
        while(y1 <= y2) : (y1 += 1)
        {
            var x1: u32 = x - 1;
            while(x1 <= x2) : (x1 += 1)
            {
                if(x1 == x and y1 == y)
                    continue;
                addValue(board, x1, y1);
            }
        }
    }
}

