const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;


pub fn day8(alloc: *std.mem.Allocator, comptime inputFile: []const u8 ) anyerror!void
{

    // cos of allocator
    var board = std.ArrayList(u64).init(alloc);
    defer board.deinit();
    {
        var nums: [10]u64 = std.mem.zeroes([10]u64);
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");

        while (lines.next()) |line|
        {
            var splits = std.mem.tokenize(u8, line, "|");
            _ = splits.next().?;
            const rightSide = splits.next().?;
            var numTexts = std.mem.tokenize(u8, rightSide, " ");
            while(numTexts.next()) | numText |
            {
                if(numText.len == 2) nums[1] += 1;
                if(numText.len == 4) nums[4] += 1;
                if(numText.len == 3) nums[7] += 1;
                if(numText.len == 7) nums[8] += 1;
                //print("l:{d}, ", .{numText.len});
            }
            //print("Text: {s}\n", .{rightSide});
        }
        print("Day8-1: 1,4,7,8 appears: {} times\n", .{nums[1] + nums[4] + nums[7] + nums[8]});
    }
    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        var numberSum: u64 = 0;
        while (lines.next()) |line|
        {
            var splits = std.mem.tokenize(u8, line, "|");
            const leftSide = splits.next().?;
            var nums: [10]u64 = .{127, 127, 127, 127, 127, 127, 127, 127, 127, 127};
            var nums2: [10]u64 = std.mem.zeroes([10]u64);

            var numTexts = std.mem.tokenize(u8, leftSide, " ");
            var i:u32 = 0;
            while(numTexts.next()) | numText |
            {
                var indices: u64 = getIndices(numText);

                if(numText.len == 2) nums[1] = indices & 255;
                if(numText.len == 4) nums[4] = indices & 255;
                if(numText.len == 3) nums[7] = indices & 255;
                if(numText.len == 7) nums[8] = indices & 255;
                nums2[i] = indices;
                i += 1;
            }
            i = 0;
            while(i < 10) : (i += 1)
            {
                const numLen:u64 = nums2[i] >> 10;
                const t:u64 = nums2[i] & 255;
                if(numLen == 6)
                {
                    if(checkBInA(t, nums[7]))
                    {
                        if(checkBInA(t, nums[4]))
                        {
                            nums[9] = t;
                        }
                        else
                        {
                            nums[0] = t;
                        }
                    }
                    else
                    {
                        nums[6] = t;
                    }
                }
                else if(numLen == 5)
                {
                    if(checkBInA(t, nums[7]))
                    {
                        nums[3] = t;
                    }
                    else if(checkBInA(t, 127 - nums[4]))
                    {
                        nums[2] = t;
                    }
                    else
                    {
                        nums[5] = t;
                    }
                }
            }

            const rightSide = splits.next().?;
            numTexts = std.mem.tokenize(u8, rightSide, " ");
            var number: u64 = 0;
            while(numTexts.next()) | numText |
            {
                var indices: u64 = getIndices(numText) & 255;
                i = 0;
                while(i < 10) : (i += 1)
                {
                    if(nums[i] == indices)
                    {
                        number = number * 10 + i;
                    }
                }
            }
            numberSum += number;

        }
        print("Day8-2: 7 digit numbers sum: {}\n", .{numberSum});
    }
}

fn checkBInA(a: u64, b: u64) bool
{
    return ((a & b) & 255) == (b & 255);
}

// first 7 bits the ons, from 10 onwards how many
fn getIndices(numText: []const u8) u64
{
    var indices: u64 = 0;
    if(std.mem.count(u8, numText, "a") > 0) indices += 1 + 1024;
    if(std.mem.count(u8, numText, "b") > 0) indices += 2 + 1024;
    if(std.mem.count(u8, numText, "c") > 0) indices += 4 + 1024;
    if(std.mem.count(u8, numText, "d") > 0) indices += 8 + 1024;
    if(std.mem.count(u8, numText, "e") > 0) indices += 16 + 1024;
    if(std.mem.count(u8, numText, "f") > 0) indices += 32 + 1024;
    if(std.mem.count(u8, numText, "g") > 0) indices += 64 + 1024;
    return indices;
}