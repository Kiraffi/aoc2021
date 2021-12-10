const std = @import("std");

//const print = std.log.info;
const print = std.debug.print;


pub fn day10(alloc: *std.mem.Allocator, comptime inputFile: []const u8 ) anyerror!void
{
    // cos of allocator
    var autoScores = std.ArrayList(u64).init(alloc);
    defer autoScores.deinit();

    {
        var lines = std.mem.tokenize(u8, inputFile, "\r\n");
        // Parse
        var errorScore: u64 = 0;
        //var lineNum: u64 = 0;
        while (lines.next()) |line|
        {
            //print("Line: {}\n", .{lineNum});
            var newLine: [160]u8 = std.mem.zeroes([160]u8);
            const errorChar: u8 = findErrorChar(line, &newLine);
            if(errorChar != 0)
            {
                errorScore += switch(errorChar)
                {
                    '>' => 25137,
                    '}' => 1197,
                    ']' => 57,
                    ')' => 3,
                    else => @as(u64, 0),
                };
                //print("Error at line:{}, {c}\n", .{lineNum, errorChar});
            }
            else
            {
                var i:u32 = 0;
                while(newLine[i] != 0) : (i += 1) {}
                var score: u64 = 0;
                while(i > 0) : (i -= 1)
                {
                    const val = switch(newLine[i - 1])
                    {
                        '<' => 4,
                        '{' => 3,
                        '[' => 2,
                        '(' => 1,
                        else => @as(u64, 0),
                    };
                    score = score * 5 + val;
                }
                try autoScores.append(score);
            }
        }
        print("Day10-1: Syntax error score: {}\n", .{errorScore});

        std.sort.sort(u64, autoScores.items, {}, comptime std.sort.asc(u64));
        var i:u64 = (autoScores.items.len) / 2;
        print("Day10-2: Score: {}\n", .{autoScores.items[i]});

    }
}


fn findErrorChar(line: []const u8, newLine: []u8 ) u8
{
    {
        var i:u64 = 0;
        while(i < line.len) : (i += 1)
        {
            newLine[i] = line[i];
        }
    }
    var i:i64 = 0;
    var end:i64 = @intCast(i64, line.len);
    while(i < end) : (i += 1)
    {
        const ii: u64 = @intCast(u64, i);
        const removeChars: bool = switch(newLine[ii])
        {
            '>' => if(newLine[ii - 1] != '<') { return '>'; } else true,
            '}' => if(newLine[ii - 1] != '{') { return '}'; } else true,
            ']' => if(newLine[ii - 1] != '[') { return ']'; } else true,
            ')' => if(newLine[ii - 1] != '(') { return ')'; } else true,
            else => false,
        };
        if(removeChars)
        {
            var j:u64 = ii - 1;
            const jEnd: u64 = @intCast(u64, end);
            while(j < jEnd - 2) : (j += 1)
            {
                newLine[j] = newLine[j + 2];
            }
            newLine[jEnd - 2] = 0;
            end -= 2;
            i -= 2;
        }
    }
    return 0;
}

