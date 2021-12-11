const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;

//pub fn day5(alloc: *std.mem.Allocator, comptime inputFileName: []const u8 ) anyerror!void

pub fn day5(comptime inputFile: []const u8 ) anyerror!void
{
    //const inputFile = @embedFile(inputFileName);

    var lines = std.mem.tokenize(u8, inputFile, "\r\n");
    const boardSize: u32 = 1024;
    var lineBoard: [boardSize * boardSize]u8 = std.mem.zeroes([boardSize * boardSize]u8);

    var overLappingPoints: u32 = 0;
    var overLappingPoints2: u32 = 0;


    while (lines.next()) |line|
    {
        var charIndex: u32 = 0;
        const x1 = getNumber(line, &charIndex);
        charIndex += 1;
        const y1 = getNumber(line, &charIndex);


        charIndex += 4;
        const x2 = getNumber(line, &charIndex);
        charIndex += 1;
        const y2 = getNumber(line, &charIndex);

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
                //const ind: u32 = getIndex(xmin, ymin);
                if(lineBoard[ind] & 10 != 10)
                {
                    if(lineBoard[ind] & 2 == 0)
                    {
                        lineBoard[ind] += 1;
                        overLappingPoints += (lineBoard[ind] >> 1) & 1;
                    }

                    if(lineBoard[ind] & 8 == 0)
                    {
                        lineBoard[ind] += 4;
                        overLappingPoints2 += (lineBoard[ind] >> 3);
                    }
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
                //const index: u32 = getIndex(@intCast(u32, px), @intCast(u32, py));
                if(lineBoard[index] & 8 == 0)
                {
                    lineBoard[index] += 4;
                    overLappingPoints2 += (lineBoard[index] >> 3);
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

fn getIndex(x: u32, y:u32) u32
{
    const xBorder:u32 = x >> 4;
    const yBorder:u32 = y >> 4;
    const borderInd: u32 = xBorder + yBorder * 64; // 1024 / 16 = 64
    return (x & 15) + (y & 15) * 16 + borderInd * 256;
}

fn getNumber(line: []const u8, ind: *u32) u32
{
    var result: u32 = 0;
    while(ind.* < line.len) : (ind.* += 1)
    {
        const c: u8 = line[ind.*];
        if(c >= '0' and c <= '9')
        {
            result = result * 10 + @intCast(u32, c - '0');
        }
        else
        {
            return result;
        }
    }
    return result;
}

fn distance(a: u32, b: u32) u32
{
    return if(a > b) a - b else b - a;
}

fn direction(a: u32, b: u32) i32
{
    return if(a > b) -1 else 1;
}