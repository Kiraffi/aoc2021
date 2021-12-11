const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

const Point = struct {
    x: u64,
    y: u64,
    tiles: u32,
};


pub fn day9(alloc: *std.mem.Allocator, comptime inputFile: []const u8 ) anyerror!void
{

    // cos of allocator
    var board = std.ArrayList(u8).init(alloc);
    defer board.deinit();

    var lowestPoints = std.ArrayList(Point).init(alloc);
    defer lowestPoints.deinit();

    var boardWidth: u64 = 0;
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        // Parse
        while (lines.next()) |line|
        {
            var i:u32 = 0;
            while(i < line.len) : (i += 1)
            {
                var num:u8 = line[i] - '0';
                try board.append(num);
            }
            boardWidth = if (line.len > 0) line.len else boardWidth;
        }
    }
    const boardHeight:u64 = board.items.len / boardWidth;
    {
        // Find minimums
        var sumOfMins: u32 = 0;
        var y:u64 = 0;
        while(y < boardHeight) : (y += 1)
        {
            var x:u64 = 0;
            while(x < boardWidth) : (x += 1)
            {
                const curr:u8 = board.items[x + y * boardWidth];
                if(!((x > 0 and board.items[x - 1 + y * boardWidth] <= curr) or (x < boardWidth - 1 and board.items[x + 1 + y * boardWidth] <= curr) or
                (y > 0 and board.items[x + (y - 1) * boardWidth] <= curr) or (y < boardHeight - 1 and board.items[x + (y + 1) * boardWidth] <= curr)))
                {
                    sumOfMins += @intCast(u32, curr + 1);
                    try lowestPoints.append(Point{.x = x, .y = y, .tiles = 0});
                }
            }
        }
        print("Day9-1: Sum of mins: {}\n", .{sumOfMins});
    }

    {
        // Find the end point from every point as in flow.
        var y:u64 = 0;
        while(y < boardHeight) : (y += 1)
        {
            var x:u64 = 0;
            while(x < boardWidth) : (x += 1)
            {
                if( board.items[x + y * boardWidth] == 9)
                    continue;
                var found: bool = false;
                var x1:u64 = x;
                var y1:u64 = y;
                while(!found)
                {
                    const curr:u8 = board.items[x1 + y1 * boardWidth];

                    if(x1 > 0 and board.items[x1 - 1 + y1 * boardWidth] < curr)
                    {
                        x1 -= 1;
                    }
                    else if(x1 < boardWidth - 1 and board.items[x1 + 1 + y1 * boardWidth] < curr)
                    {
                        x1 += 1;
                    }
                    else if(y1 > 0 and board.items[x1 + (y1 - 1) * boardWidth] < curr)
                    {
                        y1 -= 1;
                    }
                    else if(y1 < boardHeight - 1 and board.items[x1 + (y1 + 1) * boardWidth] < curr)
                    {
                        y1 += 1;
                    }
                    else
                    {
                        found = true;
                    }
                }

                var i:u32 = 0;
                while(i < lowestPoints.items.len) : (i += 1)
                {
                    if(lowestPoints.items[i].x == x1 and lowestPoints.items[i].y == y1)
                    {
                        lowestPoints.items[i].tiles += 1;
                    }
                }
            }
        }
    }
    // Find 3 largest
    var i:u32 = 0;
    var largest: [3]u32 = .{0, 0, 0};
    while(i < lowestPoints.items.len) : (i += 1)
    {
        const p: Point = lowestPoints.items[i];
        var tiles: u32 = p.tiles;
        var j:u32 = 0;
        while(j < 3) : (j += 1)
        {
            if(largest[j] < tiles)
            {
                const tmp: u32 = largest[j];
                largest[j] = tiles;
                tiles = tmp;
            }
        }

    }
    print("Day9-2: Basins {}\n", .{ largest[0] * largest[1] * largest[2] });
}

