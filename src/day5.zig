const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

//pub fn day5(alloc: *std.mem.Allocator, comptime inputFileName: []const u8 ) anyerror!void

pub fn day5(comptime inputFile: []const u8 ) anyerror!void
{
    //const inputFile = @embedFile(inputFileName);
    var parseTimer : std.time.Timer =  try std.time.Timer.start();
    defer print("Day5-1: Parsing: {d}\n", .{parseTimer.read() / 1000});

    var lines = std.mem.tokenize(u8, inputFile, "\r\n");
    const boardSize: u32 = 1000;
    var lineBoard: [boardSize * boardSize]u8 = std.mem.zeroes([boardSize * boardSize]u8);

    var overLappingPoints: u32 = 0;
    var overLappingPoints2: u32 = 0;


    while (lines.next()) |line|
    {
        var numbIter = std.mem.tokenize(u8, line, ",");

        const x1 = try std.fmt.parseInt(u32, numbIter.next().?, 10);

        var middleIter = std.mem.tokenize(u8, numbIter.next().?, " -> ");
        const y1 = try std.fmt.parseInt(u32, middleIter.next().?, 10);
        const x2 = try std.fmt.parseInt(u32, middleIter.next().?, 10);

        const y2 = try std.fmt.parseInt(u32, numbIter.next().?, 10);

        const dx:u32 = distance(x2, x1);
        const dy:u32 = distance(y2, y1);

        if(dx == 0 or dy == 0)
        {
            var xmin:u32 = @minimum(x1, x2);
            var ymin:u32 = @minimum(y1, y2);
            const dist = dx + dy;
            var i:u32 = 0;
            while(i <= dist) : (i += 1)
            {
                const ind: u32 = xmin + boardSize * ymin;
                if(lineBoard[ind] & 10 != 10)
                {
                    var v = lineBoard[ind];
                    if(v & 2 == 0)
                    {
                        v += 1;
                        if(v & 2 != 0)
                            overLappingPoints += 1;
                    }

                    if(v & 8 == 0)
                    {
                        v += 4;
                        if(v & 8 != 0)
                            overLappingPoints2 += 1;
                    }
                    lineBoard[ind] = v;
                }
                xmin += if(dx != 0) @as(u32, 1) else @as(u32, 0);
                ymin += if(dy != 0) @as(u32, 1) else @as(u32, 0);
            }


        }
        else if(dx == dy)
        {
            const dirX:i32 = direction(x1, x2);
            const dirY:i32 = direction(y1, y2);

            var px:i32 = @intCast(i32, x1);
            var py:i32 = @intCast(i32, y1);
            var i:u32 = 0;
            while(i <= dx) : (i += 1)
            {
                const index: u32 = @intCast(u32, px) + @intCast(u32, py) * boardSize;
                if(lineBoard[index] & 8 == 0)
                {
                    var v = lineBoard[index];
                    v += 4;
                    if(v & 1 != 0)
                        v += 4;
                    if(v & 8 != 0)
                        overLappingPoints2 += 1;
                    lineBoard[index] = v;
                }

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