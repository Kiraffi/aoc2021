const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;


pub fn day11(alloc: *std.mem.Allocator, comptime inputFile: []const u8 ) anyerror!void
{
    // cos of allocator
    var autoScores = std.ArrayList(u64).init(alloc);
    defer autoScores.deinit();

    var board: [100]u8 = std.mem.zeroes([100]u8);
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        var y:u32 = 0;
        while (lines.next()) |line|
        {
            var x: u32 = 0;
            while(x < line.len) : (x += 1)
            {
                const index:u32 = x + y * 10;
                board[index] = line[x] - '0';
            }
            y += 1;
        }
    }

    {
        var flashes: u32 = 0;
        var steps: u32 = 0;
        var allFlashStep: u32 = 0;
        var flashesAt100: u32 = 0;
        while(steps < 100 or allFlashStep == 0) : (steps += 1)
        {
            var y:u32 = 0;
            while(y < 10) : (y += 1)
            {
                var x: u32 = 0;
                while(x < 10) : (x += 1)
                {
                    addValue(&board, x, y);
                }
            }
            y = 0;
            var flashCountPerStep: u32 = 0;
            while(y < 10) : (y += 1)
            {
                var x: u32 = 0;
                while(x < 10) : (x += 1)
                {
                    const index:u32 = x + y * 10;
                    if(board[index] > 9)
                    {
                        flashes += 1;
                        flashCountPerStep += 1;
                        board[index] = 0;
                    }
                }
            }
            if(flashCountPerStep == 100 and allFlashStep == 0)
            {
                allFlashStep = steps;
            }
            if(steps == 99)
            {
                flashesAt100 = flashes;
            }
        }

        print("Day11-1: Flashes: {}\n", .{flashesAt100});
        print("Day11-2: All flash step: {}\n", .{allFlashStep + 1});

    }
}


fn addValue(board: []u8, x: u32, y: u32) void
{
    const index:u32 = x + y * 10;
    board[index] += 1;
    if(board[index] == 10)
    {
        const x2: u32 = if(x < 9) x + 1 else 9;
        var y1: u32 = if(y > 0) y - 1 else 0;
        const y2: u32 = if(y < 9) y + 1 else 9;

        while(y1 <= y2) : (y1 += 1)
        {
            var x1: u32 = if(x > 0) x - 1 else 0;
            while(x1 <= x2) : (x1 += 1)
            {
                if(x1 == x and y1 == y)
                    continue;
                addValue(board, x1, y1);
            }
        }
    }
}

