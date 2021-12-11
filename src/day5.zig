const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

//pub fn day5(alloc: *std.mem.Allocator, comptime inputFileName: []const u8 ) anyerror!void

pub fn day5(alloc: *std.mem.Allocator, comptime inputFile: []const u8 ) anyerror!void
{
    //const inputFile = @embedFile(inputFileName);
    var lines = std.mem.tokenize(u8, inputFile, "\r\n");
    var board = std.ArrayList(u32).init(alloc);
    defer board.deinit();
    const boardSize: u32 = 1000;
    var lineBoard: [boardSize * boardSize]u32 = std.mem.zeroes([boardSize * boardSize]u32);
    var lineBoard2: [boardSize * boardSize]u32 = std.mem.zeroes([boardSize * boardSize]u32);

    while (lines.next()) |line|
    {
        var numbIter = std.mem.tokenize(u8, line, ",");

        const x1 = try std.fmt.parseInt(u32, numbIter.next().?, 10);

        var middleIter = std.mem.tokenize(u8, numbIter.next().?, " -> ");
        const y1 = try std.fmt.parseInt(u32, middleIter.next().?, 10);
        const x2 = try std.fmt.parseInt(u32, middleIter.next().?, 10);

        const y2 = try std.fmt.parseInt(u32, numbIter.next().?, 10);

        const d1:u32 = distance(x2, x1);
        const d2:u32 = distance(y2, y1);

        if(d1 == 0 or d2 == 0)
        {
            var xmin:u32 = @minimum(x1, x2);
            const xmax:u32 = @maximum(x1, x2);
            var ymin:u32 = @minimum(y1, y2);
            const ymax:u32 = @maximum(y1, y2);
            if(d1 != 0)
            {
                while(xmin <= xmax) : (xmin += 1)
                   lineBoard[xmin + boardSize * ymin] += 1;

            }
            else
            {
                while(ymin <= ymax) : (ymin += 1)
                   lineBoard[xmin + boardSize * ymin] += 1;

            }

        }
        else if(d1 == d2)
        {
            const dirX:i32 = direction(x1, x2);
            const dirY:i32 = direction(y1, y2);

            var px:i32 = @intCast(i32, x1);
            var py:i32 = @intCast(i32, y1);
            var i:u32 = 0;
            while(i <= d1) : (i += 1)
            {
                const index: u32 = @intCast(u32, px) + @intCast(u32, py) * boardSize;
                lineBoard2[index] += 1;

                //... integer overflows possibly if last point on edge..
                //if(i < d1)
                {
                    _ = @addWithOverflow(i32, px, dirX, &px);
                    _ = @addWithOverflow(i32, py, dirY, &py);
                    //p1 += dir1; // if(dir1 > 0) p1 + 1 else p1 - 1;
                    //p2 += dir2; // if(dir2 > 0) p2 + 1 else p2 - 1;
                }
            }

        }

    }
    var i:u32 = 0;
    var overLappingPoints: u32 = 0;
    var overLappingPoints2: u32 = 0;
    
    //i += 1;
    //overLappingPoints += 1;
    //overLappingPoints2 += 1;
    while(i < boardSize * boardSize)
    {
        overLappingPoints += if(lineBoard[i] > 1) @as(u32, 1) else @as(u32, 0);
        overLappingPoints2 += if(lineBoard[i] + lineBoard2[i] > 1) @as(u32, 1) else @as(u32, 0);
        i += 1;
    }
    print("Day5-1: Overlapping points: {d}\n", .{overLappingPoints});
    print("Day5-2: Overlapping points: {d}\n", .{overLappingPoints2});
}

fn distance(a: u32, b: u32) u32
{
    return if(a > b) a - b else b - a;
}

fn direction(a: u32, b: u32) i32
{
    return if(a > b) -1 else 1;
}